{
  pkgs,
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

  # Install service packages
  environment.systemPackages = with pkgs; [
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
  ];
}
