#!/usr/bin/env bash
set -euo pipefail

CONFIG_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
HOST="$(hostname)"
UPDATE=false
BUILD_ONLY=false
usage() {
  echo "Usage: rebuild [-u|-U] [-b] [-n]"
  echo "  -u  explicitly update flake inputs"
  echo "  -U  preserve pins (default)"
  echo "  -b  validate and build without activation"
  echo "  -n  accepted for compatibility; commits are always manual"
}
while getopts ':uUbn' opt; do
  case "$opt" in
    u) UPDATE=true ;;
    U) UPDATE=false ;;
    b) BUILD_ONLY=true ;;
    n) : ;;
    *) usage; exit 2 ;;
  esac
done
shift $((OPTIND - 1))
if (( $# )); then
  echo "Commit messages are no longer accepted. Commit reviewed changes with git commit."
  usage
  exit 2
fi
cd "$CONFIG_DIR"
if [[ "$UPDATE" == true ]]; then
  nix flake update
fi
nix flake check --no-update-lock-file
nixos-rebuild build --flake ".#$HOST" --no-update-lock-file
if [[ "$BUILD_ONLY" == true ]]; then
  echo "Build complete. No activation performed."
  exit 0
fi
sudo nixos-rebuild switch --flake ".#$HOST" --no-update-lock-file
echo "Activated $HOST. Review and commit changes separately."
