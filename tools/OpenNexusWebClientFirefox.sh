#!/usr/bin/env bash
set -euo pipefail

profile_directory="${NEXUS_FIREFOX_PROFILE:-/tmp/nexus-exodus-firefox}"
webclient_url="${NEXUS_WEBCLIENT_URL:-http://www.byond.com/play/embed/127.0.0.1:50000}"

if ! command -v firefox >/dev/null 2>&1; then
	printf 'Firefox executable not found.\n' >&2
	exit 1
fi

mkdir -p "$profile_directory"
exec firefox --no-remote --profile "$profile_directory" "$webclient_url"
