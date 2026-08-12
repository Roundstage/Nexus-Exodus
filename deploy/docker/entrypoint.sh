#!/bin/sh
set -eu

runtime_dir="${NEXUS_RUNTIME_DIR:-/srv/nexus/runtime}"
release_marker="$runtime_dir/.release-sha256"
release_hash="$(sha256sum /opt/nexus/DU.dmb /opt/nexus/DU.rsc | sha256sum | cut -d ' ' -f 1)"
installed_release=""

mkdir -p "$runtime_dir"
chmod 0700 "$runtime_dir"

if [ -f "$release_marker" ]; then
	installed_release="$(sed -n '1p' "$release_marker")"
fi

if [ "$installed_release" != "$release_hash" ] || [ ! -s "$runtime_dir/DU.dmb" ] || [ ! -s "$runtime_dir/DU.rsc" ]; then
	echo "Installing Nexus runtime release $release_hash"
	cp /opt/nexus/DU.dmb "$runtime_dir/DU.dmb.next"
	cp /opt/nexus/DU.rsc "$runtime_dir/DU.rsc.next"
	chmod 0400 "$runtime_dir/DU.dmb.next" "$runtime_dir/DU.rsc.next"
	mv -f "$runtime_dir/DU.dmb.next" "$runtime_dir/DU.dmb"
	mv -f "$runtime_dir/DU.rsc.next" "$runtime_dir/DU.rsc"
	rm -f "$runtime_dir/DU.dyn.rsc" "$runtime_dir/DU.dyn.rsc.lk"
	printf '%s\n' "$release_hash" > "$release_marker"
fi

exec /opt/byond/bin/DreamDaemon "$runtime_dir/DU.dmb" "$@"
