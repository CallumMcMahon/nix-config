---
name: Deployment & Secrets Bootstrapping
description: How to deploy nix configs and bootstrap secrets with sops
---

# Deployment & Secrets Bootstrapping

## Overview

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

```bash
# Sync repo
rsync -avz --exclude='.git' /Users/callum/nix-config/ mini:/Users/fibonar/nix-config/

# Deploy
ssh mini "cd ~/nix-config && nix run home-manager/release-25.11 -- switch --flake .#fibonar@Callums-Mac-Mini"
```

### Mac Mini - Full System (requires admin)

```bash
rsync -avz --exclude='.git' /Users/callum/nix-config/ mini:/Users/fibonar/nix-config/
ssh mini-admin "cd /Users/fibonar/nix-config && sudo darwin-rebuild switch --flake .#Callums-Mac-Mini"
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

### 2. Sync and deploy

```bash
rsync -avz --exclude='.git' /Users/callum/nix-config/ <machine>:/path/to/nix-config/
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
