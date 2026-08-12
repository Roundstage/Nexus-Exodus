#!/usr/bin/env python3
"""Binary-safe profile-media inspection for the sandboxed BYOND runtime."""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import signal
import struct
import sys
import tempfile
import time
from pathlib import Path
from urllib.parse import parse_qs, urlencode


MIN_BYTES = 1024
MAX_BYTES = 8 * 1024 * 1024
MAX_DIMENSION = 3840
MAX_PIXELS = 3840 * 2160
REQUEST_MAX_AGE_SECONDS = 600

REQUEST_NAME_RE = re.compile(r"^\.inspect-([0-9a-f]{32})\.request$")
RESULT_NAME_RE = re.compile(r"^\.inspect-([0-9a-f]{32})\.result(?:\.next)?$")
UPLOAD_NAME_RE = re.compile(
    r"^\.upload-([a-z0-9]{1,64})-slot([1-3])-([0-9a-f]{32})\.(webp|webm)$"
)
HASH_RE = re.compile(r"^[0-9a-f]{40}$")


class InspectionError(ValueError):
    def __init__(self, code: str):
        super().__init__(code)
        self.code = code


def _u24le(data: bytes) -> int:
    return data[0] | (data[1] << 8) | (data[2] << 16)


def inspect_webp(data: bytes) -> tuple[int, int]:
    if len(data) < 20 or data[:4] != b"RIFF" or data[8:12] != b"WEBP":
        raise InspectionError("invalid_webp_signature")
    if struct.unpack_from("<I", data, 4)[0] + 8 != len(data):
        raise InspectionError("invalid_webp_container_size")

    position = 12
    dimensions: tuple[int, int] | None = None
    while position + 8 <= len(data):
        chunk_type = data[position : position + 4]
        chunk_size = struct.unpack_from("<I", data, position + 4)[0]
        payload = position + 8
        payload_end = payload + chunk_size
        if payload_end > len(data):
            raise InspectionError("truncated_webp_chunk")

        chunk_dimensions: tuple[int, int] | None = None
        if chunk_type == b"VP8X" and chunk_size >= 10:
            chunk_dimensions = _u24le(data[payload + 4 : payload + 7]) + 1, _u24le(
                data[payload + 7 : payload + 10]
            ) + 1
        elif chunk_type == b"VP8L" and chunk_size >= 5 and data[payload] == 0x2F:
            byte_0, byte_1, byte_2, byte_3 = data[payload + 1 : payload + 5]
            width = 1 + byte_0 + ((byte_1 & 0x3F) << 8)
            height = 1 + ((byte_1 & 0xC0) >> 6) + (byte_2 << 2) + ((byte_3 & 0x0F) << 10)
            chunk_dimensions = width, height
        elif (
            chunk_type == b"VP8 "
            and chunk_size >= 10
            and data[payload + 3 : payload + 6] == b"\x9d\x01\x2a"
        ):
            width = struct.unpack_from("<H", data, payload + 6)[0] & 0x3FFF
            height = struct.unpack_from("<H", data, payload + 8)[0] & 0x3FFF
            if width and height:
                chunk_dimensions = width, height

        if chunk_dimensions:
            if dimensions and dimensions != chunk_dimensions:
                raise InspectionError("conflicting_webp_dimensions")
            dimensions = chunk_dimensions

        position = payload_end + (chunk_size & 1)
    if position != len(data):
        raise InspectionError("truncated_webp_container")
    if not dimensions:
        raise InspectionError("missing_webp_dimensions")
    return dimensions


def _read_ebml_vint(data: bytes, position: int, limit: int) -> tuple[int, int, bool]:
    if position >= limit:
        raise InspectionError("truncated_webm_vint")
    first = data[position]
    marker = 0x80
    length = 1
    while length <= 8 and not first & marker:
        marker >>= 1
        length += 1
    if length > 8 or position + length > limit:
        raise InspectionError("invalid_webm_vint")
    value = first & (marker - 1)
    unknown = value == marker - 1
    for byte in data[position + 1 : position + length]:
        value = (value << 8) | byte
        if byte != 0xFF:
            unknown = False
    return value, length, unknown


def _read_ebml_id(data: bytes, position: int, limit: int) -> tuple[int, int]:
    if position >= limit:
        raise InspectionError("truncated_webm_element")
    first = data[position]
    marker = 0x80
    length = 1
    while length <= 4 and not first & marker:
        marker >>= 1
        length += 1
    if length > 4 or position + length > limit:
        raise InspectionError("invalid_webm_element")
    value = 0
    for byte in data[position : position + length]:
        value = (value << 8) | byte
    return value, length


def _inspect_webm_video_payload(data: bytes, start: int, end: int) -> tuple[int, int] | None:
    width = 0
    height = 0
    position = start
    while position < end:
        try:
            element_id, id_length = _read_ebml_id(data, position, end)
            element_size, size_length, unknown = _read_ebml_vint(
                data, position + id_length, end
            )
        except InspectionError:
            return None
        if unknown:
            return None
        payload = position + id_length + size_length
        payload_end = payload + element_size
        if payload_end > end:
            return None
        if element_id in (0xB0, 0xBA) and 1 <= element_size <= 4:
            value = int.from_bytes(data[payload:payload_end], "big")
            if element_id == 0xB0:
                width = value
            else:
                height = value
            if width and height:
                return width, height
        position = payload_end
    return None


def inspect_webm(data: bytes) -> tuple[int, int]:
    if len(data) < 12 or data[:4] != b"\x1aE\xdf\xa3" or b"webm" not in data[:4096].lower():
        raise InspectionError("invalid_webm_signature")
    scan_limit = min(len(data), 1024 * 1024)
    for position in range(4, scan_limit):
        if data[position] != 0xE0:
            continue
        try:
            payload_size, size_length, unknown = _read_ebml_vint(
                data, position + 1, scan_limit
            )
        except InspectionError:
            continue
        payload = position + 1 + size_length
        payload_end = scan_limit if unknown else payload + payload_size
        if payload >= payload_end or payload_end > scan_limit:
            continue
        dimensions = _inspect_webm_video_payload(data, payload, payload_end)
        if dimensions:
            return dimensions
    raise InspectionError("missing_webm_dimensions")


def inspect_png(data: bytes) -> tuple[int, int]:
    if len(data) < 24 or data[:8] != b"\x89PNG\r\n\x1a\n" or data[12:16] != b"IHDR":
        raise InspectionError("invalid_png_signature")
    return struct.unpack_from(">II", data, 16)


def inspect_jpeg(data: bytes) -> tuple[int, int]:
    if len(data) < 4 or data[:3] != b"\xff\xd8\xff":
        raise InspectionError("invalid_jpeg_signature")
    position = 2
    sof_markers = {
        0xC0,
        0xC1,
        0xC2,
        0xC3,
        0xC5,
        0xC6,
        0xC7,
        0xC9,
        0xCA,
        0xCB,
        0xCD,
        0xCE,
        0xCF,
    }
    while position + 3 < len(data):
        while position < len(data) and data[position] != 0xFF:
            position += 1
        while position < len(data) and data[position] == 0xFF:
            position += 1
        if position >= len(data):
            break
        marker = data[position]
        position += 1
        if marker in (0xD8, 0xD9) or 0xD0 <= marker <= 0xD7:
            continue
        if position + 2 > len(data):
            break
        segment_length = struct.unpack_from(">H", data, position)[0]
        if segment_length < 2 or position + segment_length > len(data):
            raise InspectionError("truncated_jpeg_segment")
        if marker in sof_markers:
            if segment_length < 7:
                raise InspectionError("invalid_jpeg_dimensions")
            height, width = struct.unpack_from(">HH", data, position + 3)
            return width, height
        position += segment_length
    raise InspectionError("missing_jpeg_dimensions")


INSPECTORS = {
    "jpg": inspect_jpeg,
    "png": inspect_png,
    "webm": inspect_webm,
    "webp": inspect_webp,
}


def inspect_media(path: Path, media_format: str) -> dict[str, object]:
    if media_format not in INSPECTORS:
        raise InspectionError("unsupported_format")
    try:
        stat = path.lstat()
    except OSError as error:
        raise InspectionError("missing_upload") from error
    if path.is_symlink() or not path.is_file():
        raise InspectionError("invalid_upload_path")
    if stat.st_size < MIN_BYTES or stat.st_size > MAX_BYTES:
        raise InspectionError("invalid_file_size")
    try:
        data = path.read_bytes()
    except OSError as error:
        raise InspectionError("unreadable_upload") from error
    if len(data) != stat.st_size:
        raise InspectionError("changed_file_size")
    width, height = INSPECTORS[media_format](data)
    if (
        width < 1
        or height < 1
        or width > MAX_DIMENSION
        or height > MAX_DIMENSION
        or width * height > MAX_PIXELS
    ):
        raise InspectionError("dimensions_out_of_bounds")
    return {
        "status": "ok",
        "format": media_format,
        "bytes": len(data),
        "width": width,
        "height": height,
        "hash": hashlib.sha1(data).hexdigest(),
    }


def _write_result(result_path: Path, result: dict[str, object]) -> None:
    next_path = result_path.with_name(result_path.name + ".next")
    next_path.write_text(urlencode(result), encoding="ascii")
    os.replace(next_path, result_path)


def _process_request(root: Path, request_path: Path, ticket: str) -> None:
    result_path = root / f".inspect-{ticket}.result"
    try:
        lines = request_path.read_text(encoding="ascii").splitlines()
        if len(lines) != 4:
            raise InspectionError("invalid_request")
        media_format, upload_name, expected_size_text, expected_hash = lines
        upload_match = UPLOAD_NAME_RE.fullmatch(upload_name)
        if (
            media_format not in ("webp", "webm")
            or not upload_match
            or upload_match.group(3) != ticket
            or upload_match.group(4) != media_format
            or not HASH_RE.fullmatch(expected_hash)
        ):
            raise InspectionError("invalid_request")
        try:
            expected_size = int(expected_size_text)
        except ValueError as error:
            raise InspectionError("invalid_request") from error
        upload_path = root / upload_name
        result = inspect_media(upload_path, media_format)
        if result["bytes"] != expected_size or result["hash"] != expected_hash:
            raise InspectionError("upload_changed_during_inspection")
        _write_result(result_path, result)
    except InspectionError as error:
        _write_result(result_path, {"status": "error", "code": error.code})
    except Exception:
        _write_result(result_path, {"status": "error", "code": "inspector_failure"})
    finally:
        try:
            request_path.unlink()
        except FileNotFoundError:
            pass


def _cleanup_stale_files(root: Path) -> None:
    cutoff = time.time() - REQUEST_MAX_AGE_SECONDS
    for entry in root.iterdir():
        if not (REQUEST_NAME_RE.fullmatch(entry.name) or RESULT_NAME_RE.fullmatch(entry.name)):
            continue
        try:
            if entry.stat().st_mtime < cutoff:
                entry.unlink()
        except FileNotFoundError:
            continue


def run_daemon(root: Path) -> int:
    root.mkdir(parents=True, exist_ok=True)
    root = root.resolve(strict=True)
    ready_path = root / ".profile-media-inspector.ready"
    running = True

    def stop(_signum: int, _frame: object) -> None:
        nonlocal running
        running = False

    signal.signal(signal.SIGTERM, stop)
    signal.signal(signal.SIGINT, stop)
    _cleanup_stale_files(root)
    ready_path.write_text(f"{os.getpid()}\n", encoding="ascii")
    print(f"Profile media inspector ready: {root}", flush=True)
    last_cleanup = time.monotonic()
    try:
        while running:
            for entry in root.iterdir():
                match = REQUEST_NAME_RE.fullmatch(entry.name)
                if not match:
                    continue
                try:
                    if not entry.is_file() or time.time() - entry.stat().st_mtime < 0.05:
                        continue
                except FileNotFoundError:
                    continue
                _process_request(root, entry, match.group(1))
            if time.monotonic() - last_cleanup >= 60:
                _cleanup_stale_files(root)
                last_cleanup = time.monotonic()
            time.sleep(0.1)
    finally:
        try:
            ready_path.unlink()
        except FileNotFoundError:
            pass
    return 0


def run_self_test() -> int:
    webp = bytes(
        [
            82,
            73,
            70,
            70,
            22,
            0,
            0,
            0,
            87,
            69,
            66,
            80,
            86,
            80,
            56,
            32,
            10,
            0,
            0,
            0,
            0,
            0,
            0,
            157,
            1,
            42,
            104,
            1,
            31,
            2,
        ]
    )
    webm = bytes([26, 69, 223, 163, 119, 101, 98, 109, 224, 136, 176, 130, 7, 128, 186, 130, 4, 56])
    if inspect_webp(webp) != (360, 543) or inspect_webm(webm) != (1920, 1080):
        raise InspectionError("self_test_failed")
    protocol_webp = bytearray(webp[:20] + webp[20:30] + bytes(994))
    struct.pack_into("<I", protocol_webp, 4, len(protocol_webp) - 8)
    struct.pack_into("<I", protocol_webp, 16, len(protocol_webp) - 20)
    with tempfile.TemporaryDirectory(prefix="nexus-profile-inspector-") as temp_directory:
        root = Path(temp_directory)
        ticket = hashlib.md5(b"nexus-profile-inspector-self-test").hexdigest()
        upload_name = f".upload-profilearttest-slot1-{ticket}.webp"
        upload_path = root / upload_name
        upload_path.write_bytes(protocol_webp)
        expected_hash = hashlib.sha1(protocol_webp).hexdigest()
        request_path = root / f".inspect-{ticket}.request"
        request_path.write_text(
            f"webp\n{upload_name}\n{len(protocol_webp)}\n{expected_hash}\n",
            encoding="ascii",
        )
        _process_request(root, request_path, ticket)
        result_path = root / f".inspect-{ticket}.result"
        result = {
            key: values[0]
            for key, values in parse_qs(result_path.read_text(encoding="ascii")).items()
        }
        if result != {
            "status": "ok",
            "format": "webp",
            "bytes": str(len(protocol_webp)),
            "width": "360",
            "height": "543",
            "hash": expected_hash,
        }:
            raise InspectionError("protocol_self_test_failed")
    print("Profile media inspector self-test passed.")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--daemon", type=Path)
    parser.add_argument("--inspect", type=Path)
    parser.add_argument("--format", choices=sorted(INSPECTORS))
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()
    try:
        if args.self_test:
            return run_self_test()
        if args.inspect and args.format:
            print(json.dumps(inspect_media(args.inspect, args.format), sort_keys=True))
            return 0
        if args.daemon:
            return run_daemon(args.daemon)
        parser.error("choose --self-test, --daemon DIR, or --inspect FILE --format FORMAT")
    except InspectionError as error:
        print(json.dumps({"status": "error", "code": error.code}), file=sys.stderr)
        return 1
    return 2


if __name__ == "__main__":
    raise SystemExit(main())
