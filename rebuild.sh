#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

# Automatically detect the hostname to use as the flake target
HOST=$(hostname)

# Define usage
usage() {
    echo "Usage: ./rebuild.sh [-u] <commit_message>"
    echo "  -u    Run 'nix flake update' before rebuilding"
    exit 1
}

UPDATE=false
while getopts "u" opt; do
  case $opt in
    u) UPDATE=true ;;
    *) usage ;;
  esac
done
shift $((OPTIND-1))

# Get the commit message
COMMIT_MSG="$*"
if [ -z "$COMMIT_MSG" ]; then
    echo "Error: Please provide a commit message."
    usage
fi

echo "--- Rebuilding for $HOST ---"

# Step 1: Update flake if requested
if [ "$UPDATE" = true ]; then
    echo "--- Updating flake inputs ---"
    nix flake update
fi

# Step 2: Git lifecycle
git add .
git commit -m "$COMMIT_MSG"

# Step 3: Rebuild
sudo nixos-rebuild switch --flake ".#$HOST"

echo "--- Build complete for $HOST ---"