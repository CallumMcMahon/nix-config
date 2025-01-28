{
  pkgs,
  specialArgs,
  ...
}:
{
  home-manager.users.${specialArgs.username} = {
    home.packages = [pkgs.signal-desktop];
  };
}