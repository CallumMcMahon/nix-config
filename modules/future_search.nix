{
  pkgs,
  specialArgs,
  ...
}: let
  gdk = pkgs.google-cloud-sdk.withExtraComponents( with pkgs.google-cloud-sdk.components; [
      gke-gcloud-auth-plugin
    ]);
in
{
  # https://github.com/NixOS/nix/issues/8081
  # nix.settings.ssl-cert-file = /etc/nix/ca_cert.pem;
  home-manager.users.${specialArgs.username} = {
    home.packages = [
      gdk 
      # pkgs.azure-cli
    ];
    # programs = {
    #   zsh.initExtra = "source ~/nix-config/modules/work_zshrc";
    #   git = {
    #     extraConfig.commit.pgpsign = true;
    #     signing = {
    #       key = "6F5AAB42F3606CF7";
    #       signByDefault = true;
    #     };
    #   };
    # };
  };
}