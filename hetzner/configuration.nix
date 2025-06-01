{
  modulesPath,
  lib,
  pkgs,
  hostname,
  username,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
  ];
  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };
  services.tailscale = {
    enable = true;
  };

  networking.firewall = {
    enable = true;
    allowPing = true; # Optional: allows ICMP ping requests to your server

    # Define your public network interface.
    # For Hetzner Cloud servers, this is typically 'eth0'.
    # You can verify with `ip addr` on your server.
    # If it's different, change 'eth0' below.
    interfaces."eth0" = {
      allowedTCPPorts = [
        22 # SSH
      ];
      allowedUDPPorts = [
        41641 # Tailscale WireGuard port
      ];
      # Ports 80, 443, and others will be blocked on this interface by default.
    };

    # Allow specific traffic on the Tailscale interface for your services
    interfaces."tailscale0" = {
      allowedTCPPorts = [
        80 # Caddy HTTP
        443 # Caddy HTTPS
      ];
      allowedUDPPorts = [
        443 # Caddy HTTP/3
      ];
      # Add any other ports for services you want accessible *only* via Tailscale.
    };

    # Trust the loopback interface
    trustedInterfaces = [ "lo" ];
  };

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
    pkgs.neovim
  ];

  networking.hostName = hostname;
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO3j3IjwJqhr6H8J/LE3hT3JpKuiKaYM23H6PwDV19iE"
  ];
  users.users.${username} = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO3j3IjwJqhr6H8J/LE3hT3JpKuiKaYM23H6PwDV19iE"
    ];
    # home = "/home/${username}";
    # description = "${username}'s home";
  };
  system.stateVersion = "24.05";
  programs.nix-ld.enable = true;
  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = false;
      # setSocketVariable = true;
    };
  };
}
