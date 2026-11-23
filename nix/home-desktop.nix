{
  xdg.configFile."hypr/hyprland.lua".source = ../hypr/hyprland.lua;
  xdg.configFile."hypr/scripts".source = ../hypr/scripts;

  programs.hyprlock = {
    enable = true;
    extraConfig = builtins.readFile ../hypr/hyprlock.conf;
  };

  services.hyprpaper = {
    enable = true;
    settings = {
      splash = false;
      wallpaper = {
        monitor = "";
        path = "/home/mateus/Pictures/wallpapers/a_ship_in_the_water.jpg";
        fit_mode = "cover";
      };
    };
  };

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
}
