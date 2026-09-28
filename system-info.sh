#!/usr/bin/env bash
# system-info.sh - display system information collected at runtime

LOG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/toolkit.log"

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') [system-info] $1" >> "$LOG_FILE"
}

log "Started system information collection"

echo "===== System Information ====="
echo "Hostname:          $(hostname)"
echo "Current user:      $(whoami)"
echo "Date/time:         $(date)"
echo "Operating system:  $(. /etc/os-release 2>/dev/null && echo "$PRETTY_NAME" || uname -s)"
echo "Kernel version:    $(uname -r)"
echo "Uptime:            $(uptime -p 2>/dev/null || uptime)"
echo "CPU:               $(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | sed 's/^ //') ($(nproc) cores)"
echo "Memory:            $(free -h | awk '/^Mem:/ {print $3 " used / " $2 " total"}')"
echo "Working directory: $(pwd)"

log "Completed system information collection"
exit 0
