# Nix Config Project Notes

<!-- This file is committed to a public repo. Do not document private details (paths, hostnames, IPs, credentials, etc.). Use CLAUDE.local.md for machine-specific or private information. -->

## Configuration Philosophy

System and user configuration should be defined declaratively in Nix rather than via imperative commands. If a setting can be codified in this Nix config, prefer that over running ad-hoc commands (e.g., `git config`, `defaults write`, manual dotfile edits). Check the relevant Nix modules for the authoritative source of any configuration.

## Text Handling

Never manually repeat or regurgitate long sequences of text (>150 characters). Use programmatic methods instead (write to file, pipe to clipboard, etc.) to avoid transcription errors.

## Debugging Hosted Services

When debugging failures in hosted/remote services, prefer checking logs via SSH rather than using Chrome browser automation. Use browser inspection only as a last resort.

## Deploying Config Changes to Remote Servers

When making configuration changes that need to be deployed to a remote server:

1. **Always make changes locally** in this repo first
2. **Sync the entire repo** to the remote server (not just the changed files)
3. **Restart affected services** as needed
4. **Verify connectivity** to confirm changes work as intended

See CLAUDE.local.md for the specific rsync command and remote paths.

## Composable Module Design

Prefer composition over conditionals. Instead of adding hostname checks inside modules, create separate modules and compose them per-host in `flake.nix`.

**Avoid:**
```nix
# Inside a module - checking hostname is a code smell
isM4 = hostname == "Callums-MacBook-Pro";
packages = lib.optionals isM4 [ expensive-package ];
```

**Prefer:**
```nix
# modules/local-dev.nix - separate module for local-only packages
{ pkgs-unstable, ... }: {
  home.packages = [ pkgs-unstable.expensive-package ];
}

# flake.nix - compose at the host level
darwinConfigurations.m4.modules = [ ./modules/local-dev.nix ];  # included
darwinConfigurations.mini.modules = [ ];  # not included
```

Key modules:
- `home/` - shared home-manager config for all hosts
- `home/mini-sops.nix` - mini-specific secrets management
- `modules/future_search.nix` - local dev packages (slow builds, not needed on servers)

## Skills Documentation

When documenting solutions in skill files, link to related skills rather than duplicating information. Reference format: `(see skill: <skill-name>, "<section>" section)`. This keeps documentation DRY and makes updates easier to maintain.
