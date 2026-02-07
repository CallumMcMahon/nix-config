# Mini-specific sops-nix configuration for secrets management
{
  config,
  pkgs,
  lib,
  miniSecretsFile,
  sops-nix,
  nix-openclaw,
  ...
}: {
  imports = [
    sops-nix.homeManagerModules.sops
    nix-openclaw.homeManagerModules.openclaw
    ./openclaw-config.nix
  ];

  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    defaultSopsFile = miniSecretsFile;
    secrets.deploy_key = {
      path = "${config.home.homeDirectory}/.ssh/nix-config-deploy";
      mode = "0600";
    };
    secrets.git_crypt_key = {
      path = "${config.home.homeDirectory}/.config/git-crypt/nix-config-key";
    };
  };

  programs.ssh = {
    enable = true;
    includes = ["${config.home.homeDirectory}/.config/colima/ssh_config"];
    matchBlocks."github.com" = {
      identityFile = "${config.home.homeDirectory}/.ssh/nix-config-deploy";
      identitiesOnly = true;
    };
  };

  home.activation.setupDeployKey = config.lib.dag.entryAfter ["sops-nix"] ''
    mkdir -p "${config.home.homeDirectory}/.ssh"
    chmod 700 "${config.home.homeDirectory}/.ssh"
  '';

  # Unlock git-crypt in the nix-config repo
  home.activation.unlockGitCrypt = let
    git-crypt = "${pkgs.git-crypt}/bin/git-crypt";
  in
    config.lib.dag.entryAfter ["sops-nix"] ''
      REPO_DIR="${config.home.homeDirectory}/nix-config"
      KEY_FILE="${config.home.homeDirectory}/.config/git-crypt/nix-config-key"
      if [ -d "$REPO_DIR/.git" ] && [ -f "$KEY_FILE" ]; then
        mkdir -p "$(dirname "$KEY_FILE")"
        base64 -d < "$KEY_FILE" > "$KEY_FILE.bin"
        cd "$REPO_DIR"
        if ! ${git-crypt} status &>/dev/null 2>&1; then
          ${git-crypt} unlock "$KEY_FILE.bin" || true
        fi
        rm -f "$KEY_FILE.bin"
      fi
    '';

}
