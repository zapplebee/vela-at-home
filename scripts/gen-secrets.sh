#!/usr/bin/env bash
# gen-secrets.sh — generate a .env file with secure random secrets.
# Run once during initial setup. Does not overwrite an existing .env.
#
# Usage:
#   bash scripts/gen-secrets.sh
#
# Requires: openssl

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
ENV_FILE="$ROOT_DIR/.env"
EXAMPLE_FILE="$ROOT_DIR/.env.example"

if [[ -f "$ENV_FILE" ]]; then
  echo "ERROR: $ENV_FILE already exists. Remove it first if you want to regenerate."
  exit 1
fi

command -v openssl >/dev/null 2>&1 || { echo "ERROR: openssl is required but not installed."; exit 1; }

echo "==> Generating secrets..."

# 32-char hex values
DATABASE_PASSWORD=$(openssl rand -hex 16)
DATABASE_ENCRYPTION_KEY=$(openssl rand -hex 16)
VELA_SERVER_PRIVATE_KEY=$(openssl rand -hex 16)
VELA_SHARED_SECRET=$(openssl rand -hex 16)

# 64-char hex value
CACHE_INSTALL_TOKEN_KEY=$(openssl rand -hex 32)

# Ed25519 keypair for queue signing
TMP_KEY=$(mktemp)
TMP_PUB=$(mktemp)
openssl genpkey -algorithm ed25519 -out "$TMP_KEY" 2>/dev/null
openssl pkey -in "$TMP_KEY" -pubout -out "$TMP_PUB" 2>/dev/null

# Extract raw key bytes: private key = last 32 bytes of PKCS8 DER (seed) + public = last 32 bytes of SubjectPublicKeyInfo DER
# Vela expects NaCl-style: private = 64 raw bytes (seed||pub) base64-encoded, public = 32 raw bytes base64-encoded
TMP_SEED=$(mktemp)
TMP_PUB_RAW=$(mktemp)
openssl pkey -in "$TMP_KEY" -outform DER 2>/dev/null | tail -c 32 > "$TMP_SEED"
openssl pkey -in "$TMP_PUB" -pubin -outform DER 2>/dev/null | tail -c 32 > "$TMP_PUB_RAW"
# NaCl private key = raw seed + raw pubkey (64 bytes total), then base64-encode
QUEUE_PRIVATE_KEY=$(cat "$TMP_SEED" "$TMP_PUB_RAW" | base64 | tr -d '\n')
QUEUE_PUBLIC_KEY=$(base64 < "$TMP_PUB_RAW" | tr -d '\n')
rm -f "$TMP_SEED" "$TMP_PUB_RAW"
rm -f "$TMP_KEY" "$TMP_PUB"

# Build DATABASE_ADDR with the generated password
DATABASE_ADDR="postgres://vela:${DATABASE_PASSWORD}@postgres:5432/vela?sslmode=disable"

echo "==> Writing $ENV_FILE..."

cp "$EXAMPLE_FILE" "$ENV_FILE"

# Replace placeholder values with generated secrets
sed -i "s|^DATABASE_PASSWORD=.*|DATABASE_PASSWORD=${DATABASE_PASSWORD}|" "$ENV_FILE"
sed -i "s|^DATABASE_ADDR=.*|DATABASE_ADDR=${DATABASE_ADDR}|" "$ENV_FILE"
sed -i "s|^DATABASE_ENCRYPTION_KEY=.*|DATABASE_ENCRYPTION_KEY=${DATABASE_ENCRYPTION_KEY}|" "$ENV_FILE"
sed -i "s|^CACHE_INSTALL_TOKEN_KEY=.*|CACHE_INSTALL_TOKEN_KEY=${CACHE_INSTALL_TOKEN_KEY}|" "$ENV_FILE"
sed -i "s|^QUEUE_PRIVATE_KEY=.*|QUEUE_PRIVATE_KEY=${QUEUE_PRIVATE_KEY}|" "$ENV_FILE"
sed -i "s|^QUEUE_PUBLIC_KEY=.*|QUEUE_PUBLIC_KEY=${QUEUE_PUBLIC_KEY}|" "$ENV_FILE"
sed -i "s|^VELA_SHARED_SECRET=.*|VELA_SHARED_SECRET=${VELA_SHARED_SECRET}|" "$ENV_FILE"
sed -i "s|^VELA_SERVER_PRIVATE_KEY=.*|VELA_SERVER_PRIVATE_KEY=${VELA_SERVER_PRIVATE_KEY}|" "$ENV_FILE"
sed -i "s|^VELA_SECRET=.*|VELA_SECRET=${VELA_SHARED_SECRET}|" "$ENV_FILE"
sed -i "s|^VELA_SERVER_SECRET=.*|VELA_SERVER_SECRET=${VELA_SHARED_SECRET}|" "$ENV_FILE"

echo ""
echo "==> Done. Secrets written to $ENV_FILE"
echo ""
echo "Next steps:"
echo "  1. Create a GitHub OAuth app (see docs/github-oauth.md)"
echo "  2. Fill in SCM_CLIENT and SCM_SECRET in .env"
echo "  3. Update VELA_ADDR / VELA_WEBUI_ADDR / VELA_API in .env"
echo "  4. Run: docker compose up -d"
