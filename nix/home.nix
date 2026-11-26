{ config, pkgs, ... }:
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
    # External binaries nvim shells out to: conform.nvim formatters
    # (nvim/lua/configs/conform.lua), language servers, and the treesitter
    # parser toolchain.
    extraPackages = with pkgs; [
      # conform.nvim formatters, per filetype.
      stylua # lua
      clang-tools # c/cpp -> clang-format
      ruff # python -> ruff format
      nixfmt # nix
      prettier # js/ts/jsx/tsx

      # Language servers for every name in lspconfig.lua's `servers` list.
      # vim.lsp.enable fails silently per server when the binary is absent.
      pyright # pyright -> pyright-langserver
      nixd # nixd
      typescript-language-server # ts_ls
      vscode-langservers-extracted # html + cssls language servers
      # ruff doubles as the `ruff` server, clang-tools ships clangd.

      # Parser toolchain for nvim-treesitter. The pinned commit is the
      # main-branch rewrite, which shells out to `tree-sitter build` (see
      # install.lua) and whose health check requires tree-sitter-cli >= 0.26.1
      # -- without the CLI nothing in ensure_installed ever installs. gcc is
      # what `tree-sitter build` compiles with; curl and tar are already on
      # nvim's PATH.
      tree-sitter
      gcc
    ];
  };

  # XDG base directory spec: export the user-level XDG_*_HOME variables (apps
  # otherwise only land in ~/.config etc. by spec default, with nothing telling
  # them to) and make home-manager modules prefer XDG paths over $HOME
  # dotfiles -- of the modules honoring it, gtk2 is the one in use here, so
  # ~/.gtkrc-2.0 moves to ~/.config/gtk-2.0/gtkrc.
  xdg.enable = true;
  home.preferXdgDirectories = true;

  # Writes ~/.config/user-dirs.dirs so file pickers and xdg-user-dir resolve.
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    desktop = "${config.home.homeDirectory}/Desktop";
    documents = "${config.home.homeDirectory}/Documents";
    download = "${config.home.homeDirectory}/Downloads";
    music = "${config.home.homeDirectory}/Music";
    pictures = "${config.home.homeDirectory}/Pictures";
    videos = "${config.home.homeDirectory}/Videos";
    # Upstream defaults these, but nothing on this system consumes them:
    # PublicShare needs a sharing daemon, Templates only feeds Dolphin's
    # "Create New" menu, and Projects isn't even a name xdg-user-dir(1) can
    # look up. null keeps createDirectories from making them.
    projects = null;
    publicShare = null;
    templates = null;
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
