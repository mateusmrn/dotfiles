# dotfiles

Personal configuration files for an Arch Linux desktop environment, managed as a plain git
repo in `~/dotfiles` and symlinked out to `~/.config` (and a few system paths under `/etc`).
There is no stow/chezmoi-style tooling — symlinks are created manually, see README.md's setup
list (note: that list is a point-in-time setup log and can drift out of date; prefer the actual
config files and git history over it for current state).

## Desktop environment

Hyprland (Wayland compositor) is the primary environment, not KDE/SDDM despite the leftover
`kde/kglobalshortcutsrc` file:
- `hypr/` — Hyprland config (`hyprland.lua`, using a Lua config framework rather than the
  stock `hyprland.conf`), `hyprpaper.conf` for wallpaper, and helper `scripts/`.
- `quickshell/` — QML panel/bar built on Quickshell: workspaces, volume, network, bluetooth,
  Spotify, system usage widgets, a dock, and popups for each module.
- `rofi/` — app launcher (`SUPER+SPACE`) config/theme.
- `greetd/` — login manager config (tuigreet), replacing a prior SDDM setup.
- `alacritty/` — terminal emulator config (default terminal, `SUPER+Return`).
- Terminal/launcher/file-manager choices and keybindings live in `hyprland.lua`.

## Shell and CLI tooling

- `fish/` — shell config (`config.fish`) and custom functions (`dot.fish`, `fsp.fish`,
  `spl.fish`, `ucel.fish`).
- `tmux/` — `.tmux.conf`, uses TPM for plugins.
- `mise/` — per-tool version manager config (e.g. Node, Maven).
- `nvim/` — Neovim config based on NvChad (`lua/nvchad`, `lua/plugins`, `lua/configs`,
  `lua/themes`), LSP/treesitter setup lives here.
- `code/` — VS Code `settings.json`, `keybindings.json`, and an extension list
  (`extensions.txt`, kept in sync by the `ucel` fish function via cron).

## System-level config

- `pacman/` — `pacman.conf` plus a hook (`hooks/save_package_list.hook`) that keeps
  `packages/official.txt` and `packages/aur.txt` up to date on every package operation.
- `packages/` — generated package lists (official repos + AUR) used to reprovision a machine.
- `cron/` — `base_crontab` installed via `crontab`, currently runs the VS Code extension sync
  (`ucel`) and a disk space cleanup (`fsp`) daily.

## Conventions

- Commits with messages like `[YYYY-MM-DD_HH:MM] updating packages list` are automated, made
  by the pacman hook — not manual work.
- Never append `Co-Authored-By` trailers to commit messages (see `.claude/CLAUDE.md`).
