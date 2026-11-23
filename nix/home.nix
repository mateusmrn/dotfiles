{ pkgs, ... }:
{
  home.username = "mateus";
  home.homeDirectory = "/home/mateus";
  home.stateVersion = "26.05";

  home.packages = [ pkgs.neovim ];

  programs.home-manager.enable = true;

  xdg.configFile."nvim".source = ../nvim;
  xdg.configFile."fish/functions".source = ../fish/functions;

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "mateusmrn";
        email = "mateusmelornrn@gmail.com";
      };
      push.autoSetupRemote = true;
      init.defaultBranch = "main";
      alias.nuke = "!git reset --hard HEAD && git clean -fd";
    };
  };

  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "https";
      aliases.co = "pr checkout";
    };
    hosts."github.com" = {
      git_protocol = "https";
      user = "mateusmrn";
    };
  };

  programs.fish = {
    enable = true;
    shellInit = builtins.readFile ../fish/config.fish;
    plugins = [
      {
        name = "l";
        src = pkgs.fetchFromGitHub {
          owner = "oh-my-fish";
          repo = "theme-l";
          rev = "4aadb2649fd3420e6515016f869eb79455807aaa";
          hash = "sha256-cuCZjISIsAahZ3lDFnjCcawrEOdsFXgI8+slzv2LyGc=";
        };
      }
    ];
  };

  programs.tmux = {
    enable = true;
    extraConfig = builtins.readFile ../tmux/.tmux.conf;
    plugins = with pkgs.tmuxPlugins; [
      resurrect
      continuum
      open
    ];
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.mise = {
    enable = true;
    enableFishIntegration = true;
  };

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
}
