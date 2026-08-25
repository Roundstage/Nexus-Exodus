#!/bin/sh
set -eu

repository_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
compose_file="$repository_root/deploy/docker/compose.yaml"
project_name="nexus-local"

if ! command -v docker >/dev/null 2>&1; then
	echo "Docker is not installed or is not available on PATH." >&2
	echo "Install Docker Engine with the Compose plugin, then run this command again." >&2
	exit 1
fi

if ! docker info >/dev/null 2>&1; then
	echo "The Docker daemon is unavailable to the current user." >&2
	echo "Start Docker and ensure this user can access it." >&2
	exit 1
fi

action=${1:-up}
shift_count=0
if [ "$#" -gt 0 ]; then
	shift_count=1
fi
if [ "$shift_count" -eq 1 ]; then
	shift
fi

run_compose() {
	NEXUS_BIND_ADDRESS=127.0.0.1 \
	NEXUS_BACKEND_PORT=50000 \
	NEXUS_IMAGE_TAG=local-516.1686 \
		docker compose --project-name "$project_name" --file "$compose_file" "$@"
}

case "$action" in
	up)
		run_compose up --detach --build "$@"
		echo "Nexus is starting. WebClient: http://localhost:50000/play"
		echo "Inspect startup with: $0 logs"
		;;
	down)
		run_compose down "$@"
		;;
	logs)
		run_compose logs --follow --tail 200 "$@"
		;;
	status)
		run_compose ps "$@"
		;;
	rebuild)
		run_compose up --detach --build --force-recreate "$@"
		;;
	*)
		echo "Usage: $0 {up|down|logs|status|rebuild}" >&2
		exit 2
		;;
esac
