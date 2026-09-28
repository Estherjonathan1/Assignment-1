# Assignment 1 - Linux Diagnostic Toolkit

A set of Bash scripts that collect system information, check disk usage and run basic network checks.

## Requirements

- Linux (tested on Ubuntu under WSL2)
- Bash 4+
- Standard tools: `df`, `awk`, `getent`, `ping`, `ip`, `free`, `timeout`

## Setup

    git clone <your-repository-url>
    cd <repository>
    chmod +x *.sh

## Usage

### system-info.sh

Displays hostname, current user, date/time, operating system, kernel version, uptime, CPU, memory and working directory. All values are read from the system at runtime.

    ./system-info.sh

### disk-check.sh

    ./disk-check.sh <threshold> [path]

- `threshold`: integer from 1 to 100
- `path`: optional, defaults to `/`

| Exit code | Meaning |
|-----------|---------|
| 0 | Usage is below the threshold |
| 1 | Usage reached or exceeded the threshold |
| 2 | Invalid input |

### network-check.sh

    ./network-check.sh <hostname-or-ip> [port]

Validates the host, resolves it, pings it, shows network interfaces and, if a port (1-65535) is given, checks TCP connectivity.

| Exit code | Meaning |
|-----------|---------|
| 0 | All checks passed |
| 1 | Resolution, ping or port check failed |
| 2 | Invalid input |

## Logging

Every script appends timestamped entries to `logs/toolkit.log`, in the format `YYYY-MM-DD HH:MM:SS [script-name] message`. The `logs/` folder is created automatically if it is missing.

## Testing

Run the grading script:

    ./grade.sh

Manual examples:

    ./disk-check.sh 90
    ./disk-check.sh abc                  # exit code 2
    ./network-check.sh localhost
    ./network-check.sh localhost 65536   # exit code 2

## Git workflow

Development used a feature branch (`feature/disk-check`), which was merged into `main` with a merge commit.

## Assumptions

- The scripts run on Linux with the standard tools listed above.
- Ping may fail on networks that block ICMP, which the script reports as a failed check.
- A path that does not exist is treated as invalid input (exit code 2).
