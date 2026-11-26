{ pkgs, ... }:
{
  home.username = "mateus";
  home.homeDirectory = "/home/mateus";
  home.stateVersion = "26.05";

  home.packages = [
    # Also on the shell PATH (not just nvim's, below): this repo is
    # nixfmt-formatted and there is otherwise no way to format a .nix file
    # outside the editor.
    pkgs.nixfmt
  ];

  # Neovim's formatter binaries live in extraPackages rather than
  # home.packages: it wraps nvim with them on PATH, so conform.nvim's
  # subprocesses find them without the whole set leaking into the shell. Only
  # extraPackages is set, so the module writes nothing into ~/.config/nvim and
  # the NvChad tree symlinked below stays intact.
  programs.neovim = {
    enable = true;
    # Binaries conform.nvim shells out to (nvim/lua/configs/conform.lua).
    extraPackages = with pkgs; [
      stylua # lua
      clang-tools # c/cpp -> clang-format
      ruff # python -> ruff format
      nixfmt # nix
      prettier # js/ts/jsx/tsx
    ];
  };

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
    # No `hosts` here on purpose: setting it links ~/.config/gh/hosts.yml into
    # the store read-only, and that is the file `gh auth login` writes the
    # OAuth token to ("read-only file system"). hosts.yml is auth state, not
    # config -- let gh own it; `user` is filled in on login. Keeping the module
    # enabled is what declares the gh git credential helper in git's config
    # (programs.gh.gitCredentialHelper), without which HTTPS pushes have no
    # credentials.
  };

  programs.claude-code = {
    enable = true;
    settings.includeCoAuthoredBy = false;
    skills = ../.claude/skills;
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
    keyMode = "vi";
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
