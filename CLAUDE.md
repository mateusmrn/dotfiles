# dotfiles

Personal configuration for a NixOS + Hyprland desktop, declared as a single Nix flake under
`nix/` and installed by a guided script (`install.sh`). The repo lives at `~/dotfiles`;
`install.sh` symlinks `/etc/nixos` → `~/dotfiles/nix`, so `nixos-rebuild switch` picks it up.
User-level config is home-manager, split in two modules. README.md is the user-facing install
doc — keep it in sync when the module split or the repo layout changes.

Nothing is symlinked by hand anymore: a config file matters only if some module under `nix/`
points at it. Editing a file nothing references changes nothing.

## The flake

- `nix/flake.nix` — inputs (nixpkgs `nixos-26.05`, disko, home-manager) and two outputs:
  `nixosConfigurations.nixos` (the full machine; `install.sh` renames the attr to the host) and
  `homeConfigurations.mateus` (standalone home-manager importing only `home.nix`, for non-NixOS
  machines). The inline system module holds boot/locale/networking, pipewire, fonts (including
  an Anthrosevka Mono derivation fetched from GitHub), greetd + tuigreet, bluetooth/Qt, docker,
  system packages, and the `mateus` user (fish as login shell).
- `nix/disko.nix` — disk layout (GPT, 512M ESP + ext4 root, `/dev/vda` by default). Applying it
  **destroys** the target disk.
- `nix/home.nix` — portable user config: git, `gh`, fish (`l` theme), tmux, zoxide, mise,
  Neovim.
- `nix/home-desktop.nix` — desktop-only: Hyprland/Quickshell config files, Alacritty, rofi,
  hyprlock, hyprpaper, Firefox (policies, forced extensions, bookmarks), Anki (with add-ons
  built from source), Obsidian, cursor theme, screenshot/clipboard tooling.
- `nix/hardware-configuration.nix` and `nix/flake.lock` are per-machine and generated at
  install time, not tracked on this branch; `install.sh` can commit them to a per-host
  backup branch.

Flake evaluation only sees git-tracked content, which is why `install.sh` runs `git add -A`
before `nixos-install`. A brand-new file won't be picked up until it's at least staged.

## Config files the modules point at

- `hypr/` — `hyprland.lua` (Hyprland's Lua config and its `hl` API, not the stock
  `hyprland.conf`) plus helper `scripts/`; terminal, launcher, file manager and keybindings are
  all defined there. `hyprlock.conf` is read in as `extraConfig`.
- `quickshell/` — QML shell/bar: workspaces, volume, network, bluetooth, Spotify, system usage,
  stopwatch, dock, and a popup per module.
- `fish/` — `config.fish` is inlined as `shellInit`; `fish/functions/` is symlinked as-is.
- `tmux/.tmux.conf` — read in as `extraConfig`; plugins come from `pkgs.tmuxPlugins`, not TPM.
- `nvim/` — NvChad-based config, whole directory symlinked.
- `rofi/theme.rasi` — the rofi theme (its settings are declared in Nix).
- `wallpapers/` — referenced as a Nix path from `services.hyprpaper.settings`, so it's copied
  into the store rather than needing to exist elsewhere on disk.

## Arch-era leftovers

`greetd/`, `hypr/hyprpaper.conf`, `rofi/config.rasi`, and `fish/functions/{fsp,spl}.fish` were
removed once superseded by their Nix equivalents (`services.greetd`/`services.hyprpaper` in
`flake.nix`/`home-desktop.nix`, inline rofi settings) or found calling `pacman`/`yay` and writing
the deleted `packages/` lists.

Still kept, deliberately, wired to nothing in the flake:

- `code/` — VS Code settings, keybindings and `extensions.txt`. No module reads it (VS Code
  isn't installed by the flake either); kept while still deciding what to do with it.
- `fish/functions/ucel.fish` — maintains `code/extensions.txt` via `code --list-extensions`.
  Kept alongside `code/` for the same reason. Doesn't call `pacman`/`yay`, so unlike `fsp`/`spl`
  it'd still work as-is if `code` were ever installed.

## Branches

- `nixos-migration` (current) — the NixOS rewrite; the only branch this file describes.
- `desktop` — the Arch + Hyprland machine this grew out of; the nix work branched off it and it
  now only receives automated `[YYYY-MM-DD_HH:MM] updating packages list` commits from the old
  pacman hook.
- `main` — a much older Arch + i3/polybar state, diverged since Aug 2025.
- Per-host branches created by `install.sh` carry that machine's generated nix files.

## Conventions

- Never append `Co-Authored-By` trailers to commit messages (see `.claude/CLAUDE.md`).
- `[YYYY-MM-DD_HH:MM] updating packages list` commits are automated, not manual work.
