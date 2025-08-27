{
  pkgs,
  pkgs-unstable,
  specialArgs,
  ...
}: let
  stablePackages = with pkgs; [
    iina
    iterm2
    # karabiner-elements
  ];
  # services.karabiner-elements.enable = true;
  unstablePackages = with pkgs-unstable; [
    raycast
  ];
in {
  home-manager.users.${specialArgs.username} = {
    home.packages = stablePackages ++ unstablePackages;
    programs.zsh.initContent = ''
      # refactor to only be on macos outputs
      export DOCKER_HOST="unix://$HOME/.config/colima/default/docker.sock"
    '';
  };
  services.tailscale = {
    enable = true;
    # package = pkgs-unstable.tailscale;
    package = pkgs.tailscale;
  };
}
