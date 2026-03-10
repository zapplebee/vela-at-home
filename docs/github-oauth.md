# GitHub OAuth App Setup

Vela uses a GitHub OAuth app to authenticate users and receive webhooks.

## Create the app

1. Go to **GitHub → Settings → Developer settings → OAuth Apps → New OAuth App**
   (or https://github.com/settings/applications/new)

2. Fill in the fields:

   | Field | Value |
   |---|---|
   | **Application name** | `Vela at Home` (or anything) |
   | **Homepage URL** | `https://nyx.anchovy-scylla.ts.net:3500` |
   | **Authorization callback URL** | `https://nyx.anchovy-scylla.ts.net:3500/authenticate` |

   > Replace `nyx.anchovy-scylla.ts.net` with your Tailscale hostname if different.
   > The callback URL **must** end in `/authenticate` — that is Vela's OAuth handler path.

3. Click **Register application**.

4. On the next page, copy the **Client ID**.

5. Click **Generate a new client secret** and copy the secret immediately (it won't be shown again).

## Add to .env

Open `.env` and set:

```
SCM_CLIENT=<your client ID>
SCM_SECRET=<your client secret>
```

## Make the server reachable for OAuth

GitHub needs to redirect the browser back to `VELA_ADDR/authenticate` after login. This address must be reachable from your device during the OAuth flow.

**Option A — Tailscale VPN only (simplest):**
- Set `VELA_ADDR=http://nyx:3500` (or the Tailscale IP)
- Works as long as the browser doing the login is on the Tailscale network
- Does **not** require Tailscale Funnel

**Option B — Tailscale Funnel (accessible from any device/browser):**
```bash
tailscale funnel --bg 3500
```
- Set `VELA_ADDR=https://nyx.anchovy-scylla.ts.net:3500`
- Update the callback URL in the GitHub OAuth app to match
- You can turn off Funnel after initial setup if you only use Vela from within Tailscale

## Webhook delivery (optional)

For Vela to trigger builds on push/PR, GitHub needs to call the Vela server's webhook endpoint. This requires the server to be publicly reachable (Funnel), or you can trigger builds manually from the UI.

If you want automatic webhook triggers:
- Keep `tailscale funnel --bg 3500` running
- Vela registers webhooks automatically when you enable a repo in the UI
