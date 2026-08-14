# Monitoring Runbook

**Last updated:** 2026-08-10  
**Paid APM not required for Sprint 12**

---

## Minimum production monitoring

| Signal | Check | Alert threshold (suggested) |
|--------|-------|----------------------------|
| API health | `GET /health` | Non-200 or `database != connected` |
| Backend process | systemd / PM2 / container health | Process down |
| Database | Health endpoint + connection pool errors | Sustained failures |
| API error rate | Reverse proxy / app logs (5xx) | **NEEDS BUSINESS DECISION** |
| Payment failures | Audit logs + `payment.failed` notifications | Spike vs baseline |
| OTP failures | 401/400 on `/auth/otp/verify`, rate-limit 429 | Spike vs baseline |
| Notification failures | Meta status `FAILED`, dispatcher logs | > 0 sustained |
| Disk / uploads | `uploads/` volume | > 80% capacity |

---

## Health endpoint

```
GET /health
```

Expected:

```json
{
  "success": true,
  "data": {
    "status": "ok",
    "database": "connected",
    "timestamp": "..."
  }
}
```

---

## Logging (backend)

- **Framework:** NestJS + Pino (`nestjs-pino`)
- Structured JSON logs in production (configure log transport at deploy time)
- Request errors logged by exception filters
- Auth failures: `AuthService` / guards (no password in logs)
- Payment errors: finance module + `UnprocessableEntityException`
- Notification dispatch: `NotificationDispatcherService` (channel-level status in meta)

### Never log

- Passwords
- Plaintext OTP (suppressed in production in `OtpService`)
- JWT / refresh tokens
- Payment secrets / webhook signatures
- Database passwords
- Full `Authorization` headers

---

## On-call actions

### Health check failing

1. Check database connectivity and credentials
2. Check migration status (`prisma migrate status`)
3. Restart backend process
4. Review recent deploy logs

### Payment webhook failures (future)

1. Verify HTTPS endpoint reachable
2. Validate signature secret matches provider dashboard
3. Replay idempotent events from provider console

### OTP delivery failures (future)

1. Verify provider credentials and sender ID
2. Check rate-limit metrics
3. Confirm `APP_ENV=production` (no dev log fallback)

### Notification backlog

1. Check outlet toggles (`notification.settings` in system settings)
2. Verify template `isActive` in admin settings
3. Inspect `systemSetting` keys `notification.customer.*` / `notification.employee.*`

---

## Log retention

**NEEDS BUSINESS/LEGAL DECISION** for retention period and PII redaction policy.
