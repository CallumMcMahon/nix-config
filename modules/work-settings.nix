{
  pkgs,
  lib,
  ...
}: {
  # https://github.com/NixOS/nix/issues/8081
  nix.settings.ssl-cert-file = /etc/nix/ca_cert.pem;
}