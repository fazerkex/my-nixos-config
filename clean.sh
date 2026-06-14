#!/usr/bin/env bash
set -euo pipefail

# How many days of generations to keep.
# Default: 14 days
KEEP_DAYS="${1:-14}"

# Validate input
if ! [[ "$KEEP_DAYS" =~ ^[0-9]+$ ]]; then
  echo "Usage: clean [days-to-keep]"
  echo "Example: clean 14"
  exit 1
fi

# System generation cleanup and garbage collection need root.
if [[ "$EUID" -ne 0 ]]; then
  echo "Please run with sudo: sudo clean ${KEEP_DAYS}"
  exit 1
fi

# Figure out which user owns the Home Manager profile.
# SUDO_USER is preferred when running with sudo.
USER_NAME="${SUDO_USER:-$(logname 2>/dev/null || true)}"

if [[ -z "${USER_NAME}" ]]; then
  echo "Could not determine target user for Home Manager cleanup."
  exit 1
fi

HM_PROFILE="/nix/var/nix/profiles/per-user/${USER_NAME}/home-manager"
SYSTEM_PROFILE="/nix/var/nix/profiles/system"

# Helper: run commands as the real user, not root.
run_as_user() {
  sudo -u "$USER_NAME" -- "$@"
}

echo "==> Cleaning old NixOS generations older than ${KEEP_DAYS} days"
# Delete old system generations so they stop pinning store paths.
if [[ -e "$SYSTEM_PROFILE" ]]; then
  nix-env --delete-generations --profile "$SYSTEM_PROFILE" "${KEEP_DAYS}d"
fi

echo "==> Cleaning old user profile generations older than ${KEEP_DAYS} days"
# Delete old generations from the user's main profile.
run_as_user nix-env --delete-generations "${KEEP_DAYS}d" || true

echo "==> Cleaning old Home Manager generations older than ${KEEP_DAYS} days"
# Expire old Home Manager generations if Home Manager is in use.
if [[ -e "$HM_PROFILE" ]]; then
  run_as_user home-manager expire-generations "-${KEEP_DAYS} days" || true
fi

echo "==> Running garbage collection"
# Remove store paths no longer referenced by any remaining generation or GC root.
nix-collect-garbage -d

echo "==> Optimising store (deduplicate identical files)"
# Hard-link identical files in /nix/store to save disk space.
nix-store --optimise

echo "==> Current store usage"
du -sh /nix/store

echo
echo "Done."
echo "Reboot once if you want old boot entries fully reflected in the boot menu."