{
  lib,
  username,
  system ? "aarch64-darwin",
  ...
}: let
  isDarwin = builtins.match ".*-darwin" system != null;
  homeDir = if isDarwin then "/Users/${username}" else "/home/${username}";
in {
  # import sub modules
  imports = [
    ./shell.nix
    ./core.nix
    ./git.nix
    ./gpg.nix
    ./starship.nix
    # ./tmux.nix
  ];

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home = {
    username = lib.mkDefault username;
    homeDirectory = lib.mkDefault homeDir;

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = "24.05";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
