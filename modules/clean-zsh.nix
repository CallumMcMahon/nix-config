{ config, username, ... }:
let
  xdgConfig = config.home-manager.users.${username}.xdg;
in
{
  environment.etc."zshenv".text = ''
    source ${xdgConfig.configHome}/zsh/.zshenv
  '';
  home-manager.users.${username}.home.file.".zshenv".enable = false;
}