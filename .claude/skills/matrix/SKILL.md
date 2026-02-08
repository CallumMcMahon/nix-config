---
name: Matrix Homeserver & WhatsApp Bridge
description: Manage tuwunel Matrix homeserver and mautrix-whatsapp bridge on the Mac Mini.
---

# Matrix Homeserver & WhatsApp Bridge

## Architecture

```
Caddy (proxy_network)
  |
  ├── matrix.callums-server.co.uk --> tuwunel:6167 (Matrix API)
  └── callums-server.co.uk/.well-known/matrix/* --> static JSON (delegation)

tuwunel:6167 (Matrix homeserver, embedded RocksDB)
      |
 matrix_network (internal)
      |
 mautrix-whatsapp:29318 (WhatsApp bridge)
      |
 matrix-postgres:5432 (bridge DB only)
```

- **Server name**: `callums-server.co.uk` (permanent, baked into user IDs like `@callum:callums-server.co.uk`)
- **Matrix API**: `https://matrix.callums-server.co.uk`
- **Federation**: disabled
- **Admin user**: `@callum:callums-server.co.uk`
- **Registration**: disabled (re-enable temporarily in compose if needed)

## File Locations

| What | Path |
|------|------|
| Docker Compose | `composes/matrix/docker-compose.yaml` |
| Sops secrets | `composes/matrix/secrets.yaml` |
| Caddy routes | `composes/caddy-internal/Caddyfile.internal` |
| Tuwunel data | `/Volumes/mini4/matrix/tuwunel/` (on mini) |
| Postgres data | `/Volumes/mini4/matrix/postgres/` (on mini) |
| Bridge config | `/Volumes/mini4/matrix/mautrix-whatsapp/config.yaml` (on mini) |
| Bridge registration | `/Volumes/mini4/matrix/mautrix-whatsapp/registration.yaml` (on mini) |

## Managing the Stack

All `docker compose` commands need secrets injected via sops (see skill: `deployment`, "Editing Secrets" section):

```bash
# Start / recreate
ssh mini "cd ~/nix-config/composes/matrix && sops exec-env secrets.yaml 'docker compose up -d'"

# Restart a single service
ssh mini "cd ~/nix-config/composes/matrix && docker compose restart mautrix-whatsapp"

# Stop everything
ssh mini "cd ~/nix-config/composes/matrix && docker compose down"

# View logs
ssh mini "docker logs tuwunel --tail 20"
ssh mini "docker logs mautrix-whatsapp --tail 20"
ssh mini "docker logs matrix-postgres --tail 20"
```

Note: only `up` requires `sops exec-env` (for `${POSTGRES_PASSWORD}` interpolation). Other commands work without it.

## Secrets

Postgres password is stored in `composes/matrix/secrets.yaml`, encrypted with sops for both m4 and mini age keys (creation rule: `composes/.*/secrets\.yaml$` in `.sops.yaml`).

```bash
# Edit secrets
sops composes/matrix/secrets.yaml

# View decrypted
sops decrypt composes/matrix/secrets.yaml
```

## Bridge Config

The bridge config lives on the mini at `/Volumes/mini4/matrix/mautrix-whatsapp/config.yaml` (not in git). Key settings:

- `homeserver.address`: `http://tuwunel:6167`
- `homeserver.domain`: `callums-server.co.uk`
- `appservice.address`: `http://mautrix-whatsapp:29318`
- `appservice.hostname`: `0.0.0.0`
- `database.uri`: `postgres://mautrix:<PASSWORD>@matrix-postgres:5432/mautrix_whatsapp?sslmode=disable`
- `encryption.allow`: `true`
- `encryption.default`: `true`
- `bridge.permissions`: `@callum:callums-server.co.uk` = admin
- File logging is disabled (macOS volume chown issue); logs go to stdout only

## Appservice Registration

The bridge appservice is registered with tuwunel via the `#admins` room. If re-registration is needed:

1. Generate a new `registration.yaml`: `docker compose run --rm mautrix-whatsapp`
2. Send `!admin appservices register` with the YAML contents in a code block to the `#admins` room via the Matrix API or a client

## WhatsApp Pairing

Message `@whatsappbot:callums-server.co.uk` in Element X:
- `login --phone` — pair via phone number (use this on mobile since QR can't be scanned on the same device)
- `login` — pair via QR code (for desktop clients)

## Bridge Behaviour

The bridge is a **passive mirror**. It only sends messages to WhatsApp when you explicitly type in a bridged Matrix room. It will not:
- Auto-reply to messages
- Send join/presence notifications
- Send read receipts (unless `force_active_delivery_receipts` is enabled, which it isn't)
- Notify contacts about the bridge's existence

Accepting room invites (including group chats and communities) only grants Matrix-side visibility. Nothing is sent back to WhatsApp.

## Maintenance

- **Restarts** are safe — the WhatsApp session persists in postgres. No re-pairing needed.
- **Phone must come online** within ~14 days or WhatsApp disconnects linked devices.
- **Image updates**: `docker compose pull && sops exec-env secrets.yaml 'docker compose up -d'`. Check release notes before updating tuwunel (young software).
- **Backups**: back up `/Volumes/mini4/matrix/` — losing postgres means re-pairing WhatsApp; losing tuwunel data means losing all Matrix history.

## Troubleshooting

### Bridge encryption error
Element X encrypts by default. If the bridge reports "not configured to support encryption", ensure `encryption.allow` and `encryption.default` are `true` in the bridge config and restart.

### TLS cert not obtaining for new domains
Caddy uses Cloudflare DNS-01 challenge. For apex domains, add `propagation_delay 30s` to the tls block to avoid negative DNS cache issues with Google DNS (8.8.8.8).

### Bridge can't connect to postgres
Check the password in the bridge config matches the sops secret. The bridge config on the mini is not managed by sops — the password is in plaintext there.

### WhatsApp disconnected
Re-pair by messaging the bridge bot with `login --phone`. This happens if: the phone was offline >14 days, you manually unlinked from WhatsApp settings, or WhatsApp revoked the session.

## Caddy Routes

Two blocks in `Caddyfile.internal` (see skill: `caddy-deploy`):
- `matrix.callums-server.co.uk` — reverse proxy to `tuwunel:6167`
- `callums-server.co.uk` — serves `.well-known/matrix/client` and `.well-known/matrix/server` delegation JSON, 404 for everything else
