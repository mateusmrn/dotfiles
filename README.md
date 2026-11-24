# dotfiles

My personal configuration for a NixOS + Hyprland environment, declared as a single Nix flake
(`nix/flake.nix`) and installed with a guided script (`install.sh`). Disk partitioning is **not**
automated — you partition, format and mount the target yourself, and `install.sh` installs onto
whatever is mounted at `/mnt`. User-level config is managed by
[home-manager](https://github.com/nix-community/home-manager), split into:

- `nix/home.nix` — base tooling I want everywhere: git, `gh`, fish (with the `l` theme), tmux,
  zoxide, mise, Neovim.
- `nix/home-desktop.nix` — everything specific to this machine being a full desktop: Hyprland,
  Quickshell, rofi, hyprpaper/hyprlock, Alacritty, Firefox (with policies/extensions), Anki,
  Obsidian.

The rest of the repo (`hypr/`, `quickshell/`, `rofi/`, `fish/`, `tmux/`, `nvim/`, `wallpapers/`)
holds the actual config files those home-manager modules point at.

## Installing on a new machine

1. Boot the [NixOS installer image](https://nixos.org/download/) (the minimal ISO is enough —
   it ships with `git` and Nix with flakes already usable).
2. Get on the network. Wired usually just works (DHCP); for Wi-Fi, run `nmtui`.
3. Clone this repo and **check out the branch you want to install from**. `install.sh` installs
   whatever branch is currently checked out and never switches branches itself, so this step is
   on you:
   ```
   git clone https://github.com/mateusmrn/dotfiles
   cd dotfiles
   git checkout nixos-desktop   # or whichever branch describes this machine
   ```
4. **Partition, format and mount the disk yourself.** `install.sh` never touches the partition
   table — it installs onto whatever is already mounted under `/mnt`, and
   `nix/hardware-configuration.nix` is generated from those live mounts. At minimum you need:
   - an ESP (FAT32, type EF00) mounted at `/mnt/boot` — the flake boots with systemd-boot;
   - a root filesystem mounted at `/mnt`;
   - optionally swap, `swapon`'d before running the script so it lands in `swapDevices`.

   Mount the ESP *after* the root filesystem, so `/mnt/boot` ends up inside it. The installer
   refuses to run if either `/mnt` or `/mnt/boot` is not a mountpoint, prints what it found, and
   asks you to confirm the layout before writing anything. Doing this by hand is deliberate: it
   keeps the installer from being able to wipe a partition table it shouldn't, which matters on
   a machine that dual-boots another OS off the same disk.
5. Run the installer:
   ```
   ./install.sh
   ```
6. Follow the prompts: confirm the detected mounts, confirm or edit the flake config, choose
   whether to reuse an existing `nix/hardware-configuration.nix`, set the user's password, and
   optionally set up a branch to back up this machine's config to. If you do, every future
   `nixos-rebuild switch` automatically commits and pushes any changes to that branch
   (`services.dotfilesAutoCommit`, `nix/auto-commit.nix`) — not just the one-time
   `nix/flake.lock`/`hardware-configuration.nix` snapshot captured at install time.

   Only reuse an existing `hardware-configuration.nix` if its filesystem UUIDs match the disk
   you just partitioned — it now carries the `fileSystems`/`swapDevices` entries, so a stale one
   produces a system that won't boot.
7. Reboot into the new system and log in. A few things aren't (and shouldn't be) automated by
   the flake — log in interactively:
   1. Sign into 1Password.
   2. `gh auth login` — git itself authenticates to GitHub over HTTPS via `gh`'s credential
      helper (see `nix/home.nix`), so nothing works until this is done.
   3. Log into Claude Code (`claude`).

## Using just `home.nix` elsewhere

For a non-NixOS machine (e.g. a work laptop) where I only want the base tooling — not the
Hyprland desktop — the flake exposes a standalone home-manager configuration that imports only
`home.nix`:

```nix
homeConfigurations.mateus = home-manager.lib.homeManagerConfiguration {
  pkgs = nixpkgs.legacyPackages.x86_64-linux;
  modules = [ ./home.nix ];
};
```

With [Nix](https://nixos.org/download/) installed (flakes enabled), apply it with:

```
nix run github:nix-community/home-manager -- switch --flake github:mateusmrn/dotfiles?dir=nix#mateus
```

or, from a local clone:

```
nix run github:nix-community/home-manager -- switch --flake ./nix#mateus
```

## TODO

- [ ] Think about whether it's worth automating credential provisioning (e.g. pulling secrets
      from 1Password at install time). So far, the only real logins needed (GitHub, 1Password,
      Claude Code) are each a one-time manual step with no static secret to actually automate.
