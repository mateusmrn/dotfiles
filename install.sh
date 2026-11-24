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

echo "$(yellow "Note: on this branch, this does NOT blindly wipe the target disk -- changed")"
echo "$(yellow "specifically for this PC's dual-boot setup. If the disk already has a partition")"
echo "$(yellow "table, only the partitions declared above are touched -- anything else on the disk")"
echo "$(yellow "(e.g. another OS) is left alone. If you actually want a clean disk and it isn't")"
echo "$(yellow "already blank, wipe it yourself first (e.g. 'sgdisk --zap-all /dev/yourdisk').")"
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
# No `destroy`: it unconditionally wipes the partition table of the whole
# disk, which would also wipe a dual-booted OS sharing that disk. `format`
# alone still initializes a genuinely blank disk correctly (disko only
# skips clearing the table when blkid finds one already there), so this
# works for both cases.
nix --extra-experimental-features "nix-command flakes" run github:nix-community/disko -- --mode format,mount "$DISKO_PATH"

echo "$(green "Done. Resulting disk layout:")"
lsblk -f

TARGET_DOTFILES_DIR="/mnt/home/$USERNAME/dotfiles"

echo "$(bold "Copying dotfiles repo to") $(italic "$TARGET_DOTFILES_DIR")"
mkdir -p "$(dirname "$TARGET_DOTFILES_DIR")"
cp -a "$SCRIPT_DIR" "$TARGET_DOTFILES_DIR"

echo "$(bold "Symlinking /etc/nixos to the dotfiles flake...")"
mkdir -p /mnt/etc
ln -sfn "../home/$USERNAME/dotfiles/nix" /mnt/etc/nixos

FLAKE_PATH="$TARGET_DOTFILES_DIR/nix/flake.nix"
FLAKE_LOCK_PATH="$TARGET_DOTFILES_DIR/nix/flake.lock"
HARDWARE_CONFIG_PATH="$TARGET_DOTFILES_DIR/nix/hardware-configuration.nix"

flake_lock_existed=false
if [ -f "$FLAKE_LOCK_PATH" ]; then
  flake_lock_existed=true
fi

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

# nixos-generate-config always writes this, but nothing in flake.nix imports
# it (the flake wires up hardware-configuration.nix and disko.nix directly),
# so it's dead weight.
rm -f "$TARGET_DOTFILES_DIR/nix/configuration.nix"

if [ "$flake_existed" = false ]; then
  sed -i "s/nixosConfigurations\.nixos/nixosConfigurations.$HOST/" "$FLAKE_PATH"
fi

echo "$(bold "Staging dotfiles repo changes so the flake build picks them up...")"
git -C "$TARGET_DOTFILES_DIR" add -A

echo "$(bold "Running nixos-install...")"
nixos-install --root /mnt --flake "$TARGET_DOTFILES_DIR/nix#$HOST"

echo "$(green "NixOS installation complete!")"

echo "$(bold "Do you want to set up a branch to back up this machine's config after future changes?")"
select backup_choice in "Yes" "No"; do
  case "$backup_choice" in
  "Yes" | "No")
    break
    ;;
  *)
    echo "$(red "Invalid choice, please try again.")"
    ;;
  esac
done

if [ "$backup_choice" = "Yes" ]; then
  while true; do
    while true; do
      read -rp "$(bold "Branch name [$HOST]: ")" backup_branch_1
      backup_branch_1="${backup_branch_1:-$HOST}"
      read -rp "$(bold "Confirm branch name: ")" backup_branch_2
      backup_branch_2="${backup_branch_2:-$HOST}"

      if [ "$backup_branch_1" = "$backup_branch_2" ]; then
        backup_branch="$backup_branch_1"
        break
      fi

      echo "$(red "Branch names did not match, please try again.")"
    done

    branch_exists=false
    if git -C "$TARGET_DOTFILES_DIR" ls-remote --exit-code --heads origin "$backup_branch" >/dev/null 2>&1; then
      branch_exists=true
    fi

    if [ "$branch_exists" = true ]; then
      echo "$(yellow "Branch '$backup_branch' already exists on the remote. It may already be in use by another machine, and syncing with it could lead to conflicts.")"
      echo "$(bold "Continue using this branch anyway?")"
      select branch_confirm in "Yes" "No, choose a different name"; do
        case "$branch_confirm" in
        "Yes")
          break
          ;;
        "No, choose a different name")
          continue 2
          ;;
        *)
          echo "$(red "Invalid choice, please try again.")"
          ;;
        esac
      done
    fi

    break
  done

  if [ "$branch_exists" = true ]; then
    git -C "$TARGET_DOTFILES_DIR" fetch origin "$backup_branch"
    git -C "$TARGET_DOTFILES_DIR" checkout "$backup_branch"
  else
    git -C "$TARGET_DOTFILES_DIR" checkout -b "$backup_branch"
  fi

  AUTO_COMMIT_PATH="$TARGET_DOTFILES_DIR/nix/auto-commit.nix"
  sed -i \
    -e 's/default = false; # Set to true by install.sh'"'"'s backup-branch step./default = true;/' \
    -e "s/default = \"\"; # Filled in by install.sh's backup-branch step./default = \"$backup_branch\";/" \
    "$AUTO_COMMIT_PATH"

  backup_paths=(nix/hardware-configuration.nix nix/auto-commit.nix)

  if [ "$flake_lock_existed" = true ]; then
    echo "$(yellow "nix/flake.lock already existed in '$source_branch'; nothing new to capture.")"
  else
    backup_paths+=(nix/flake.lock)
  fi

  git -C "$TARGET_DOTFILES_DIR" add -- "${backup_paths[@]}"

  if git -C "$TARGET_DOTFILES_DIR" diff --cached --quiet -- "${backup_paths[@]}"; then
    echo "$(yellow "No machine-specific files changed, nothing to commit.")"
  else
    git_author_name=$(nix --extra-experimental-features "nix-command flakes" eval --raw \
      "$TARGET_DOTFILES_DIR/nix#homeConfigurations.$USERNAME.config.programs.git.settings.user.name")
    git_author_email=$(nix --extra-experimental-features "nix-command flakes" eval --raw \
      "$TARGET_DOTFILES_DIR/nix#homeConfigurations.$USERNAME.config.programs.git.settings.user.email")

    git -C "$TARGET_DOTFILES_DIR" -c user.name="$git_author_name" -c user.email="$git_author_email" \
      commit -m "Record this machine's config after initial install" -- "${backup_paths[@]}"
  fi

  echo "$(green "Config backups for this machine will be saved on branch") $(bold "$backup_branch")"
  echo "$(yellow "Not pushing yet (no GitHub authentication set up at this point). It'll be pushed automatically after your next nixos-rebuild switch, or you can push it manually once you've run 'gh auth login'.")"
fi

echo "$(bold "Set a password for the '$USERNAME' user")"
while true; do
  read -rsp "$(bold "Password: ")" password_1
  echo
  read -rsp "$(bold "Confirm password: ")" password_2
  echo

  if [ -z "$password_1" ]; then
    echo "$(red "Password cannot be empty, please try again.")"
    continue
  fi

  if [ "$password_1" != "$password_2" ]; then
    echo "$(red "Passwords did not match, please try again.")"
    continue
  fi

  break
done

echo "$USERNAME:$password_1" | nixos-enter --root /mnt -c "chpasswd"

echo "$(green "Password set for user") $(bold "$USERNAME")"
echo
echo "$(bold "$(green "Installation complete!")")"
echo "Reboot the machine and log in as $(bold "$USERNAME") to start using your new NixOS system."
