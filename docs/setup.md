# Setup Guide

Complete steps for getting Vela running on nyx from scratch.

## Prerequisites

- Docker Engine installed (`docker compose version` should work)
- Tailscale installed and authenticated
- `openssl` available (`apt install openssl` if not)
- A GitHub account

## Step 1 — Clone this repo

```bash
cd ~/github.com/zapplebee
git clone https://github.com/zapplebee/vela-at-home.git
cd vela-at-home
```

## Step 2 — Generate secrets

```bash
bash scripts/gen-secrets.sh
```

This creates a `.env` file with random values for all cryptographic secrets. The file is gitignored — never commit it.

## Step 3 — Create the GitHub OAuth app

Follow **docs/github-oauth.md** to create the OAuth app and get your `SCM_CLIENT` and `SCM_SECRET`.

## Step 4 — Update .env URLs

Open `.env` and set the three URL fields to match your nyx setup:

```
VELA_ADDR=https://nyx.anchovy-scylla.ts.net:3500
VELA_WEBUI_ADDR=http://nyx:3501
VELA_API=https://nyx.anchovy-scylla.ts.net:3500
```

- `VELA_ADDR` — the server API, must be reachable by GitHub for OAuth callback
- `VELA_WEBUI_ADDR` — the UI, only needs to be reachable by you
- `VELA_API` — the URL the UI's JavaScript uses to call the API (set equal to `VELA_ADDR`)

## Step 5 — Expose port 3500 via Tailscale Funnel (for OAuth)

GitHub needs to reach the server to complete the OAuth flow:

```bash
tailscale funnel --bg 3500
```

You can disable this after initial setup if you only use Vela from devices on Tailscale.

## Step 6 — Start the stack

```bash
docker compose up -d
```

Check that all services came up:

```bash
docker compose ps
```

All services should show `Up`. The `vela-worker` may show a brief restart loop while it waits for the server to be ready — this is normal and resolves within 30 seconds.

## Step 7 — Log in

Open the Vela UI in your browser:

```
http://nyx:3501
```

Click **Login with GitHub** and complete the OAuth flow. The first user to log in becomes the admin.

## Step 8 — Enable a repo

1. In the Vela UI, click **Add Repositories**
2. Find a repo you want to run CI on
3. Click **Enable**

Vela will add a webhook to the GitHub repo automatically. On the next push, a build will be queued.

## Step 9 — Add a .vela.yml to a repo

In any enabled repo, create `.vela.yml` at the root:

```yaml
version: "1"

steps:
  - name: echo
    image: alpine
    commands:
      - echo "Hello from Vela on nyx!"
```

Push the file to trigger a build.

## Port reference

| Service | Host port | Notes |
|---|---|---|
| Vela API server | 3500 | Used by the worker and browser for OAuth |
| Vela UI | 3501 | Web interface |
| PostgreSQL | — | Internal only, not exposed |
| Redis | — | Internal only, not exposed |
