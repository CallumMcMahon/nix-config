{
  pkgs,
  pkgs-unstable,
  ...
}: let
  gdk = pkgs.google-cloud-sdk.withExtraComponents (with pkgs.google-cloud-sdk.components; [
    gke-gcloud-auth-plugin
  ]);
in {
  home.packages = [
    gdk
    pkgs.sops
    # pkgs-unstable.slack
    pkgs.texlive.combined.scheme-full
    pkgs.pnpm_10
    # pkgs.lefthook
    pkgs-unstable.lefthook
    pkgs-unstable.supabase-cli
    pkgs-unstable.watchexec
    pkgs-unstable.codex # slow to build, local only
    pkgs-unstable.uv # conflicts with openclaw on mini
    # pkgs.azure-cli

    # pkgs.blender
    # pkgs.sweethome3d.application
  ];
}
