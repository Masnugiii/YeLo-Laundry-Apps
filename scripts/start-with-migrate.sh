#!/usr/bin/env sh
# Optional production start: apply migrations then boot.
# Prefer a direct (non-pooler) DATABASE_URL / DIRECT_URL for migrate deploy.
# Do not use this as the default Railway start if the only URL is a pooler
# that hangs migrate — use `node dist/main.js` and run migrate separately.
set -eu
if [ "${RUN_MIGRATE_ON_START:-false}" = "true" ]; then
  echo "Running prisma migrate deploy..."
  npx prisma migrate deploy
fi
exec node dist/main.js
