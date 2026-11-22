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
    userName = "mateusmrn";
    userEmail = "mateusmelornrn@gmail.com";
  };

  programs.fish = {
    enable = true;
    shellInit = builtins.readFile ../fish/config.fish;
  };

  programs.tmux = {
    enable = true;
    extraConfig = builtins.readFile ../tmux/.tmux.conf;
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.mise = {
    enable = true;
    enableFishIntegration = true;
    globalConfig = {
      tools = {
        maven = "latest";
        node = "22";
      };
      settings = {
        idiomatic_version_file_enable_tools = [ "node" ];
      };
    };
  };

  programs.alacritty = {
    enable = true;
    settings = {
      font = {
        size = 16;
        bold.family = "Anthropic Mono Web";
        bold_italic = {
          family = "Anthropic Mono Web";
          style = "Italic";
        };
        italic = {
          family = "Anthropic Mono Web";
          style = "Italic";
        };
        normal.family = "Anthropic Mono Web";
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
