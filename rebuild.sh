#!/usr/bin/env bash
set -euo pipefail

CONFIG_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
HOST="$(hostname)"
UPDATE=false
BUILD_ONLY=false
COMMIT_MESSAGE=""
PUSH=false
NO_COMMIT=false
usage() {
  echo "Usage: rebuild [-u|-U] [-b] [-n | -c message [-p]]"
  echo "  -u  explicitly update flake inputs"
  echo "  -U  preserve pins (default)"
  echo "  -b  validate and build without activation"
  echo "  -c  commit pre-staged changes after checks/build succeed"
  echo "  -p  push after successful build/activation (requires -c)"
  echo "  -n  do not commit (default)"
}
while getopts ':uUbnc:p' opt; do
  case "$opt" in
    u) UPDATE=true ;;
    U) UPDATE=false ;;
    b) BUILD_ONLY=true ;;
    n) NO_COMMIT=true ;;
    c) COMMIT_MESSAGE="$OPTARG" ;;
    p) PUSH=true ;;
    *) usage; exit 2 ;;
  esac
done
shift $((OPTIND - 1))
if (( $# )); then
  echo "Use -c followed by a commit message; stage reviewed changes first."
  usage
  exit 2
fi
if [[ "$PUSH" == true && -z "$COMMIT_MESSAGE" ]] ||
   [[ -n "$COMMIT_MESSAGE" && ( "$UPDATE" == true || "$NO_COMMIT" == true ) ]]; then
  echo "-p requires -c; -c cannot be combined with -u or -n." >&2
  exit 2
fi
cd "$CONFIG_DIR"
if [[ -n "$COMMIT_MESSAGE" ]]; then
  # Build exactly the reviewed index, without accidentally including other edits.
  if ! git diff --quiet || [[ -n "$(git ls-files --others --exclude-standard)" ]]; then
    echo "Stage reviewed changes first; -c rejects unstaged/untracked changes." >&2
    exit 2
  fi
  INDEX_TREE="$(git write-tree)"
  if git diff --cached --quiet; then
    echo "No staged changes to commit." >&2
    exit 2
  fi
fi
if [[ "$UPDATE" == true ]]; then
  nix flake update
fi
nix flake check --no-update-lock-file
nixos-rebuild build --flake ".#$HOST" --no-update-lock-file
if [[ -n "$COMMIT_MESSAGE" ]]; then
  # Recheck after the build so concurrent edits cannot slip into the commit.
  if [[ "$(git write-tree)" != "$INDEX_TREE" ]]; then
    echo "Staged changes changed during the build; refusing commit/push." >&2
    exit 2
  fi
  if ! git diff --quiet || [[ -n "$(git ls-files --others --exclude-standard)" ]]; then
    echo "Files changed during the build; refusing commit/push." >&2
    exit 2
  fi
  git commit -m "$COMMIT_MESSAGE"
fi
if [[ "$BUILD_ONLY" == true ]]; then
  if [[ "$PUSH" == true ]]; then git push; fi
  echo "Build complete. No activation performed."
  exit 0
fi
sudo nixos-rebuild switch --flake ".#$HOST" --no-update-lock-file
if [[ "$PUSH" == true ]]; then git push; fi
echo "Activated $HOST."
