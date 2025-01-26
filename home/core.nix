{pkgs, pkgs-unstable, ...}: 
  let
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
      zellij
      unzip
      helix
      micromamba
      xz
      p7zip
      aria2
      socat
      nmap
      file
      gawk
      zstd
  ];
  unstablePackages = with pkgs-unstable; [
    uv
  ];
  in {
  home.packages = stablePackages ++ unstablePackages;

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
