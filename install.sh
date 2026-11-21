#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
USERNAME="mateus"
HOST="nixos"

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
nix --extra-experimental-features "nix-command flakes" run github:nix-community/disko -- --mode destroy,format,mount "$DISKO_PATH"

echo "$(green "Done. Resulting disk layout:")"
lsblk -f

TARGET_DOTFILES_DIR="/mnt/home/$USERNAME/dotfiles"

echo "$(bold "Copying dotfiles repo to") $(italic "$TARGET_DOTFILES_DIR")"
mkdir -p "$(dirname "$TARGET_DOTFILES_DIR")"
cp -a "$SCRIPT_DIR" "$TARGET_DOTFILES_DIR"

echo "$(bold "Symlinking /etc/nixos to the dotfiles flake...")"
mkdir -p /mnt/etc
ln -sfn "/home/$USERNAME/dotfiles/nix" /mnt/etc/nixos

FLAKE_PATH="$TARGET_DOTFILES_DIR/nix/flake.nix"
HARDWARE_CONFIG_PATH="$TARGET_DOTFILES_DIR/nix/hardware-configuration.nix"

flake_existed=false
if [ -f "$FLAKE_PATH" ]; then
  flake_existed=true
  echo "$(green "Found an existing flake config at") $(bold "nix/flake.nix")"
  echo
  cat "$FLAKE_PATH"
  echo

  echo "$(bold "Do you want to use this flake config as is, or make changes to it?")"
  select flake_choice in "Use as is" "Make changes"; do
    case "$flake_choice" in
    "Use as is")
      break
      ;;
    "Make changes")
      "${EDITOR:-nano}" "$FLAKE_PATH"
      break
      ;;
    *)
      echo "$(red "Invalid choice, please try again.")"
      ;;
    esac
  done
else
  echo "$(yellow "No existing flake config found; one will be generated automatically.")"
fi

reuse_hardware_config=false
if [ -f "$HARDWARE_CONFIG_PATH" ]; then
  echo "$(green "Found an existing hardware config at") $(bold "nix/hardware-configuration.nix")"
  echo
  cat "$HARDWARE_CONFIG_PATH"
  echo

  echo "$(bold "Do you want to reuse this hardware configuration?")"
  select hardware_choice in "Yes" "No"; do
    case "$hardware_choice" in
    "Yes")
      reuse_hardware_config=true
      break
      ;;
    "No")
      rm "$HARDWARE_CONFIG_PATH"
      break
      ;;
    *)
      echo "$(red "Invalid choice, please try again.")"
      ;;
    esac
  done
else
  echo "$(yellow "No existing hardware config found; one will be generated automatically.")"
fi

if [ "$reuse_hardware_config" = true ]; then
  cp "$HARDWARE_CONFIG_PATH" "$HARDWARE_CONFIG_PATH.bak"
fi

echo "$(bold "Generating NixOS flake configuration...")"
nixos-generate-config --flake --no-filesystems --root /mnt

if [ "$reuse_hardware_config" = true ]; then
  mv "$HARDWARE_CONFIG_PATH.bak" "$HARDWARE_CONFIG_PATH"
fi

if [ "$flake_existed" = false ]; then
  sed -i "s/nixosConfigurations\.nixos/nixosConfigurations.$HOST/" "$FLAKE_PATH"
fi

echo "$(bold "Staging dotfiles repo changes so the flake build picks them up...")"
git -C "$TARGET_DOTFILES_DIR" add -A

echo "$(bold "Running nixos-install...")"
nixos-install --root /mnt --flake "$TARGET_DOTFILES_DIR/nix#$HOST"

echo "$(green "NixOS installation complete!")"
