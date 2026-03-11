# vela-at-home

Single-node [Vela CI/CD](https://go-vela.github.io/docs/) stack for nyx.

Runs on Docker Compose. Connects to GitHub via OAuth. Executes builds locally using Docker.

## Services

| Container | Image | Purpose |
|---|---|---|
| `vela-server` | `target/vela-server:v0.27.3` | API server, build scheduler |
| `vela-worker` | `target/vela-worker:v0.27.3` | Build executor (uses host Docker) |
| `vela-ui` | `target/vela-ui:v0.27.3` | Web interface |
| `vela-postgres` | `postgres:15-alpine` | Persistent storage |
| `vela-redis` | `redis:7-alpine` | Build queue |

## Quick start

```bash
# 1. Generate secrets
bash scripts/gen-secrets.sh

# 2. Create GitHub OAuth app → docs/github-oauth.md
#    Create GitHub App → docs/github-app.md
#    Fill in SCM_* values in .env

# 3. Update URLs in .env

# 4. Start
docker compose up -d
```

Full instructions: **[docs/setup.md](docs/setup.md)**

## Access

Served at `https://vela.prettybird.zapplebee.online` via Traefik reverse proxy with Let's Encrypt TLS.

## Docs

- [Setup guide](docs/setup.md)
- [GitHub OAuth app setup](docs/github-oauth.md)
- [GitHub App setup](docs/github-app.md)
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
