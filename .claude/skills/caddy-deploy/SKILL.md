---
name: caddy-deploy
description: Deploy Caddy reverse proxy changes to internal (Mac Mini) or external (Hetzner) servers.
---

# Caddy Reverse Proxy Deployment

## Workflow

1. **Make changes locally** in the nix-config repo
2. **Sync config repo to remote** (see CLAUDE.md "Deploying Config Changes to Remote Servers")
3. **Restart Caddy** container
4. **Verify connectivity** from local machine

## File Locations

| Environment | Caddyfile | Compose Directory |
|-------------|-----------|-------------------|
| Internal (Mac Mini) | `composes/caddy-internal/Caddyfile.internal` | `composes/caddy-internal/` |
| External (Hetzner) | `composes/caddy-hetzner/Caddyfile.hetzner` | `composes/caddy-hetzner/` |

## Adding a Reverse Proxy Entry

Follow the existing pattern in the Caddyfile:

```caddy
subdomain.callums-server.co.uk {
	reverse_proxy host.docker.internal:<port>
    tls {
        dns cloudflare {env.CLOUDFLARE_API_TOKEN}
        resolvers 8.8.8.8
	}
}
```

## Deployment Steps

1. **Sync config repo** to the remote server
2. **Restart Caddy:**
   - Internal: `ssh mini "cd <compose-dir>/caddy-internal && docker compose restart caddy"`
   - External: `ssh hetzner "cd <compose-dir>/caddy-hetzner && docker compose restart caddy"`
3. **Check logs** for certificate acquisition: `docker logs <container> --tail 10`
4. **Verify connectivity** from local machine: `curl -I https://subdomain.example.com`

## TLS Certificates

Caddy automatically obtains TLS certificates via Cloudflare DNS challenge. On first deploy of a new subdomain:
- Logs will show "obtaining certificate" and "trying to solve challenge"
- Wait ~10-15 seconds for certificate acquisition
- Logs should show "certificate obtained successfully"

## Troubleshooting

- **Certificate errors**: Check Cloudflare API token is valid
- **Connection refused**: Verify target service is running on specified port
- **502 Bad Gateway**: Target service unreachable from Caddy container; check `host.docker.internal` resolves correctly
