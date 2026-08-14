# Database Backup & Restore

**Last updated:** 2026-08-10  
**Scope:** PostgreSQL (Prisma)

---

## Backup command

```bash
# Recommended naming: yelo_<env>_YYYYMMDD_HHMMSS.dump
pg_dump "$DATABASE_URL" \
  --format=custom \
  --no-owner \
  --file="backups/yelo_production_$(date +%Y%m%d_%H%M%S).dump"
```

### If `pg_dump` rejects query parameters in URL

Prisma often uses URLs like `postgresql://user:pass@host:5432/db?schema=public`.  
`pg_dump` on PostgreSQL 16 accepts this URL in local verification (Sprint 12 PASS).

If a host rejects query params, strip them for backup only:

```bash
DATABASE_URL_BACKUP="${DATABASE_URL%%\?*}"
pg_dump "$DATABASE_URL_BACKUP" --format=custom --no-owner --file="backups/..."
```

Keep `DATABASE_URL` unchanged for the application.

---

## Naming convention

```
backups/yelo_<environment>_YYYYMMDD_HHMMSS.dump
```

Example: `backups/yelo_sprint9_20260810_113355.dump` (existing local backup)

---

## Secure storage

- Encrypt backups at rest (S3 SSE, GPG, or provider equivalent)
- Restrict access to owner/DBA roles
- Never commit `.dump` files to git (already gitignored via `backups/` policy — verify before commit)
- Rotate retention per business policy (**NEEDS BUSINESS/LEGAL DECISION**)

---

## Restore (isolated environment only)

**Never run destructive restore against production without maintenance window and approval.**

```bash
# 1. Create empty database (staging/restore sandbox)
createdb yelo_restore_test

# 2. Restore
pg_restore \
  --dbname="postgresql://<USER>:<PASSWORD>@<HOST>:5432/yelo_restore_test" \
  --no-owner \
  --clean \
  --if-exists \
  backups/yelo_production_YYYYMMDD_HHMMSS.dump

# 3. Verify migrations state
cd /path/to/yelo_laundry_erp
DATABASE_URL="postgresql://..." npx prisma migrate status
```

---

## Post-restore verification

1. `npx prisma migrate status` — should show all migrations applied
2. `GET /health` — database connected
3. Spot-check row counts: customers, orders, payments
4. Run read-only smoke tests (login, list orders)

---

## Integrity checks

```sql
-- Example: orphaned payments (adjust as needed)
SELECT COUNT(*) FROM payments p
LEFT JOIN orders o ON o.id = p.order_id
WHERE o.id IS NULL;
```

---

## Production backup schedule

Automated scheduled backups on VPS/cloud remain an **EXTERNAL DEPLOYMENT TASK**.  
Procedure above is **READY** for operations team.
