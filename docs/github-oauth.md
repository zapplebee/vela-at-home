# GitHub OAuth App Setup

Vela uses a GitHub OAuth app to authenticate users and receive webhooks.

## Create the app

1. Go to **GitHub → Settings → Developer settings → OAuth Apps → New OAuth App**
   (or https://github.com/settings/applications/new)

2. Fill in the fields:

   | Field | Value |
   |---|---|
   | **Application name** | `Vela at Home` |
   | **Homepage URL** | `https://vela.prettybird.zapplebee.online` |
   | **Authorization callback URL** | `https://vela.prettybird.zapplebee.online/authenticate` |

   > The callback URL **must** end in `/authenticate` — that is Vela's OAuth handler path.

3. Click **Register application**.

4. On the next page, copy the **Client ID**.

5. Click **Generate a new client secret** and copy the secret (it won't be shown again).

## Add to .env

```
SCM_CLIENT=<your client ID>
SCM_SECRET=<your client secret>
```

## Webhooks

Vela registers webhooks automatically when you enable a repo in the UI. Since `vela.prettybird.zapplebee.online` is publicly reachable via the UDM Pro port forwarding and Traefik, webhook delivery works out of the box — no extra configuration needed.
