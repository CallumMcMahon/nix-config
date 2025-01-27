{
  pkgs,
  lib,
  ...
}: {
  nix.settings.ssl-cert-file = /etc/nix/ca_cert.pem;
}