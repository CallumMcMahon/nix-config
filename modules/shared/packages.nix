{ pkgs, ... }:

with pkgs; [
  # General packages for development and system management
  bat
  btop
  coreutils
  difftastic
  du-dust
  gcc
  git-filter-repo
  killall
  neofetch
  # pandoc
  sqlite
  wget
  zip
  lazygit
  lazydocker
  postman
  sqlite
  ollama
  pqrs
  pgadmin4
  mpi
  xz
  jdk
  # code-cursor
  devenv

  # rust
  cargo
  rustc
  libiconv

  # Encryption and security tools
  age
  age-plugin-yubikey
  gnupg
  libfido2

  # Cloud-related tools and SDKs
  docker
  docker-compose
  colima
  # awscli2 - marked broken Mar 22
  google-cloud-sdk
  azure-cli
  terraform
  terraform-ls
  tflint

  # Media-related packages
  imagemagick
  dejavu_fonts
  ffmpeg
  fd
  font-awesome
  hack-font
  noto-fonts
  noto-fonts-emoji

  # Node.js development tools
  fzf
  nodePackages.live-server
  nodePackages.nodemon
  nodePackages.prettier
  nodePackages.npm
  nodejs

  # Source code management, Git, GitHub tools
  gh

  # Text and terminal utilities
  htop
  iftop
  jetbrains-mono
  jq
  ripgrep
  tree
  tmux
  zellij
  unrar
  unzip
  zsh-powerlevel10k
  helix

  # Python packages
  # python39
  # python39Packages.virtualenv
  micromamba
  uv
  # unstable.pixi
  poetry
  pyenv
  # py-spy
]
