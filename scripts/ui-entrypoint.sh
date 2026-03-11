#!/bin/sh
# Substitute env vars into the JS bundle, then install our custom nginx
# config (static file server only — no proxy_pass) and start nginx.
set -eu

for f in /usr/share/nginx/html/*.js; do
    envsubst '${VELA_API},${VELA_DOCS_URL},${VELA_FEEDBACK_URL},${VELA_MAX_BUILD_LIMIT},${VELA_MAX_STARLARK_EXEC_LIMIT},${VELA_SCHEDULE_ALLOWLIST}' \
        < "$f" > "$f.tmp" && mv "$f.tmp" "$f"
done

cp /ui-nginx.conf /etc/nginx/conf.d/default.conf

exec nginx -g 'daemon off;'
