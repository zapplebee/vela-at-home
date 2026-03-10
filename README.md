# vela-at-home

Single-node [Vela CI/CD](https://go-vela.github.io/docs/) stack for nyx.

Runs on Docker Compose. Connects to GitHub via OAuth. Executes builds locally using Docker.

## Services

| Container | Image | Purpose |
|---|---|---|
| `vela-server` | `ghcr.io/go-vela/server:v0.27.5` | API server, build scheduler |
| `vela-worker` | `ghcr.io/go-vela/worker:v0.27.3` | Build executor (uses host Docker) |
| `vela-ui` | `ghcr.io/go-vela/ui:v0.28.0` | Web interface |
| `vela-postgres` | `postgres:15-alpine` | Persistent storage |
| `vela-redis` | `redis:7-alpine` | Build queue |

## Quick start

```bash
# 1. Generate secrets
bash scripts/gen-secrets.sh

# 2. Create GitHub OAuth app → docs/github-oauth.md
#    Then fill in SCM_CLIENT and SCM_SECRET in .env

# 3. Update URLs in .env

# 4. Start
docker compose up -d
```

Full instructions: **[docs/setup.md](docs/setup.md)**

## Ports

| Port | Service |
|---|---|
| `3500` | Vela API server |
| `3501` | Vela UI |

Both are accessible via Tailscale. Port 3500 needs Tailscale Funnel for the GitHub OAuth callback — see [docs/github-oauth.md](docs/github-oauth.md).

## Docs

- [Setup guide](docs/setup.md)
- [GitHub OAuth app setup](docs/github-oauth.md)
- [Maintenance — updates, backups, troubleshooting](docs/maintenance.md)

## Writing pipelines

Add a `.vela.yml` to any enabled repo:

```yaml
version: "1"

steps:
  - name: test
    image: node:20-alpine
    commands:
      - npm ci
      - npm test
```

Full pipeline reference: https://go-vela.github.io/docs/reference/yaml/
