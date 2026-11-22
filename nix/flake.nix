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
            home-manager.users.mateus = import ./home.nix;
          }

          (
            { pkgs, ... }:
            {
              nix.settings.experimental-features = [
                "nix-command"
                "flakes"
              ];

              networking.hostName = "nixos";

              boot.loader.systemd-boot.enable = true;
              boot.loader.efi.canTouchEfiVariables = true;

              time.timeZone = "America/Fortaleza";
              i18n.defaultLocale = "en_GB.UTF-8";

              programs.fish.enable = true;

              environment.systemPackages = [
                (pkgs.anki.withAddons [
                  pkgs.ankiAddons.anki-connect
                  (pkgs.anki-utils.buildAnkiAddon (finalAttrs: {
                    pname = "advanced-review-bottombar";
                    version = "3.6.1";
                    src = pkgs.fetchFromGitHub {
                      owner = "noobj2";
                      repo = "Anki-Advanced-Review-Bottombar";
                      tag = "v${finalAttrs.version}";
                      hash = "sha256-ah51DWf1DbULF580hMj360R5qPh3fHnYM6KGBtJrgh8=";
                    };
                  }))
                  (pkgs.anki-utils.buildAnkiAddon (finalAttrs: {
                    pname = "ace";
                    version = "0.1.2";
                    src = pkgs.fetchzip {
                      url = "https://github.com/mateusmrn/ace/releases/download/v${finalAttrs.version}/ace-${finalAttrs.version}.ankiaddon";
                      hash = "sha256-1W44qplSN9DWgfYmx+Ac468ybwhf1Hk7q1ozeKRvTMo=";
                    };
                  }))
                ])
              ];

              users.users.mateus = {
                isNormalUser = true;
                extraGroups = [ "wheel" ];
                home = "/home/mateus";
                shell = pkgs.fish;
                packages = [ ];
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
