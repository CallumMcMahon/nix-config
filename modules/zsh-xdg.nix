# https://github.com/nix-community/home-manager/issues/1965#issuecomment-2075045184
{
  config,
  username,
  ...
}: let
  xdgConfig = config.home-manager.users.${username}.xdg;
in {
  environment.etc."zshenv".text = ''
    SHELL_SESSIONS_DISABLE=1
    source ${xdgConfig.configHome}/zsh/.zshenv
  '';
  home-manager.users.${username}.home.file.".zshenv".enable = false;
}
