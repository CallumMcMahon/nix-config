{
  pkgs,
  pkgs-unstable,
  username,
  ...
}: {
  # Custom Jellyfin launchd service
  # Check status: `ssh mini-admin "sudo launchctl list | grep jellyfin"` (PID = running, - = not running)
  # Restart: `ssh mini-admin "sudo launchctl kickstart -kp system/org.nixos.jellyfin"`
  # If kickstart hangs (stuck state after reboot), use unload/load instead:
  # Unload: `ssh mini-admin "sudo launchctl unload /Library/LaunchDaemons/org.nixos.jellyfin.plist"`
  # Load: `ssh mini-admin "sudo launchctl load /Library/LaunchDaemons/org.nixos.jellyfin.plist"`
  # Logs: `ssh mini-admin "tail -f /var/log/jellyfin.log"`
  launchd.daemons.jellyfin = {
    serviceConfig = {
      ProgramArguments = [
        "${pkgs.jellyfin}/bin/jellyfin"
        "--datadir"
        "/var/lib/jellyfin"
        "--configdir"
        "/etc/jellyfin"
        "--cachedir"
        "/var/cache/jellyfin"
      ];
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "/var/log/jellyfin.log";
      StandardErrorPath = "/var/log/jellyfin.error.log";
      WorkingDirectory = "/var/lib/jellyfin";
    };
  };

  # Custom n8n launchd service
  # Check status: `ssh mini-admin "sudo launchctl list | grep n8n"` (PID = running, - = not running)
  # Restart: `ssh mini-admin "sudo launchctl kickstart -kp system/org.nixos.n8n"`
  # Logs: `ssh mini-admin "tail -f /var/log/n8n.log"`
  launchd.daemons.n8n = {
    serviceConfig = {
      ProgramArguments = [
        "${pkgs-unstable.n8n}/bin/n8n"
      ];
      EnvironmentVariables = {
        N8N_USER_FOLDER = "/var/lib/n8n";
        N8N_PORT = "5678";
        N8N_HOST = "0.0.0.0";
        N8N_PROTOCOL = "http";
      };
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "/var/log/n8n.log";
      StandardErrorPath = "/var/log/n8n.error.log";
      WorkingDirectory = "/var/lib/n8n";
    };
  };

  # Create necessary directories for jellyfin
  system.activationScripts.jellyfin = {
    text = ''
      mkdir -p /var/lib/jellyfin
      mkdir -p /etc/jellyfin
      mkdir -p /var/cache/jellyfin
      mkdir -p /var/log
      chown -R ${username}:staff /var/lib/jellyfin
      chown -R ${username}:staff /etc/jellyfin
      chown -R ${username}:staff /var/cache/jellyfin
    '';
  };

  # Create necessary directories for n8n
  system.activationScripts.n8n = {
    text = ''
      mkdir -p /var/lib/n8n
      mkdir -p /var/log
      chown -R ${username}:staff /var/lib/n8n
    '';
  };

  # Install service packages
  environment.systemPackages = with pkgs; [
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
  ] ++ [ pkgs-unstable.n8n ];
}
