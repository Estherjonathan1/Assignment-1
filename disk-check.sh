#!/usr/bin/env bash
# disk-check.sh - check disk usage against a threshold
# Usage: ./disk-check.sh <threshold 1-100> [path]

LOG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/toolkit.log"

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') [disk-check] $1" >> "$LOG_FILE"
}

if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "Usage: $0 <threshold 1-100> [path]" >&2
  log "Invalid arguments: expected 1 or 2, got $#"
  exit 2
fi

THRESHOLD="$1"
TARGET="${2:-/}"

if ! [[ "$THRESHOLD" =~ ^[0-9]+$ ]] || (( 10#$THRESHOLD < 1 || 10#$THRESHOLD > 100 )); then
  echo "Error: threshold must be an integer from 1 to 100" >&2
  log "Invalid threshold: $THRESHOLD"
  exit 2
fi

if [[ ! -e "$TARGET" ]]; then
  echo "Error: path does not exist: $TARGET" >&2
  log "Invalid path: $TARGET"
  exit 2
fi

USAGE=$(df -P "$TARGET" 2>/dev/null | awk 'NR==2 {gsub("%","",$5); print $5}')

if [[ -z "$USAGE" ]]; then
  echo "Error: could not read disk usage for $TARGET" >&2
  log "Failed to read disk usage for $TARGET"
  exit 1
fi

echo "Disk usage for $TARGET: ${USAGE}% (threshold: ${THRESHOLD}%)"
log "Checked $TARGET: usage ${USAGE}%, threshold ${THRESHOLD}%"

if (( USAGE >= THRESHOLD )); then
  echo "WARNING: usage has reached or exceeded the threshold"
  log "Result: threshold reached or exceeded"
  exit 1
fi

echo "OK: usage is below the threshold"
log "Result: below threshold"
exit 0
