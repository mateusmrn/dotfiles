#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

green() {
  printf '\033[0;32m%s\033[0m' "$1"
}

yellow() {
  printf '\033[0;33m%s\033[0m' "$1"
}

red() {
  printf '\033[0;31m%s\033[0m' "$1"
}

blue() {
  printf '\033[0;34m%s\033[0m' "$1"
}

bold() {
  printf '\033[1m%s\033[0m' "$1"
}

italic() {
  printf '\033[3m%s\033[0m' "$1"
}

echo "$(bold "$(blue "Welcome to Mateus' NixOS installer!")")"
echo "This script will set up your NixOS environment based on this repo's flake configuration."
echo

mapfile -t branches < <(git -C "$SCRIPT_DIR" branch -r --format='%(refname:short)' | grep -v '/HEAD$' | sed 's#^[^/]*/##')

if [ ${#branches[@]} -eq 0 ]; then
  echo "$(red "No branches found in the repository.")"
  exit 1
fi

echo "$(bold "Which branch do you want to use to set up this environment?")"
select source_branch in "${branches[@]}"; do
  if [ -n "$source_branch" ]; then
    break
  fi
  echo "$(red "Invalid choice, please try again.")"
done

echo "$(green "Selected branch:") $(bold "$source_branch")"

git -C "$SCRIPT_DIR" checkout "$source_branch"

DISKO_PATH="$SCRIPT_DIR/nix/disko.nix"

if [ ! -f "$DISKO_PATH" ]; then
  echo "$(red "No nix/disko.nix file found for branch '$source_branch'.")"
  exit 1
fi

echo "$(green "Found a disk configuration at") $(bold "nix/disko.nix")"
echo
cat "$DISKO_PATH"
echo

echo "$(bold "Do you want to use this disk configuration as is, or make changes to it?")"
select disko_choice in "Use as is" "Make changes"; do
  case "$disko_choice" in
  "Use as is")
    break
    ;;
  "Make changes")
    "${EDITOR:-nano}" "$DISKO_PATH"
    break
    ;;
  *)
    echo "$(red "Invalid choice, please try again.")"
    ;;
  esac
done

echo "$(bold "Partitioning and formatting the disk...")"
nix --extra-experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko "$DISKO_PATH"

echo "$(green "Done. Resulting disk layout:")"
lsblk -f
