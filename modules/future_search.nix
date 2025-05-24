{
  pkgs,
  pkgs-unstable,
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
      pkgs.sops
      pkgs-unstable.slack
      pkgs.texlive.combined.scheme-full
      pkgs.pnpm_10
      # pkgs.lefthook
      pkgs-unstable.lefthook
      pkgs-unstable.supabase-cli
      pkgs-unstable.watchexec 
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
