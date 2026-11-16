#!/usr/bin/env bash
set -euo pipefail

# Rebuild the current host from your flake in ~/NixOS.
# Optional:
#   -u  force update flake inputs first
#   -U  skip flake input updates
#   -n  do not create a git commit before rebuilding

CONFIG_DIR="$HOME/NixOS"
HOST="$(hostname)"
# Keep inputs current by default so package versions (like codex) move forward.
AUTO_UPDATE_DEFAULT=true
UPDATE="$AUTO_UPDATE_DEFAULT"
NO_COMMIT=false

usage() {
  echo "Usage: rebuild [-u|-U] [-n] [commit message]"
  echo
  echo "Options:"
  echo "  -u    Force 'nix flake update' before rebuilding"
  echo "  -U    Skip 'nix flake update' before rebuilding"
  echo "  -n    Skip git commit (test mode)"
  echo
  echo "Examples:"
  echo "  rebuild \"tweak plasma shortcuts\""
  echo "  rebuild -U \"quick rebuild without input updates\""
  echo "  rebuild -u \"update inputs and rebuild\""
  echo "  rebuild -n"
  exit 1
}

while getopts ":unU" opt; do
  case "$opt" in
    u) UPDATE=true ;;
    U) UPDATE=false ;;
    n) NO_COMMIT=true ;;
    *) usage ;;
  esac
done
shift $((OPTIND - 1))

COMMIT_MSG="$*"

if [[ "$NO_COMMIT" == false && -z "$COMMIT_MSG" ]]; then
  echo "Error: provide a commit message, or use -n to skip commit."
  usage
fi

cd "$CONFIG_DIR"

echo "--- Rebuilding for $HOST ---"

if [[ "$UPDATE" == true ]]; then
  echo "--- Updating flake inputs ---"
  nix flake update
fi

if [[ "$NO_COMMIT" == true ]]; then
  echo "--- Skipping git commit (test mode) ---"
else
  echo "--- Committing config changes ---"
  git add .

  # Only commit if there is actually something staged.
  if git diff --cached --quiet; then
    echo "Nothing to commit."
  else
    git commit -m "$COMMIT_MSG"
  fi
fi

echo "--- Running nixos-rebuild ---"
sudo nixos-rebuild switch --flake ".#$HOST"

echo "--- Done for $HOST ---"