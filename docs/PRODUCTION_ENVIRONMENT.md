# Production Environment Variables

**Project:** Yelo Laundry ERP  
**Last updated:** 2026-08-10  
**Rule:** Never commit real production values. Use placeholders only in templates.

---

## Overview

| Environment | Purpose | Config source |
|-------------|---------|---------------|
| LOCAL | Developer machines | `.env` (gitignored) |
| STAGING | Pre-production smoke / UAT | Deployment secret store |
| PRODUCTION | Live operations | Deployment secret store |

---

## Backend (NestJS)

| Variable | Required | Description |
|----------|----------|-------------|
| `DATABASE_URL` | Yes | PostgreSQL connection string. Example: `<PRODUCTION_SECRET>` |
| `JWT_SECRET` | Yes | Access token signing secret. Example: `<PRODUCTION_SECRET>` |
| `REFRESH_TOKEN_SECRET` | Yes | Refresh token signing secret. Example: `<PRODUCTION_SECRET>` |
| `JWT_EXPIRES_IN` | No | Access token TTL (default `7d`) |
| `REFRESH_TOKEN_EXPIRES_IN` | No | Refresh token TTL (default `30d`) |
| `APP_NAME` | No | Application display name |
| `APP_ENV` | Yes (prod) | Set `production` in production |
| `APP_PORT` | No | HTTP port (default `3000`) |
| `API_PREFIX` | No | API path prefix (default `api/v1`) |
| `CORS_ORIGINS` | Yes (prod) | Comma-separated allowed origins. Example: `<ADMIN_PRODUCTION_DOMAIN>` |
| `BODY_LIMIT` | No | Max JSON body size (default `10mb`) |
| `REDIS_HOST` | No | Redis host if/when used (default `localhost`) |
| `REDIS_PORT` | No | Redis port (default `6379`) |
| `OTP_LENGTH` | No | OTP digit length (default `6`) |
| `OTP_EXPIRED_MINUTES` | No | OTP expiry window |
| `WHATSAPP_API_KEY` | External | OTP/SMS delivery provider key — **EXTERNAL DEPENDENCY** |
| `WHATSAPP_BASE_URL` | External | OTP/SMS provider API base URL |
| `R2_ACCOUNT_ID` | Future | Cloudflare R2 account (reserved; local uploads used today) |
| `R2_ACCESS_KEY` | Future | R2 access key |
| `R2_SECRET_KEY` | Future | R2 secret key |
| `R2_BUCKET` | Future | R2 bucket name |
| `PAYMENT_PROVIDER` | External | Payment gateway identifier — **EXTERNAL DEPENDENCY** |
| `PAYMENT_MERCHANT_ID` | External | Merchant / store ID |
| `PAYMENT_API_KEY` | External | Gateway API key |
| `PAYMENT_SECRET` | External | Gateway API secret |
| `PAYMENT_WEBHOOK_SECRET` | External | Webhook signature verification secret |
| `PAYMENT_WEBHOOK_URL` | External | Public webhook URL registered at provider |

### LOCAL example

```env
DATABASE_URL=<LOCAL_POSTGRES_URL>
JWT_SECRET=<LOCAL_DEV_SECRET>
REFRESH_TOKEN_SECRET=<LOCAL_DEV_SECRET>
APP_ENV=development
CORS_ORIGINS=http://localhost:3000,http://localhost:3001,http://localhost:5173
```

### STAGING example

```env
APP_ENV=production
DATABASE_URL=<STAGING_SECRET>
JWT_SECRET=<STAGING_SECRET>
REFRESH_TOKEN_SECRET=<STAGING_SECRET>
CORS_ORIGINS=https://admin-staging.example.com
```

### PRODUCTION example

```env
APP_ENV=production
DATABASE_URL=<PRODUCTION_SECRET>
JWT_SECRET=<PRODUCTION_SECRET>
REFRESH_TOKEN_SECRET=<PRODUCTION_SECRET>
CORS_ORIGINS=<ADMIN_PRODUCTION_DOMAIN>
API_PREFIX=api/v1
```

---

## Admin Web (Next.js)

| Variable | Required | Description |
|----------|----------|-------------|
| `NEXT_PUBLIC_API_BASE_URL` | Yes (prod) | Backend API URL. Example: `https://api.example.com/api/v1` |

### LOCAL

```env
NEXT_PUBLIC_API_BASE_URL=http://localhost:3000/api/v1
```

### PRODUCTION

```env
NEXT_PUBLIC_API_BASE_URL=<PRODUCTION_API_URL>
```

---

## Customer Flutter App

| Build define | Required (release) | Description |
|--------------|-------------------|-------------|
| `API_BASE_URL` | Yes | Full API base including `/api/v1` |
| `GOOGLE_MAPS_API_KEY` | Optional | Maps (Android `local.properties` or env) |

Release builds must **not** rely on `localhost`, `127.0.0.1`, or `10.0.2.2` defaults.

---

## Staff Flutter App

| Build define | Required (release) | Description |
|--------------|-------------------|-------------|
| `API_BASE_URL` | Yes | Full API base including `/api/v1` |

Staff release builds must pass `--dart-define=API_BASE_URL=...`. Debug builds may fall back to emulator loopback.

---

## Security notes

- Wildcard CORS (`*`) is **not** used; origins are explicit via `CORS_ORIGINS`.
- OTP plaintext is logged only when `APP_ENV !== 'production'` (see `OtpService`).
- Payment gateway webhook credentials are not implemented in code yet.
- No production secrets were found hardcoded in application source during Sprint 12 audit.
