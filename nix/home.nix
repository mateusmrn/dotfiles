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

  programs.claude-code = {
    enable = true;
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
}
