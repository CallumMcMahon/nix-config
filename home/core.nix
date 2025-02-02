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
    cargo
    rustc
    libiconv
    nil
    age
    gnupg
    libfido2
    docker
    docker-compose
    colima
    font-awesome
    fzf
    htop
    jq
    ripgrep
    tree
    tmux
    unzip
    micromamba
    xz
    p7zip
    aria2
    socat
    nmap
    file
    gawk
    zstd
    alejandra
    nodejs # needed for neovim plugins

    # macOS
    iina
    iterm2
  ];
  unstablePackages = with pkgs-unstable; [
    uv
    helix
    zellij
    neovim
  ];
  # currently assumes the location of the config repo
  dotfiles = "${config.home.homeDirectory}/nixos-config/dotfiles";
in {
  home.packages = stablePackages ++ unstablePackages;
  xdg.configFile = {
    "helix" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/helix";
      recursive = true;
    };
    "karabiner" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/karabiner/karabiner.json";
      target = "karabiner/karabiner.json";
    };
    "zellij" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/zellij";
      recursive = true;
    };
    "nvim" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/nvim";
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
