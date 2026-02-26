{
  pkgs,
  pkgs-unstable,
  ...
}: let
  stablePackages = with pkgs; [
    iina
    iterm2
  ];
  unstablePackages = with pkgs-unstable; [
    raycast
  ];
in {
  home.packages = stablePackages ++ unstablePackages;
  programs.zsh.initContent = ''
    export DOCKER_HOST="unix://$HOME/.config/colima/default/docker.sock"
  '';
}
