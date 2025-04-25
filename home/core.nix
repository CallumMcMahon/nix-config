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

    # macOS
    iina
    iterm2
  ];
  unstablePackages = with pkgs-unstable; [
    colima # xdg home support?
    uv
    helix
    zellij
    neovim
    micromamba
    mamba-cpp
  ];
  # currently assumes the location of the config repo
  dotfiles = "${config.home.homeDirectory}/nix-config/dotfiles";
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
  };

  programs = {
    # modern vim
    neovim = {
      enable = false;
      defaultEditor = true;
      vimAlias = true;
      package = pkgs-unstable.neovim;
    };

    vscode = {
      enable = true;
      package = pkgs-unstable.vscode;
      extensions = with pkgs.vscode-extensions; [
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

    # A modern replacement for ‘ls’
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
