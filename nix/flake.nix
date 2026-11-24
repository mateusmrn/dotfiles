{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }:
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          # Carries fileSystems/swapDevices too: the disk is partitioned by
          # hand and this file is generated from the live mounts at install
          # time (see install.sh / README.md).
          ./hardware-configuration.nix
          ./auto-commit.nix
          home-manager.nixosModules.home-manager

          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.mateus = {
              imports = [
                ./home.nix
                ./home-desktop.nix
              ];
            };
          }

          (
            { pkgs, config, ... }:
            {
              nixpkgs.config.allowUnfree = true;

              nix.settings.experimental-features = [
                "nix-command"
                "flakes"
              ];

              networking.hostName = "nixos";

              boot.loader.systemd-boot.enable = true;
              boot.loader.efi.canTouchEfiVariables = true;

              time.timeZone = "America/Fortaleza";
              i18n.defaultLocale = "en_GB.UTF-8";

              networking.networkmanager.enable = true;

              # GeForce RTX 3060 (Ampere/GA106) + Hyprland (Wayland).
              services.xserver.videoDrivers = [ "nvidia" ];
              hardware.nvidia = {
                package = config.boot.kernelPackages.nvidiaPackages.stable;
                # Matches nvidia-open already in use on Arch; Turing and
                # later GPUs support the open-source kernel module.
                open = true;
                # Needed for Wayland compositors (Hyprland) to work at all
                # on NVIDIA; also already the default for driver >= 535.
                modesetting.enable = true;
              };
              hardware.graphics.enable = true;
              environment.sessionVariables = {
                LIBVA_DRIVER_NAME = "nvidia";
                GBM_BACKEND = "nvidia-drm";
                __GLX_VENDOR_LIBRARY_NAME = "nvidia";
              };

              services.pipewire = {
                enable = true;
                alsa.enable = true;
                pulse.enable = true;
              };

              fonts.packages = [
                pkgs.noto-fonts-cjk-sans
                pkgs.noto-fonts-cjk-serif
                pkgs.font-awesome
                pkgs.monaspace
                pkgs.cascadia-code
                pkgs.fira-code
                pkgs.nerd-fonts.blex-mono
                pkgs.nerd-fonts.iosevka
                pkgs.nerd-fonts.jetbrains-mono
                pkgs.nerd-fonts.adwaita-mono
              ]
              ++ builtins.filter pkgs.lib.isDerivation (builtins.attrValues pkgs.tex-gyre)
              ++ [
                (pkgs.stdenvNoCC.mkDerivation {
                  pname = "anthrosevka-mono";
                  version = "0.4.0";
                  src = pkgs.fetchzip {
                    url = "https://github.com/nanxstats/anthrosevka/releases/download/v0.4.0/AnthrosevkaMono.zip";
                    stripRoot = false;
                    hash = "sha256-vMdTPFXH9D6JnTJDmMsoTgKUmsNuWAgtya+n0umW57I=";
                  };
                  installPhase = ''
                    runHook preInstall
                    install -Dm644 -t "$out/share/fonts/truetype" *.ttf
                    runHook postInstall
                  '';
                })
              ];

              programs.fish.enable = true;

              programs.hyprland.enable = true;

              hardware.bluetooth.enable = true;

              # Needed for Qt/KDE apps' QML plugins (e.g. bluedevil's Bluetooth
              # KCM) to find each other's modules outside a full Plasma
              # session: aggregates QT_PLUGIN_PATH/QML2_IMPORT_PATH across
              # everything in environment.systemPackages.
              qt.enable = true;

              services.greetd = {
                enable = true;
                settings.default_session.command = "tuigreet --time --remember --remember-session --asterisks";
              };

              systemd.services.greetd = {
                wants = [ "bluetooth.service" ];
                after = [ "bluetooth.service" ];
              };

              virtualisation.docker.enable = true;

              environment.systemPackages = [
                pkgs.kdePackages.bluedevil
                pkgs.kdePackages.kcmutils
                pkgs.kdePackages.bluez-qt
                pkgs.docker-compose
                pkgs.tuigreet
                pkgs.git
                pkgs.less
                pkgs.openssh
                pkgs._1password-gui
              ];

              users.users.mateus = {
                isNormalUser = true;
                extraGroups = [
                  "wheel"
                  "docker"
                ];
                home = "/home/mateus";
                shell = pkgs.fish;
              };

              system.stateVersion = "26.05";
            }
          )
        ];
      };

      homeConfigurations.mateus = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [ ./home.nix ];
      };
    };
}
