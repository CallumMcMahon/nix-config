{
  pkgs,
  pkgs-unstable,
  config,
  ...
}: let
  stablePackages = with pkgs; [
    sqlite
    wget
    zip
    lazygit
    lazydocker
    ollama
    pqrs
    # rustc
    # cargo
    rustup # either cargo or rustup
    rsync # default macos version is old
    duckdb
    libiconv
    nil
    age
    gnupg
    libfido2
    docker
    docker-compose
    font-awesome
    fzf
    htop
    jq
    yq
    ripgrep
    tree
    tmux
    unzip
    xz
    p7zip
    aria2
    socat
    nmap
    file
    gawk
    zstd
    alejandra # nix code formatter
    ranger
    joshuto # trying ranger alternative
    nodejs # needed for neovim plugins
    rclone
    restic
  ];
  unstablePackages = with pkgs-unstable; [
    colima # xdg home support?
    uv
    micromamba
    mamba-cpp

    neovim
    helix
    zellij
  ];
  # currently assumes the location of the config repo
  # dotfiles = "${config.home.homeDirectory}/nix-config/dotfiles";
  dotfiles = builtins.toString (builtins.path { path = ../dotfiles; });
  mkOutOfStoreSymlink = config.lib.file.mkOutOfStoreSymlink;
in {
  home.packages = stablePackages ++ unstablePackages;
  xdg.enable = true; # verify with # nix run github:b3nj5m1n/xdg-ninja
  xdg.configFile = {
    "helix" = {
      source = mkOutOfStoreSymlink "${dotfiles}/helix";
      recursive = true;
    };
    "karabiner" = {
      source = mkOutOfStoreSymlink "${dotfiles}/karabiner/karabiner.json";
      target = "karabiner/karabiner.json";
    };
    "zellij" = {
      source = mkOutOfStoreSymlink "${dotfiles}/zellij";
      recursive = true;
    };
    "nvim" = {
      source = mkOutOfStoreSymlink "${dotfiles}/nvim";
      recursive = true;
    };
    "iterm2" = {
      source = mkOutOfStoreSymlink "${dotfiles}/iterm2/com.googlecode.iterm2.plist";
      target = "iterm2/com.googlecode.iterm2.plist";
    };
    "python" = {
      source = mkOutOfStoreSymlink "${dotfiles}/python";
      recursive = true;
    };
    "lazygit" = {
      source = mkOutOfStoreSymlink "${dotfiles}/lazygit/config.yml";
      target = "lazygit/config.yml";
    };
  };

  # Ensure lazy-lock.json is writable, not a symlink
  home.activation.makeLazyLockWritable = config.lib.dag.entryAfter ["writeBoundary"] ''
    LAZY_LOCK="$HOME/.config/nvim/lazy-lock.json"
    if [ -L "$LAZY_LOCK" ]; then
      $DRY_RUN_CMD rm -f "$LAZY_LOCK"
      $DRY_RUN_CMD cp "${dotfiles}/nvim/lazy-lock.json" "$LAZY_LOCK"
      $DRY_RUN_CMD chmod u+w "$LAZY_LOCK"
    fi
  '';

  programs = {
    # modern vim
    neovim = {
      enable = false;
      defaultEditor = true;
      vimAlias = true;
      package = pkgs-unstable.neovim;
      plugins = [pkgs.vimPlugins.lazy-nvim];
      # extraLuaConfig =
      #   # lua
      #   ''
      #     require("lazy").setup({
      #       -- disable all update / install features
      #       -- this is handled by nix
      #       rocks = { enabled = false },
      #       pkg = { enabled = false },
      #       install = { missing = false },
      #       change_detection = { enabled = false },
      #       spec = {
      #         -- TODO
      #       },
      #     })
      #   '';
    };

    vscode = {
      enable = false;
      package = pkgs-unstable.vscode;
      profiles.default.extensions = with pkgs.vscode-extensions; [
        ms-python.python
        ms-python.debugpy
        ms-python.vscode-pylance
        asvetliakov.vscode-neovim
        dracula-theme.theme-dracula

        ms-toolsai.jupyter
        ms-toolsai.jupyter-keymap

        yzhang.markdown-all-in-one
        waderyan.gitblame
        jnoortheen.nix-ide
        charliermarsh.ruff
        github.copilot
        github.copilot-chat
      ];
    };

    # A modern replacement for 'ls'
    # useful in bash/zsh prompt, not in nushell.
    eza = {
      enable = true;
      git = true;
      icons = "auto";
      enableZshIntegration = true;
    };

    # terminal file manager
    yazi = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        manager = {
          show_hidden = true;
          sort_dir_first = true;
        };
      };
    };

    # skim provides a single executable: sk.
    # Basically anywhere you would want to use grep, try sk instead.
    skim = {
      enable = true;
      enableBashIntegration = true;
    };

    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
  };
}
