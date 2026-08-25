#!/usr/bin/env bash
set -euo pipefail

chrome_binary="${CHROME_BINARY:-google-chrome}"
profile_directory="${NEXUS_CHROME_PROFILE:-/tmp/nexus-exodus-webclient}"
webclient_url="${NEXUS_WEBCLIENT_URL:-http://www.byond.com/play/embed/127.0.0.1:50000}"

if ! command -v "$chrome_binary" >/dev/null 2>&1; then
	printf 'Chrome executable not found: %s\n' "$chrome_binary" >&2
	exit 1
fi

exec "$chrome_binary" \
	--user-data-dir="$profile_directory" \
	--no-first-run \
	--disable-extensions \
	--disable-features=HttpsUpgrades \
	"$webclient_url"
