#!/usr/bin/env bash
# network-check.sh - basic network diagnostics
# Usage: ./network-check.sh <hostname-or-ip> [port]

LOG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/toolkit.log"

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') [network-check] $1" >> "$LOG_FILE"
}

if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "Usage: $0 <hostname-or-ip> [port]" >&2
  log "Invalid arguments: expected 1 or 2, got $#"
  exit 2
fi

HOST="$1"
PORT="${2:-}"

# Host may only contain letters, digits, dots and hyphens
if ! [[ "$HOST" =~ ^[A-Za-z0-9]([A-Za-z0-9.-]*[A-Za-z0-9])?$ ]]; then
  echo "Error: invalid host: $HOST" >&2
  log "Invalid host: $HOST"
  exit 2
fi

if [[ -n "$PORT" ]]; then
  if ! [[ "$PORT" =~ ^[0-9]{1,5}$ ]] || (( 10#$PORT < 1 || 10#$PORT > 65535 )); then
    echo "Error: port must be an integer from 1 to 65535" >&2
    log "Invalid port: $PORT"
    exit 2
  fi
fi

FAILED=0

echo "===== Network Check: $HOST ====="
log "Started network check for $HOST${PORT:+ port $PORT}"

# 1. Resolve the host
RESOLVED=$(getent ahosts "$HOST" 2>/dev/null | awk 'NR==1 {print $1}')
if [[ -z "$RESOLVED" ]]; then
  echo "Resolution: FAILED - could not resolve $HOST"
  log "Could not resolve $HOST"
  exit 1
fi
echo "Resolved address: $RESOLVED"
log "Resolved $HOST to $RESOLVED"

# 2. Basic connectivity check (ping)
if command -v ping >/dev/null 2>&1; then
  if ping -c 1 -W 2 "$HOST" >/dev/null 2>&1; then
    echo "Ping: OK"
    log "Ping to $HOST succeeded"
  else
    echo "Ping: FAILED (host unreachable or blocking ping)"
    log "Ping to $HOST failed"
    FAILED=1
  fi
else
  echo "Ping: skipped (ping command not available)"
  log "Ping skipped: command not available"
fi

# 3. Network interface information
echo "--- Network interfaces ---"
if command -v ip >/dev/null 2>&1; then
  ip -brief address 2>/dev/null || ip addr
elif command -v ifconfig >/dev/null 2>&1; then
  ifconfig
else
  echo "No interface tool available (ip/ifconfig)"
fi
log "Displayed network interface information"

# 4. Optional TCP port check
if [[ -n "$PORT" ]]; then
  if timeout 3 bash -c 'exec 3<>/dev/tcp/"$1"/"$2"' _ "$HOST" "$PORT" 2>/dev/null; then
    echo "TCP port $PORT: OPEN"
    log "TCP port $PORT on $HOST is open"
  else
    echo "TCP port $PORT: CLOSED or unreachable"
    log "TCP port $PORT on $HOST is closed or unreachable"
    FAILED=1
  fi
fi

log "Finished network check for $HOST (result: $FAILED)"
exit $FAILED
