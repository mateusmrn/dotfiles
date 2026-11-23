# dotfiles

My personal configuration for a NixOS + Hyprland environment, declared as a single Nix flake
(`nix/flake.nix`) and installed with a guided script (`install.sh`). Disk partitioning is handled
by [disko](https://github.com/nix-community/disko) (`nix/disko.nix`), and user-level config is
managed by [home-manager](https://github.com/nix-community/home-manager), split into:

- `nix/home.nix` — base tooling I want everywhere: git, `gh`, fish (with the `l` theme), tmux,
  zoxide, mise, Alacritty, Neovim.
- `nix/home-desktop.nix` — everything specific to this machine being a full desktop: Hyprland,
  Quickshell, rofi, hyprpaper/hyprlock, Firefox (with policies/extensions), Anki, Obsidian.

The rest of the repo (`hypr/`, `quickshell/`, `rofi/`, `greetd/`, `alacritty/`, `fish/`, `tmux/`,
`nvim/`) holds the actual config files those home-manager modules point at.

## Installing on a new machine

1. Boot the [NixOS installer image](https://nixos.org/download/) (the minimal ISO is enough —
   it ships with `git` and Nix with flakes already usable).
2. Get on the network. Wired usually just works (DHCP); for Wi-Fi, run `nmtui`.
3. Clone this repo and run the installer:
   ```
   git clone https://github.com/mateusmrn/dotfiles
   cd dotfiles
   ./install.sh
   ```
4. Follow the prompts: pick the branch to install from, confirm or edit `nix/disko.nix` (this
   **destroys** the target disk), confirm or edit the flake config, choose whether to reuse an
   existing `nix/hardware-configuration.nix`, set the user's password, and optionally set up a
   branch to back up this machine's generated files (`nix/flake.lock`,
   `nix/hardware-configuration.nix`) going forward.
5. Reboot into the new system and log in. A few things aren't (and shouldn't be) automated by
   the flake — log in interactively:
   1. `gh auth login` — git itself authenticates to GitHub over HTTPS via `gh`'s credential
      helper (see `nix/home.nix`), so nothing works until this is done.
   2. Sign into 1Password.
   3. Log into Claude Code (`claude`).

If you're testing this in a VM without real GPU acceleration (e.g. VirtualBox's software-only
3D support), pass `--hyprland-vm-fix` to force Hyprland onto a software renderer instead of
crashing on launch. Not needed with QEMU/KVM + `virtio-gpu-gl`, which gives the guest real
accelerated rendering.

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

- [ ] Automatically sync this machine's config changes back to its backup branch over time.
      Today, `install.sh` only captures a one-time snapshot of generated files
      (`flake.lock`/`hardware-configuration.nix`) at install time — everything after that is
      still a manual `git commit` + `git push`.
- [ ] Think about whether it's worth automating credential provisioning (e.g. pulling secrets
      from 1Password at install time). So far, the only real logins needed (GitHub, 1Password,
      Claude Code) are each a one-time manual step with no static secret to actually automate.
