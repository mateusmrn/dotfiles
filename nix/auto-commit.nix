# Auto-commit/push this machine's dotfiles repo to its backup branch after
# every `nixos-rebuild switch`. Disabled by default; install.sh's
# backup-branch step flips `enable` and fills in `branch` for this machine
# only (never committed back to the shared nixos-migration branch).
{ lib, config, pkgs, ... }:
let
  cfg = config.services.dotfilesAutoCommit;
in
{
  options.services.dotfilesAutoCommit = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Whether to automatically commit and push this machine's dotfiles
        repo (~/dotfiles) to its backup branch after every
        `nixos-rebuild switch`. Only fires on an actual switch
        (`$NIXOS_ACTION == switch`), not on plain boot, `test`, or
        `dry-activate`.
      '';
    };

    branch = lib.mkOption {
      type = lib.types.str;
      default = "nixos-desktop";
      description = "Git branch in ~/dotfiles to commit and push changes to.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.branch != "";
        message = "services.dotfilesAutoCommit.branch must be set when services.dotfilesAutoCommit.enable is true.";
      }
    ];

    system.activationScripts.dotfilesAutoCommit.text = ''
      if [ "$NIXOS_ACTION" = switch ]; then
        if ! ${pkgs.util-linux}/bin/runuser -l mateus -c '
          set -e
          cd /home/mateus/dotfiles
          ${pkgs.git}/bin/git add -A
          if ! ${pkgs.git}/bin/git diff --cached --quiet; then
            ${pkgs.git}/bin/git commit -m "Auto-commit after nixos-rebuild switch ($(date -Iseconds))"
            ${pkgs.git}/bin/git push origin HEAD:${cfg.branch}
          fi
        '; then
          echo "dotfilesAutoCommit: failed to commit/push config changes (see above)" >&2
        fi
      fi
    '';
  };
}
