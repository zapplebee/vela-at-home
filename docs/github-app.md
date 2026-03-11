# GitHub App Setup

Vela ≥v0.27 uses a GitHub App for webhook delivery. The OAuth App (see
`github-oauth.md`) handles user authentication; the GitHub App handles
receiving push/PR/tag events and triggering builds.

## Create the app

1. Go to **GitHub → Settings → Developer settings → GitHub Apps → New GitHub App**

2. Fill in the fields:

   | Field | Value |
   |---|---|
   | **GitHub App name** | `Vela at Home` |
   | **Homepage URL** | `https://vela.prettybird.zapplebee.online` |
   | **Webhook URL** | `https://vela.prettybird.zapplebee.online/webhook` |
   | **Webhook secret** | Run `openssl rand -hex 32` and paste the output |

3. **Repository permissions** (set each to the indicated level):

   | Permission | Level |
   |---|---|
   | Contents | Read |
   | Commit statuses | Read & Write |
   | Deployments | Read & Write |
   | Pull requests | Read & Write |
   | Metadata | Read (mandatory) |

4. **Subscribe to events**: check Push, Pull request, Create, Delete, Deployment

5. **Where can this GitHub App be installed?** → Only on this account

6. Click **Create GitHub App**.

## Get credentials

1. On the app page, note the **App ID** (a number like `1234567`).

2. Scroll down to **Private keys** → **Generate a private key**.
   A `.pem` file will download.

3. Base64-encode the key:
   ```bash
   base64 -w0 < ~/Downloads/vela-at-home.*.private-key.pem
   ```
   Copy the output — this is `SCM_APP_PRIVATE_KEY`.

## Add to .env

```
SCM_APP_ID=<your app ID>
SCM_APP_PRIVATE_KEY=<base64 encoded PEM>
SCM_APP_WEBHOOK_SECRET=<the secret you used when creating the app>
```

## Install the app on your repos

After restarting Vela with the app credentials, use the **Repair** button
in the Vela UI for each repo. This installs the GitHub App on the repo,
which is what tells GitHub to send webhook events to Vela.

You can also install it manually: GitHub App page → **Install App** →
select your account → choose repos.
