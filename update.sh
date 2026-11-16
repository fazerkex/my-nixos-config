#!/usr/bin/env bash
set -euo pipefail

# Always refresh flake inputs, then run the normal rebuild flow.
exec "$HOME/NixOS/rebuild.sh" -u "$@"
