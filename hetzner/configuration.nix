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

  # services.fail2ban = {
  #   enable = true;
    
  #   bantime-increment = {
  #     enable = true;
  #     multipliers = "1 2 4 8 16 32 64";
  #     maxtime = "168h";
  #     overalljails = true;
  #   };
    
  #   ignoreIP = [
  #     "127.0.0.1/8"
  #     "::1"
  #     "10.0.0.0/8"
  #     "172.16.0.0/12"
  #     "192.168.0.0/16"
  #     "100.64.0.0/10"  # Tailscale CGNAT range
  #   ];
  # };

  # networking.firewall = {
  #   enable = true;
  #   allowPing = true; # Optional: allows ICMP ping requests to your server

  #   # Define your public network interface.
  #   # For Hetzner Cloud servers, this is typically 'eth0'.
  #   # You can verify with `ip addr` on your server.
  #   # If it's different, change 'eth0' below.
  #   interfaces."eth0" = {
  #     allowedTCPPorts = [
  #       22 # SSH
  #     ];
  #     allowedUDPPorts = [
  #       41641 # Tailscale WireGuard port
  #     ];
  #     # Ports 80, 443, and others will be blocked on this interface by default.
  #   };

  #   # Allow specific traffic on the Tailscale interface for your services
  #   interfaces."tailscale0" = {
  #     allowedTCPPorts = [
  #       80 # Caddy HTTP
  #       443 # Caddy HTTPS
  #     ];
  #     allowedUDPPorts = [
  #       443 # Caddy HTTP/3
  #     ];
  #     # Add any other ports for services you want accessible *only* via Tailscale.
  #   };

  #   # Trust the loopback interface
  #   trustedInterfaces = [ "lo" ];
  # };

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
    pkgs.neovim
    pkgs.cacert
    pkgs.passt
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
    linger = true; # stops rootless docker from exiting
    # home = "/home/${username}";
    # description = "${username}'s home";
  };
  system.stateVersion = "24.05";
  programs.nix-ld.enable = true;
  
  # Allow rootless docker to bind to privileged ports
  boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = 80;
  
  virtualisation.docker = {
    enable = false;
    rootless = {
      enable = true;
      setSocketVariable = true;
      daemon.settings = {
        dns = [ "1.1.1.1" "8.8.8.8" ];
        registry-mirrors = [ "https://mirror.gcr.io" ];
      };
    };
  };

  systemd.user.services.docker = {
    path = [ pkgs.passt ];
    environment = {
      DOCKERD_ROOTLESS_ROOTLESSKIT_NET = "pasta";
      DOCKERD_ROOTLESS_ROOTLESSKIT_PORT_DRIVER = "implicit";
    };
  };
}
