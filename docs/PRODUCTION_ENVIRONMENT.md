# Production Environment Variables

**Project:** Yelo Laundry ERP  
**Last updated:** 2026-08-14  
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

Validated at boot in `src/config/env.validation.ts`. Missing required values crash with:

`Environment validation failed: DATABASE_URL / JWT_SECRET / REFRESH_TOKEN_SECRET`

| Variable | Required | Description |
|----------|----------|-------------|
| `DATABASE_URL` | **Yes** | PostgreSQL URL. On Railway: reference the Postgres plugin variable. |
| `JWT_SECRET` | **Yes** | Access token signing secret. Generate a long random value. |
| `REFRESH_TOKEN_SECRET` | **Yes** | Refresh token signing secret. Must differ from `JWT_SECRET`. |
| `APP_ENV` | **Yes (prod)** | Set `production` on Railway. |
| `APP_HOST` | No | Default `0.0.0.0` (keep this on Railway). |
| `PORT` | Platform | Railway sets this. App reads `PORT` then `APP_PORT` then `3000`. |
| `APP_PORT` | No | Local HTTP port (default `3000`). Unused when Railway `PORT` is set. |
| `JWT_EXPIRES_IN` | No | Access token TTL (default `7d`) |
| `REFRESH_TOKEN_EXPIRES_IN` | No | Refresh token TTL (default `30d`) |
| `APP_NAME` | No | Application display name |
| `API_PREFIX` | No | API path prefix (default `api/v1`) |
| `CORS_ORIGINS` | **Yes (prod)** | Comma-separated Admin Web origins. Default is localhost only. |
| `BODY_LIMIT` | No | Max JSON body size (default `10mb`) |
| `REDIS_HOST` | No | Present in config; not used by NestJS services yet |
| `REDIS_PORT` | No | Present in config; not used by NestJS services yet |

Start command: `npm start` → `node dist/main.js` (after `npm run build`).

`WHATSAPP_*`, `R2_*`, `PAYMENT_*`, `OTP_LENGTH` are **not** read by NestJS `src/` today. They are not boot requirements.

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
APP_HOST=0.0.0.0
DATABASE_URL=<PRODUCTION_SECRET>
JWT_SECRET=<PRODUCTION_SECRET>
REFRESH_TOKEN_SECRET=<PRODUCTION_SECRET>
CORS_ORIGINS=https://ye-lo-laundry-apps.vercel.app
API_PREFIX=api/v1
```

Railway injects `PORT`. Do not set `PORT` to `3000` unless you know the platform requires it.

**Important (Railway Variables):** if `CORS_ORIGINS` is already set, update it to include
`https://ye-lo-laundry-apps.vercel.app` (comma-separated with any other allowed origins).
Defaults only apply when the variable is unset.

---

## Admin Web (Next.js)

| Variable | Required | Description |
|----------|----------|-------------|
| `NEXT_PUBLIC_API_BASE_URL` | Yes (prod) | Backend API URL including `/api/v1` |

Login uses `admin-web/src/lib/api.ts`, which reads **`NEXT_PUBLIC_API_BASE_URL` only**.
Production builds must not fall back to localhost.

### LOCAL

```env
NEXT_PUBLIC_API_BASE_URL=http://localhost:3000/api/v1
```

### PRODUCTION

Committed default for builds: `admin-web/.env.production`

```env
NEXT_PUBLIC_API_BASE_URL=https://yelo-laundry-apps-production-2e03.up.railway.app/api/v1
```

You may also set the same variable in the Vercel project Environment Variables
(Production). Rebuild/redeploy Admin Web after changing it.

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
