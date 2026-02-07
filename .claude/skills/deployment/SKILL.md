---
name: Deployment & Secrets Bootstrapping
description: How to deploy nix configs and bootstrap secrets with sops
---

# Deployment & Secrets Bootstrapping

## Overview

This is a NixOS configuration repository for:
- m4: Personal macOS nix-darwin ARM laptop (M4)
- mini: Personal Mac Mini server
- Hetzner cloud server

Infrastructure: Cloudflare (domain: `callums-server.co.uk`), Tailscale (private networking).

**Note:** For non-standard commands not in this config, use `nix-shell -p <pkg>`

This repo uses **sops-nix** for secrets management. Secrets are encrypted in the repo and decrypted at activation time by each machine using its own age key.

## Architecture

```
m4 age key (stored in Bitwarden - the ONLY secret to back up)
    ↓ decrypts
secrets/bootstrap.yaml (contains other machines' age keys)
    ↓ deployed to each machine once
machine's age key (~/.config/sops/age/keys.txt)
    ↓ decrypts
secrets/<machine>.yaml (deploy keys, API keys, etc.)
```

## Age Keys

| Machine | Age Public Key | Location |
|---------|---------------|----------|
| m4 (local) | `age1hg5nuw0m943yhchef9wq85vzkyrs5yn6yzy7kx3nttxl884p7ytqqln4nk` | `~/.config/sops/age/keys.txt` |
| mini | `age12lectvfq9anuussh23ke9lrc5tflf48fdruacpqtl8saxfgt5fmsqchlhz` | `~/.config/sops/age/keys.txt` |

## Secrets Files

| File | Encrypted To | Contains |
|------|-------------|----------|
| `secrets/bootstrap.yaml` | m4 only | Other machines' age private keys |
| `secrets/mini.yaml` | m4 + mini | Deploy key, git-crypt key, API keys |

## Deployment Types

### Local Machine (m4) - Full System

```bash
sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake .#Callums-MacBook-Pro
```

### Local Machine (m4) - Home Manager Only

```bash
nix run home-manager/release-25.11 -- switch --flake .#callum@Callums-MacBook-Pro
```

### Mac Mini - Rootless Home Manager

**Warning:** The remote repo often has uncommitted local changes. Always check `git status` on the remote before pulling to avoid clobbering them. Stash or commit remote changes first if needed.

```bash
# Check remote status first
ssh mini "cd ~/nix-config && git status"

# Locally: commit and push
git add -A && git commit -m "message" && git push

# On remote: pull and deploy (stash if needed)
ssh mini "cd ~/nix-config && git stash && git pull && git stash pop && nix run home-manager/release-25.11 -- switch --flake .#fibonar@Callums-Mac-Mini"
```

### Mac Mini - Full System (requires admin)

**Warning:** Check for uncommitted remote changes before pulling (see above).

```bash
# Check remote status first
ssh mini-admin "cd /Users/fibonar/nix-config && git status"

# Locally: commit and push
git add -A && git commit -m "message" && git push

# On remote: pull and deploy as admin
ssh mini-admin "cd /Users/fibonar/nix-config && git stash && git pull && git stash pop && sudo darwin-rebuild switch --flake .#Callums-Mac-Mini"
```

### Mac Mini - Restart Docker Containers

```bash
ssh mini "cd /Users/fibonar/nix-config/composes/<service> && docker compose up -d"
```

## Mac Mini Docker / YAMS

### Storage Layout

Service configs and databases live on the 4TB SSD, **not** in the git tree:

```
/Volumes/mini4/
├── yams/config/          # Service configs + DBs (CONFIG_DIR)
│   ├── sonarr/
│   ├── radarr/
│   ├── lidarr/
│   └── ...
├── media/                # Media files (MEDIA_DIRECTORY)
├── torrents/
└── torrents-seeding-hidden/
```

Environment variables (in `composes/yams/.env`):
- `CONFIG_DIR=/Volumes/mini4/yams/config` — service config/DB storage
- `MEDIA_DIRECTORY=/Volumes/mini4` — media storage

Colima is configured to mount `/Volumes/mini4` as writable (in `~/.config/colima/default/colima.yaml`).

### VPN (Gluetun + Mullvad WireGuard)

Gluetun uses **WireGuard** (Mullvad removed OpenVPN entirely in Jan 2026).

Environment variables (in `composes/yams/.env`):
- `WIREGUARD_PRIVATE_KEY` — WireGuard private key
- `WIREGUARD_ADDRESSES` — tunnel IP assigned by Mullvad (e.g. `10.x.x.x/32`)

Docker compose config (in `docker-compose.yaml`):
- `VPN_SERVICE_PROVIDER=mullvad`
- `VPN_TYPE=wireguard`
- `SERVER_CITIES=London`

#### Generating a new WireGuard key

If the Mullvad device is removed or you need a new key:

```bash
# Generate key pair (locally or via nix-shell on mini)
nix-shell -p wireguard-tools --run 'wg genkey | tee /tmp/wg-private | wg pubkey'

# Upload the PUBLIC key to Mullvad:
# Account page > Advanced > Create device > paste public key
# Mullvad assigns a tunnel IP (e.g. 10.74.209.139/32)

# Update .env on the mini with the PRIVATE key and assigned address:
# WIREGUARD_PRIVATE_KEY=<private key>
# WIREGUARD_ADDRESSES=<assigned IP>/32

# Restart gluetun
ssh mini "cd ~/nix-config/composes/yams && docker compose up -d gluetun"
```

## Bootstrapping a Machine

When setting up a new machine or after a wipe:

### 1. Deploy the age key

```bash
# Extract the machine's age key from bootstrap.yaml
sops -d secrets/bootstrap.yaml | grep <machine>_age_key | cut -d' ' -f2 > /tmp/age-key

# Copy to the machine
ssh <machine> "mkdir -p ~/.config/sops/age"
scp /tmp/age-key <machine>:~/.config/sops/age/keys.txt
rm /tmp/age-key

# Verify format (should only have comments starting with # and the key)
ssh <machine> "cat ~/.config/sops/age/keys.txt"
```

### 2. Clone repo and deploy

```bash
# On the machine, clone the repo (or pull if already cloned)
ssh <machine> "git clone <repo-url> ~/nix-config" # or "cd ~/nix-config && git pull"

# Deploy
ssh <machine> "cd ~/nix-config && nix run home-manager/release-25.11 -- switch --flake .#<config-name>"
```

## Adding a New Machine

1. Generate age key on the machine:
   ```bash
   ssh <machine> "mkdir -p ~/.config/sops/age && age-keygen"
   ```

2. Fix the keys.txt format (remove "Public key:" line, keep only comments and key):
   ```bash
   ssh <machine> "cat ~/.config/sops/age/keys.txt"
   # Edit to have only: # comments and AGE-SECRET-KEY-... line
   ```

3. Add public key to `.sops.yaml`

4. Add private key to `secrets/bootstrap.yaml`:
   ```bash
   sops secrets/bootstrap.yaml
   # Add: <machine>_age_key: AGE-SECRET-KEY-...
   ```

5. Create machine secrets file:
   ```bash
   echo "placeholder: value" > secrets/<machine>.yaml
   sops --encrypt --in-place secrets/<machine>.yaml
   ```

6. Update `flake.nix` with sops-nix config for the machine

## Editing Secrets

```bash
# Edit a secrets file (decrypts, opens editor, re-encrypts)
sops secrets/mini.yaml

# Update keys after changing .sops.yaml
sops updatekeys --yes secrets/mini.yaml
```

## Disaster Recovery

If a machine is wiped:
1. Re-install OS
2. Bootstrap the age key from `secrets/bootstrap.yaml` (see above)
3. Deploy as normal

If your local machine (m4) is wiped:
1. Restore age key from Bitwarden to `~/.config/sops/age/keys.txt`
2. Clone repo
3. You can now decrypt everything

## Troubleshooting

### "no identity matched any of the recipients"

The `keys.txt` file has wrong format. It should contain only:
- Lines starting with `#` (comments)
- The `AGE-SECRET-KEY-...` line

Remove any "Public key:" lines.

### Secrets not decrypting on machine

1. Check the machine's public key is in `.sops.yaml`
2. Run `sops updatekeys --yes secrets/<file>.yaml` to re-encrypt
3. Sync and redeploy

### sops-nix secrets missing after reboot (macOS)

On macOS, sops-nix decrypts secrets via a launchd agent (`org.nix-community.home.sops-nix`) into a temp directory. Secrets should be re-decrypted automatically on login via the agent.

If secrets are missing (deploy key dangling symlink, git push fails):

```bash
# Check the launchd agent logs
ssh mini "cat ~/Library/Logs/SopsNix/stderr"

# If the agent failed, manually trigger it:
ssh mini "/bin/launchctl bootout gui/\$(id -u) ~/Library/LaunchAgents/org.nix-community.home.sops-nix.plist; sleep 1; /bin/launchctl bootstrap gui/\$(id -u) ~/Library/LaunchAgents/org.nix-community.home.sops-nix.plist"

# Or re-run home-manager switch to re-activate everything
```

### git-crypt not unlocked after reboot

git-crypt unlock state doesn't persist across reboots. The home-manager activation script (`unlockGitCrypt` in `mini-sops.nix`) handles this automatically during `home-manager switch`.

If git-crypt files appear as binary (`GITCRYPT` header) and home-manager switch fails because it can't evaluate them:

```bash
# Manually decrypt the git-crypt key and unlock
ssh mini "nix-shell -p sops --run 'cd ~/nix-config && sops -d --extract \"[\\\"git_crypt_key\\\"]\" secrets/mini.yaml' | base64 -d > /tmp/gc-key"
ssh mini "zsh -i -c 'cd ~/nix-config && git stash && git-crypt unlock /tmp/gc-key && git stash pop'"
ssh mini "rm /tmp/gc-key"

# Force re-checkout of encrypted files through the smudge filter
ssh mini "zsh -i -c 'cd ~/nix-config && git checkout -- home/openclaw-config.nix'"
```

**Important:** Nix flakes cache the source tree. After unlocking git-crypt, encrypted files must appear as "dirty" (modified) in git for Nix to use the decrypted working tree version. If a `git checkout` makes the file "clean", add a trivial change (e.g. `echo >> file`) so Nix picks up the decrypted content.

### Mini can't push to GitHub

The mini uses a deploy key managed by sops-nix. SSH config is managed by home-manager (`programs.ssh` in `home/mini-sops.nix`).

The deploy key does **not** have permission to push to the protected `main` branch. To sync changes from the mini to main, push to a feature branch and create a PR via the GitHub UI.

```bash
# Test SSH auth
ssh mini "ssh -T git@github.com"

# Push to a feature branch (not main)
ssh mini "cd ~/nix-config && git push origin HEAD:feature-branch-name"
```
