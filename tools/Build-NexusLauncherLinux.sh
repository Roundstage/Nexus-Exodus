#!/bin/sh
set -eu

repository_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
output_dir="$repository_root/NexusExodusLauncher/artifacts/linux"
image_name="nexus-exodus-launcher-builder:linux"
container_name="nexus-launcher-artifacts-$$"

if ! command -v docker >/dev/null 2>&1; then
	echo "Docker is not installed or is not available on PATH." >&2
	exit 1
fi

if ! docker info >/dev/null 2>&1; then
	echo "The Docker daemon is unavailable to the current user." >&2
	exit 1
fi

mkdir -p "$output_dir"

docker build \
	--file "$repository_root/NexusExodusLauncher/Dockerfile.linux" \
	--target build \
	--tag "$image_name" \
	"$repository_root"

docker create --name "$container_name" "$image_name" >/dev/null
trap 'docker rm --force "$container_name" >/dev/null 2>&1 || true' EXIT INT TERM
docker cp "$container_name:/launcher/src-tauri/target/release/bundle/." "$output_dir"
docker rm "$container_name" >/dev/null
trap - EXIT INT TERM

echo "Linux launcher artifacts: $output_dir"
