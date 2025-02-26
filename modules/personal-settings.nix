{
  pkgs,
  pkgs-unstable,
  specialArgs,
  ...
}:
{
  home-manager.users.${specialArgs.username} = {
    home.packages = [
      pkgs.signal-desktop 
      pkgs-unstable.whatsapp-for-mac 
      pkgs-unstable.raycast
    ];
  };
  services.tailscale = {
    enable = true;
    package = pkgs-unstable.tailscale;
  };
}