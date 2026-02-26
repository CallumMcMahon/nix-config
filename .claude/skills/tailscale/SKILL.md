---
name: Tailscale Network Configuration
description: Tailscale ACL policy, exit node setup, and per-host client configuration
---

# Tailscale Network Configuration

## Overview

Tailscale provides private networking between all machines. ACL policy is managed at https://login.tailscale.com/admin/acls (not in Nix config). API tokens can be generated at https://login.tailscale.com/admin/settings/keys (free tier supports them; delete after use).

## ACL Policy

Deny-by-default. Only `autogroup:member` (personal devices) can initiate connections.

### Tags

| Tag | Assigned To | Purpose |
|---|---|---|
| `tag:exit-node` | Mac Mini | Auto-approves exit node routes |
| `tag:server` | Hetzner | Untrusted server — no outbound tailnet access |
| `tag:mac` | (app connector) | Routes myanonamouse.net traffic |

### Rules

- `autogroup:member` → `*:*` — personal devices can reach everything
- No rule for `tag:server` — Hetzner cannot initiate connections to any tailnet device (can only respond to incoming connections)
- SSH: `autogroup:member` can SSH to `autogroup:self` devices (check mode, nonroot + root)

### Auto-Approvers

Exit node routes are auto-approved for `tag:exit-node` devices, removing the need to manually approve in the admin console.

## Exit Node (Mac Mini)

The Mac Mini acts as an exit node so other devices can route internet traffic through its UK connection (Virgin Media, Europe/London).

### Server-side setup (Mini)

- Nix-managed `tailscaled` via `services.tailscale` in `flake.nix`
- Advertises as exit node: `tailscale set --advertise-exit-node`
- IP forwarding enabled persistently via `launchd.daemons.ip-forwarding` in `flake.nix` (Mini's inline config)

### Client-side setup (M4)

- Uses the **macOS Tailscale app** (installed manually via App Store), not Nix-managed tailscaled
- The CLI daemon (`tailscaled`) cannot override macOS routing for exit nodes — it needs the app's Network Extension
- Exit node is selected from the Tailscale menu bar icon
- Documented with a comment in the M4 section of `flake.nix`

## Security Model

- **Hetzner is untrusted**: tagged `tag:server` with no outbound ACL rules. Even if compromised, it cannot reach other tailnet devices or use the exit node.
- **Exit node access**: only `autogroup:member` devices (which have `autogroup:internet` access) can use exit nodes. Tagged devices (`tag:server`) cannot.
