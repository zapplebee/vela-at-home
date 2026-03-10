# Maintenance

## Day-to-day operations

### Start / stop

```bash
# Start all services
docker compose up -d

# Stop all services (data is preserved in the postgres_data volume)
docker compose down

# Restart a single service
docker compose restart vela-server
```

### View logs

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f vela-server
docker compose logs -f vela-worker
```

### Check service health

```bash
docker compose ps
```

All services should be in the `running` state. If `vela-worker` shows repeated restarts, check:
```bash
docker compose logs vela-worker --tail 50
```

---

## Updates

### Update image versions

Pinned versions are in `docker-compose.yml`. Check the go-vela releases page for new versions:

- https://github.com/go-vela/server/releases
- https://github.com/go-vela/worker/releases
- https://github.com/go-vela/ui/releases

Update the image tags in `docker-compose.yml`, then:

```bash
docker compose pull
docker compose up -d
```

Always update `server`, `worker`, and `ui` together — they must be on matching minor versions (e.g., all v0.27.x).

### Check current versions

```bash
docker compose images
```

---

## Backups

The only stateful data is in the `postgres_data` Docker volume.

### Dump the database

```bash
docker compose exec postgres pg_dump -U vela vela > vela-backup-$(date +%Y%m%d).sql
```

### Restore from a dump

```bash
# Stop the server and worker first
docker compose stop vela-server vela-worker

# Restore
cat vela-backup-YYYYMMDD.sql | docker compose exec -T postgres psql -U vela vela

# Restart
docker compose start vela-server vela-worker
```

### Back up .env

Your `.env` file contains all secrets. Keep a copy somewhere safe (password manager, encrypted drive). If you lose it, you'll need to regenerate secrets and re-register workers and OAuth apps.

---

## Disk usage

Build logs are stored in PostgreSQL. Over time this can grow. To check volume size:

```bash
docker system df -v | grep vela
```

The go-vela server has no built-in log retention policy in this setup. If disk usage becomes a concern, you can truncate old build logs directly in the database:

```bash
docker compose exec postgres psql -U vela vela -c \
  "DELETE FROM logs WHERE created < NOW() - INTERVAL '90 days';"
```

---

## Resetting everything

To wipe all data and start fresh:

```bash
docker compose down -v   # removes containers AND the postgres_data volume
```

Then follow the setup guide from Step 6.

---

## Troubleshooting

### Worker can't connect to server

```bash
docker compose logs vela-worker --tail 30
```

Common causes:
- Server not fully started yet — wait 30 seconds and check again
- `VELA_SHARED_SECRET` mismatch between server and worker in `.env`
- `VELA_SERVER_ADDR` in docker-compose.yml should be `http://server:8080` (internal Docker DNS, not a host port)

### OAuth redirect fails

- Verify `VELA_ADDR` in `.env` matches the callback URL in your GitHub OAuth app
- Confirm Tailscale Funnel is running: `tailscale funnel status`
- Check the server logs: `docker compose logs vela-server --tail 50`

### Builds queue but never start

- Check worker logs for errors
- Confirm the worker registered: in the Vela UI, go to **Admin → Workers**
- Confirm Docker socket is accessible: `docker compose exec vela-worker docker ps`

### PostgreSQL won't start

- Check for disk space: `df -h`
- Check logs: `docker compose logs postgres`
- If the data volume is corrupt, you may need to remove it and restore from backup:
  ```bash
  docker compose down
  docker volume rm vela-at-home_postgres_data
  docker compose up -d
  # then restore from your last dump
  ```
