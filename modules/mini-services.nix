{
  pkgs,
  pkgs-unstable,
  username,
  ...
}: {
  # Custom Jellyfin launchd service (runs as user LaunchAgent for TCC/external drive access)
  # Check status: `ssh mini "launchctl list | grep jellyfin"` (PID = running, - = not running)
  # Restart: `ssh mini "launchctl kickstart -kp gui/$(id -u)/org.nixos.jellyfin"`
  # Logs: `ssh mini "tail -f ~/Library/Logs/jellyfin.log"`
  # Note: Runs as user agent (not daemon) to allow access to external volumes like /Volumes/mini4
  launchd.user.agents.jellyfin = {
    serviceConfig = {
      ProgramArguments = [
        "${pkgs.jellyfin}/bin/jellyfin"
        "--datadir"
        "/Users/${username}/.local/share/jellyfin"
        "--configdir"
        "/Users/${username}/.config/jellyfin"
        "--cachedir"
        "/Users/${username}/.cache/jellyfin"
      ];
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "/Users/${username}/Library/Logs/jellyfin.log";
      StandardErrorPath = "/Users/${username}/Library/Logs/jellyfin.error.log";
      WorkingDirectory = "/Users/${username}/.local/share/jellyfin";
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

  # Create necessary directories for jellyfin (user-level paths for LaunchAgent)
  system.activationScripts.jellyfin = {
    text = ''
      # Create user directories for jellyfin LaunchAgent
      sudo -u ${username} mkdir -p /Users/${username}/.local/share/jellyfin
      sudo -u ${username} mkdir -p /Users/${username}/.config/jellyfin
      sudo -u ${username} mkdir -p /Users/${username}/.cache/jellyfin
      sudo -u ${username} mkdir -p /Users/${username}/Library/Logs
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
