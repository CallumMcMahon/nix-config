{pkgs, ...}: {
  home.packages = with pkgs; [
    # git
    sqlite
    wget
    zip
    lazygit
    lazydocker
    ollama
    pqrs

    # rust
    cargo
    rustc
    libiconv

    # Encryption and security tools
    age
    gnupg
    libfido2

    # Cloud-related tools and SDKs
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
    zellij
    unzip
    helix

    micromamba
    uv

    # rich demo examples
    xz
    p7zip

    aria2 # A lightweight multi-protocol & multi-source command-line download utility
    socat # replacement of openbsd-netcat
    nmap # A utility for network discovery and security auditing

    # misc
    file
    gawk
    zstd
    # productivity
    # glow # markdown previewer in terminal
  ];

  programs = {
    # modern vim
    neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
    };

    # A modern replacement for ‘ls’
    # useful in bash/zsh prompt, not in nushell.
    eza = {
      enable = true;
      git = true;
      icons = true;
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
  };
}
