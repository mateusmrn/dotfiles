{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, disko, ... }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hardware-configuration.nix
        disko.nixosModules.disko
        ./disko.nix

        {
          nix.settings.experimental-features = [ "nix-command" "flakes" ];

          networking.hostName = "nixos";

          boot.loader.systemd-boot.enable = true;
          boot.loader.efi.canTouchEfiVariables = true;

          users.users.mateus = {
            isNormalUser = true;
            extraGroups = [ "wheel" ];
          };

          system.stateVersion = "26.05";
        }
      ];
    };
  };
}
