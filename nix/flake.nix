{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      disko,
      home-manager,
      ...
    }:
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hardware-configuration.nix
          disko.nixosModules.disko
          ./disko.nix
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
            { pkgs, lib, ... }:
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

              # Set by install.sh's --hyprland-vm-fix flag. VirtualBox's virtual GPU
              # has no real DRM/EGL support, which crashes Hyprland on launch; this
              # forces wlroots onto a software renderer instead. Only needed for the
              # VM used to test this install flow, not real hardware with a real GPU.
              environment.sessionVariables = lib.optionalAttrs (builtins.pathExists ./.hyprland-vm-fix) {
                WLR_RENDERER = "pixman";
                WLR_NO_HARDWARE_CURSORS = "1";
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
                pkgs.docker-compose
                pkgs.tuigreet
                pkgs.git
                pkgs.less
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
