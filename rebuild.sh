#!/usr/bin/env bash
set -e

CONFIG_DIR="$HOME/NixOS"
cd "$CONFIG_DIR"

HOST=$(hostname)
UPDATE=false
NO_COMMIT=false

usage() {
    echo "Usage: rebuild [-u] [-n] <commit_message>"
    echo "  -u    Run 'nix flake update' before rebuilding"
    echo "  -n    No commit (test mode: rebuild only)"
    exit 1
}

# Parse flags
while getopts "un" opt; do
  case $opt in
    u) UPDATE=true ;;
    n) NO_COMMIT=true ;;
    *) usage ;;
  esac
done
shift $((OPTIND-1))

# Handle commit message requirement
COMMIT_MSG="$*"
if [ "$NO_COMMIT" = false ] && [ -z "$COMMIT_MSG" ]; then
    echo "Error: Please provide a commit message (or use -n to skip commit)."
    usage
fi

echo "--- Rebuilding for $HOST ---"

if [ "$UPDATE" = true ]; then
    echo "--- Updating flake inputs ---"
    nix flake update
fi

if [ "$NO_COMMIT" = true ]; then
    echo "--- Skipping git commit (Test Mode) ---"
else
    git add .
    git commit -m "$COMMIT_MSG"
fi

sudo nixos-rebuild switch --flake ".#$HOST"

echo "--- Build complete for $HOST ---"