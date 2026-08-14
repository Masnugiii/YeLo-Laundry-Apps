# Database Deployment (Prisma)

**Last updated:** 2026-08-10

---

## Migration inventory

Sequential migrations under `prisma/migrations/`:

| Migration | Purpose |
|-----------|---------|
| `20260808120300_init` | Core schema |
| `20260808140000_add_finance_permission` | Finance RBAC |
| `20260808150000_add_payroll_engine` | Payroll |
| `20260808160000_add_loyalty_platform` | Loyalty |
| `20260809100000_add_numbering_sequences` | Document numbering |
| `20260809120000_add_customer_age_occupation` | Customer profile |
| `20260809130000_add_loyalty_voucher_promo_fields` | Promo/voucher |
| `20260809140000_add_cs_ticket_order_id` | CS tickets |
| `20260810100000_sprint5_features` | Sprint 5 features |

Sprint 12 audit: migrations are sequential; no unexpected `DROP TABLE` in recent migrations.

---

## Safe production deployment sequence

```bash
# 1. Backup (see DATABASE_BACKUP_RESTORE.md)
pg_dump "$DATABASE_URL" --format=custom --no-owner -f backups/pre_deploy_$(date +%Y%m%d_%H%M%S).dump

# 2. Apply migrations (never use migrate reset on production)
npx prisma migrate deploy

# 3. Verify
npx prisma migrate status

# 4. Deploy application
npm run build
npm run start:prod

# 5. Smoke test
curl -s https://<API_HOST>/health
```

---

## Commands

| Command | Production use |
|---------|----------------|
| `npx prisma migrate deploy` | **YES** — apply pending migrations |
| `npx prisma migrate status` | **YES** — verify state |
| `npx prisma db seed` | **CAUTION** — dev/UAT only; seed creates demo employees |
| `npx prisma migrate reset` | **NO** — destroys data |

---

## Seed behavior

`prisma/seed.ts` creates demo staff accounts and master data. **Do not run against production** unless intentionally bootstrapping a new environment with controlled credentials.

---

## Rollback strategy

Prisma does not auto-rollback migrations. Options:

1. Restore from pre-deploy backup (preferred)
2. Forward-fix with a new migration

Document rollback decision in change ticket.
