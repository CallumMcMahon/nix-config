{
  pkgs,
  pkgs-unstable,
  specialArgs,
  ...
}: {
  home-manager.users.${specialArgs.username} = {
    home.packages = [
      # pkgs.signal-desktop  # no longer available on macos
      # pkgs-unstable.whatsapp-for-mac  # constant updates complain
      pkgs-unstable.raycast
    ];
  };
  services.tailscale = {
    enable = true;
    package = pkgs-unstable.tailscale;
  };
}
