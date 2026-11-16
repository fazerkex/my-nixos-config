#!/usr/bin/env bash
set -euo pipefail

KEEP_DAYS="${1:-14}"
if [[ "$KEEP_DAYS" == "--dry-run" ]]; then
  KEEP_DAYS="${2:-14}"
  if ! [[ "$KEEP_DAYS" =~ ^[1-9][0-9]*$ ]]; then
    echo "Retention must be a positive number of days." >&2
    exit 2
  fi
  echo "Plan: expire system/user generations older than ${KEEP_DAYS} days, then collect unreachable paths."
  echo "Current system generations (no changes made):"
  nix-env --list-generations --profile /nix/var/nix/profiles/system
  exit 0
fi
if (( $# > 1 )) || ! [[ "$KEEP_DAYS" =~ ^[1-9][0-9]*$ ]]; then
  echo "Usage: clean [days-to-keep] | clean --dry-run [days-to-keep]" >&2
  exit 2
fi
if [[ "$EUID" -ne 0 ]]; then
  exec sudo "$0" "$KEEP_DAYS"
fi
USER_NAME="${SUDO_USER:-$(logname 2>/dev/null || true)}"
if [[ -z "$USER_NAME" || "$USER_NAME" == root ]]; then
  echo "Run through sudo from your normal user account." >&2
  exit 2
fi
nix-env --delete-generations --profile /nix/var/nix/profiles/system "${KEEP_DAYS}d"
sudo -u "$USER_NAME" -- nix-env --delete-generations "${KEEP_DAYS}d"
# Home Manager is integrated into NixOS: its generations follow the system.
# Do not use -d here: it would delete generations newer than the cutoff.
nix-collect-garbage
nix-store --optimise
echo "Cleanup complete; retained generations remain available for rollback."
