{pkgs, ...}: {
  programs.gpg = {
    enable = true;
    settings = {
      # Use strong algorithms
      personal-cipher-preferences = "AES256 AES192 AES";
      personal-digest-preferences = "SHA512 SHA384 SHA256";
      personal-compress-preferences = "ZLIB BZIP2 ZIP Uncompressed";
      default-preference-list = "SHA512 SHA384 SHA256 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed";
      cert-digest-algo = "SHA512";
      s2k-digest-algo = "SHA512";
      s2k-cipher-algo = "AES256";
      # Display preferences
      keyid-format = "0xlong";
      with-fingerprint = true;
    };
  };

  # gpg-agent configuration for macOS
  home.file.".gnupg/gpg-agent.conf".text = ''
    # Use macOS pinentry for passphrase prompts (with Keychain integration)
    pinentry-program ${pkgs.pinentry_mac}/bin/pinentry-mac
    # Cache passphrase for 24 hours
    default-cache-ttl 86400
    max-cache-ttl 604800
    # Enable SSH agent support (optional, if you want GPG to handle SSH keys too)
    # enable-ssh-support
  '';

  # Ensure gpg-agent is restarted when config changes
  home.activation.reloadGpgAgent = ''
    ${pkgs.gnupg}/bin/gpgconf --kill gpg-agent || true
  '';
}
