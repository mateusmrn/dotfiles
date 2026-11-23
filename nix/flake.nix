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

              programs.firefox = {
                enable = true;
                languagePacks = [
                  "en-US"
                  "pt-BR"
                ];
                policies = {
                  ExtensionSettings = {
                    "trix@highlight" = {
                      install_url = "https://addons.mozilla.org/firefox/downloads/file/3972149/highlight_by_trix-4.0.3.xpi";
                      installation_mode = "force_installed";
                      updates_disabled = true;
                    };
                    "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = {
                      install_url = "https://addons.mozilla.org/firefox/downloads/file/4717567/vimium_ff-2.4.2.xpi";
                      installation_mode = "force_installed";
                      updates_disabled = true;
                    };
                    "adguardadblocker@adguard.com" = {
                      install_url = "https://addons.mozilla.org/firefox/downloads/file/5229923/adguard_adblocker-5.5.4.55.xpi";
                      installation_mode = "force_installed";
                      updates_disabled = true;
                    };
                    "{d634138d-c276-4fc8-924b-40a0ea21d284}" = {
                      install_url = "https://addons.mozilla.org/firefox/downloads/file/5266358/1password_x_password_manager-8.12.46.29.xpi";
                      installation_mode = "force_installed";
                      updates_disabled = true;
                    };
                  };

                  Bookmarks = [
                    {
                      Title = "Awesome Wallpapers - wallhaven.cc";
                      URL = "https://wallhaven.cc/";
                      Placement = "toolbar";
                      Folder = "Wallpapers";
                    }
                    {
                      Title = "Access to Thousands of Awesome Free HD Wallpapers";
                      URL = "https://wallpaperaccess.com/";
                      Placement = "toolbar";
                      Folder = "Wallpapers";
                    }
                    {
                      Title = "Wallpaper Cave";
                      URL = "https://wallpapercave.com/";
                      Placement = "toolbar";
                      Folder = "Wallpapers";
                    }
                    {
                      Title = "Derek Taylor / Wallpapers · GitLab";
                      URL = "https://gitlab.com/dwt1/wallpapers";
                      Placement = "toolbar";
                      Folder = "Wallpapers";
                    }
                    {
                      Title = "lewdpatriot's Favorites - wallhaven.cc";
                      URL = "https://wallhaven.cc/user/lewdpatriot/favorites/935888?page=2";
                      Placement = "toolbar";
                      Folder = "Wallpapers";
                    }
                    {
                      Title = "dharmx/walls: All of my wallpapers in one repo.";
                      URL = "https://github.com/dharmx/walls/tree/main";
                      Placement = "toolbar";
                      Folder = "Wallpapers";
                    }
                    {
                      Title = "Wallpaper Abyss - The Best Cool HD Wallpapers And Backgrounds";
                      URL = "https://wall.alphacoders.com/#google_vignette";
                      Placement = "toolbar";
                      Folder = "Wallpapers";
                    }
                    {
                      Title = "BitterSweetcandyshop/wallpapers: r/unixporn's wallpaper channel plus personal db, 1080p+ abt 2gb";
                      URL = "https://github.com/BitterSweetcandyshop/wallpapers";
                      Placement = "toolbar";
                      Folder = "Wallpapers";
                    }
                    {
                      Title = "Wallpaperflare - awesome HD wallpapers free download";
                      URL = "https://www.wallpaperflare.com/";
                      Placement = "toolbar";
                      Folder = "Wallpapers";
                    }
                  ];
                };
              };

              environment.systemPackages = [
                pkgs.kdePackages.bluedevil
                pkgs.kdePackages.kcmutils
                pkgs.docker-compose
                pkgs.tuigreet
                pkgs.git
              ];

              users.users.mateus = {
                isNormalUser = true;
                extraGroups = [
                  "wheel"
                  "docker"
                ];
                home = "/home/mateus";
                shell = pkgs.fish;
                packages = [
                  pkgs.kdePackages.dolphin

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
