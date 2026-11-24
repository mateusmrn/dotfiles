{ pkgs, lib, ... }:
let
  # Store path of the shared wallpaper, as a string rather than a Nix path:
  # hyprpaper's settings are rendered by toHyprconf, whose scalar leaves go
  # through generators.mkValueStringDefault, which aborts on a path value.
  # hyprlock.conf gets the same string substituted into it below.
  wallpaper = "${../wallpapers/a_ship_in_the_water.jpg}";
in
{
  home.pointerCursor = {
    enable = true;
    package = pkgs.adwaita-icon-theme;
    name = "Adwaita";
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  home.packages = [
    pkgs.grim
    pkgs.slurp
    pkgs.swappy
    pkgs.swayimg
    pkgs.wf-recorder
    pkgs.wl-clipboard
    pkgs.kdePackages.dolphin
    pkgs.kdePackages.okular
    pkgs.obsidian
    pkgs.quickshell

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
          extension = "zip";
          stripRoot = false;
          hash = "sha256-1W44qplSN9DWgfYmx+Ac468ybwhf1Hk7q1ozeKRvTMo=";
        };
      }))
    ])
  ];

  xdg.configFile."hypr/hyprland.lua".source = ../hypr/hyprland.lua;
  xdg.configFile."hypr/scripts".source = ../hypr/scripts;
  xdg.configFile."quickshell".source = ../quickshell;

  programs.alacritty = {
    enable = true;
    settings = {
      font = {
        size = 16;
        bold.family = "Anthrosevka Mono";
        bold_italic = {
          family = "Anthrosevka Mono";
          style = "Italic";
        };
        italic = {
          family = "Anthrosevka Mono";
          style = "Italic";
        };
        normal.family = "Anthrosevka Mono";
        offset.y = 5;
      };

      window = {
        opacity = 0.88;
        padding = {
          x = 8;
          y = 8;
        };
      };

      colors = {
        primary = {
          background = "#11293c";
          foreground = "#eaf4fa";
        };
        cursor = {
          text = "#11293c";
          cursor = "#19b6ee";
        };
        normal = {
          black = "#0a1f2e";
          red = "#ff5a5f";
          green = "#4ddba0";
          yellow = "#ffd23f";
          blue = "#0098e3";
          magenta = "#b983e0";
          cyan = "#19b6ee";
          white = "#6f93a8";
        };
        bright = {
          black = "#16324a";
          red = "#ff7b7f";
          green = "#6de8bc";
          yellow = "#ffdc6b";
          blue = "#5ec1eb";
          magenta = "#d1a6ec";
          cyan = "#5ec1eb";
          white = "#eaf4fa";
        };
      };
    };
  };

  programs.hyprlock = {
    enable = true;
    # hyprlock.conf is read in verbatim and can't interpolate anything itself,
    # so it carries an @wallpaper@ placeholder that's filled in here. Without
    # this it pointed at ~/Pictures/wallpapers, which doesn't exist on a fresh
    # install -- the lock screen just came up with no background.
    extraConfig = builtins.replaceStrings [ "@wallpaper@" ] [ wallpaper ] (
      builtins.readFile ../hypr/hyprlock.conf
    );
  };

  programs.rofi = {
    enable = true;
    settings = {
      modi = "drun,run";
      show-icons = true;
      font = "Anthrosevka Mono 12";
    };
    theme = ../rofi/theme.rasi;
  };

  services.hyprpaper = {
    enable = true;
    settings = {
      splash = false;
      wallpaper = {
        monitor = "";
        path = wallpaper;
        fit_mode = "cover";
      };
    };
  };

  # hyprland.lua already execs hyprpaper itself on "hyprland.start"; prevent the
  # module's own systemd user service from also autostarting it.
  systemd.user.services.hyprpaper.Install.WantedBy = lib.mkForce [ ];

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
          default_area = "navbar";
        };
        "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/file/4717567/vimium_ff-2.4.2.xpi";
          installation_mode = "force_installed";
          updates_disabled = true;
          default_area = "navbar";
        };
        "adguardadblocker@adguard.com" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/file/5229923/adguard_adblocker-5.5.4.55.xpi";
          installation_mode = "force_installed";
          updates_disabled = true;
          default_area = "navbar";
        };
        "{d634138d-c276-4fc8-924b-40a0ea21d284}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/file/5266358/1password_x_password_manager-8.12.46.29.xpi";
          installation_mode = "force_installed";
          updates_disabled = true;
          default_area = "navbar";
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
}
