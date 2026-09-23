#!/bin/sh
# Run on the Linux Docker host while the symptom is happening.
set -eu
export LC_ALL=C

usage() {
	printf 'Usage: sh tools/Measure-NexusDockerCpu.sh [container-name-or-id]\n'
}

if [ "$#" -gt 1 ]; then
	usage >&2
	exit 2
fi
case "${1:-}" in
	-h|--help) usage; exit 0 ;;
	-*) usage >&2; exit 2 ;;
esac

for dependency in docker top awk; do
	if ! command -v "$dependency" >/dev/null 2>&1; then
		printf 'Required command is unavailable: %s\n' "$dependency" >&2
		exit 1
	fi
done

# docker top returns host PIDs. They are only meaningful to top on that host.
docker_endpoint=${DOCKER_HOST:-}
if [ -n "${DOCKER_CONTEXT:-}" ] || [ -z "$docker_endpoint" ]; then
	docker_endpoint=$(docker context inspect --format '{{.Endpoints.docker.Host}}')
fi
case "$docker_endpoint" in
	unix://*) ;;
	*)
		printf 'Run this script on the VPS using its local Docker Unix socket.\n' >&2
		exit 1
		;;
esac

container=${1:-}
if [ -z "$container" ]; then
	candidates=$(docker ps -aq --filter label=com.docker.compose.service=nexus-exodus)
	candidate_count=$(printf '%s\n' "$candidates" | awk 'NF { count++ } END { print count+0 }')
	if [ "$candidate_count" -ne 1 ]; then
		printf 'Expected one Nexus container; found %s. Pass its name or ID explicitly.\n' "$candidate_count" >&2
		docker ps -a --filter label=com.docker.compose.service=nexus-exodus --format 'table {{.Names}}\t{{.Status}}'
		exit 1
	fi
	container=$candidates
fi
container=$(docker inspect --type container --format '{{.Id}}' "$container")

printf '\nCPU diagnostic (UTC): '
date -u '+%Y-%m-%dT%H:%M:%SZ'
docker info --format 'Docker={{.ServerVersion}} OS={{.OSType}} Architecture={{.Architecture}} CPUs={{.NCPU}} Kernel={{.KernelVersion}}'
docker inspect --format 'Container={{.Name}} Status={{.State.Status}} Started={{.State.StartedAt}} Restarts={{.RestartCount}} HostPID={{.State.Pid}}' "$container"
docker inspect --format 'NanoCpus={{.HostConfig.NanoCpus}} CpuQuota={{.HostConfig.CpuQuota}} CpuPeriod={{.HostConfig.CpuPeriod}} Cpuset={{.HostConfig.CpusetCpus}} LogDriver={{.HostConfig.LogConfig.Type}}' "$container"
image_id=$(docker inspect --format '{{.Image}}' "$container")
docker image inspect --format 'Image={{.Id}} OS={{.Os}} Architecture={{.Architecture}}' "$image_id"

if [ "$(docker inspect --format '{{.State.Running}}' "$container")" != true ]; then
	printf '\nContainer is offline. No CPU sample was taken; nothing was started.\n'
	exit 0
fi

print_cgroup_cpu() {
	# Missing files are normal across cgroup v1/v2 layouts. No writes or signals.
	docker exec "$container" sh -c '
		for metric in /sys/fs/cgroup/cpu.stat /sys/fs/cgroup/cpu.max \
			/sys/fs/cgroup/cpu/cpu.stat /sys/fs/cgroup/cpu/cpu.cfs_quota_us \
			/sys/fs/cgroup/cpu/cpu.cfs_period_us \
			/sys/fs/cgroup/cpu,cpuacct/cpu.stat; do
			if [ -r "$metric" ]; then
				printf "\n%s\n" "$metric"
				cat "$metric"
			fi
		done
	'
}

printf '\nContainer totals before sampling:\n'
docker stats --no-stream "$container"
print_cgroup_cpu

printf '\nHost CPU and busiest processes (second top frame):\n'
# Show current interval usage, including dockerd/docker-proxy and CPU steal.
# Use top's default configuration (process names, not full command lines).
top -b -n 2 -d 1 -w 160 -o '%CPU' | awk '
	/^top -/ { frame++; line=0 }
	frame == 2 { line++; if (line <= 22) print }
'

printf '\nContainer processes with host PIDs (%%CPU here is the lifetime average):\n'
process_table=$(docker top "$container" -eo pid,ppid,pcpu,nlwp,comm)
printf '%s\n' "$process_table"
process_count=$(printf '%s\n' "$process_table" | awk 'NR > 1 && $1 ~ /^[0-9]+$/ { count++ } END { print count+0 }')
pid_list=$(printf '%s\n' "$process_table" | awk '
	NR > 1 && $1 ~ /^[0-9]+$/ && count < 20 {
		printf "%s%s", separator, $1; separator=","; count++
	}
')
if [ -z "$pid_list" ]; then
	printf 'Container has no processes to sample. It may have stopped.\n' >&2
	exit 1
fi
if [ "$process_count" -gt 20 ]; then
	printf 'Only the first 20 processes can be passed to top; the process table above is complete.\n'
fi

printf '\nContainer threads: ignore the first frame; compare the next three 5-second intervals.\n'
printf 'Host PIDs/TIDs are shown. In top Irix mode, 100%% represents one logical CPU.\n'
printf 'The captured PID list excludes processes created later (e.g. brief healthchecks).\n'
top -b -H -n 4 -d 5 -w 160 -o '%CPU' -p "$pid_list"

printf '\nContainer totals after sampling:\n'
docker stats --no-stream "$container"
print_cgroup_cpu
printf '\nDone. Compare with the in-game Processor reading taken during these intervals.\n'
