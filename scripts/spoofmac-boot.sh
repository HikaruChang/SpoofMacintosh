#!/bin/bash
# Powered by NyphexAI, Developed by Hikaru(i@rua.moe)
# Licensed under the PolyForm Noncommercial License 1.0.0
# Boot loader wrapper for SpoofMacintosh LaunchDaemon.
# Serializes eligibility/daemon refreshes via lockf to avoid concurrent races.

set -uo pipefail

CLI="/usr/local/bin/spoofmac"
LOCK="/var/run/spoofmacintosh-refresh.lock"
ts() { /bin/date '+%Y-%m-%d %H:%M:%S'; }

if [ "$(/usr/bin/id -u)" -ne 0 ]; then
  echo "$(ts) ERROR: must run as root" >&2
  exit 1
fi

if [ ! -x "$CLI" ]; then
  echo "$(ts) ERROR: missing $CLI" >&2
  exit 1
fi

case "${1:-}" in
  --refresh-only)
    echo "$(ts) spoofmac-boot: refresh-only start"
    /usr/bin/lockf -k -t 60 "$LOCK" "$CLI" refresh
    ;;
  '')
    echo "$(ts) spoofmac-boot: boot-load start"
    /usr/bin/lockf -k -t 60 "$LOCK" "$CLI" boot-load
    ;;
  *)
    echo "Usage: $0 [--refresh-only]" >&2
    exit 1
    ;;
esac
