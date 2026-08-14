# UAT QUICK START — Yelo Laundry

Use this guide to start local UAT **without reading source code**.

**Environment:** macOS local development  
**Backend API:** `http://localhost:3000/api/v1`  
**Health:** `http://localhost:3000/health`  
**Admin Web:** `http://localhost:3001` (default Next.js dev port)

> Never commit or share real passwords, OTP codes, JWT tokens, or `.env` secrets.

---

## 1. Prerequisites

- Node.js 20+ and npm
- Flutter SDK (stable)
- PostgreSQL running locally
- `.env` configured at repo root (copy from `.env.example`)
- Database migrated and seeded at least once

```bash
cd /path/to/yelo_laundry_erp
cp .env.example .env   # if not exists — fill DATABASE_URL, JWT secrets
npm install
npx prisma migrate deploy
npm run seed           # safe for local UAT; creates master data + dev staff accounts
```

---

## 2. Start backend

```bash
cd /path/to/yelo_laundry_erp
npm run start:dev
```

Wait until NestJS logs show the app is listening on port **3000**.

### Verify health

```bash
curl -s http://localhost:3000/health | jq .
```

Expected:

- HTTP `200`
- `"status": "ok"`
- `"database": "connected"`

---

## 3. Start Admin Web

In a **new terminal**:

```bash
cd /path/to/yelo_laundry_erp/admin-web
npm install   # first time only
npm run dev
```

Open: **http://localhost:3000** is backend — Admin is typically **http://localhost:3001**.

Login with local **Owner** staff account (phone from seed — ask dev lead for password; default local seed uses `admin123`).

Admin Web is **not required** to stay open for Customer/Staff apps to work.

---

## 4. Run Customer App

```bash
cd /path/to/yelo_laundry_erp/customer_app
flutter pub get
flutter run
```

**API base URL:** configured in app config / `.env` for customer — must point to `http://10.0.2.2:3000` (Android emulator) or `http://localhost:3000` (iOS simulator) or your machine LAN IP on physical device.

### Customer OTP (local only)

- In **non-production** (`APP_ENV=development`), OTP is written to **backend console logs** (masked phone + 6-digit code).
- Search backend terminal for: `OTP reference for`
- **Do not** screenshot or share OTP codes in bug reports.

### Dev preview (debug builds only)

- Debug builds may show "Preview Dashboard" on splash/login — this uses **dummy local data** and does **not** hit the server. Ignore for UAT unless testing debug tooling.

---

## 5. Run Staff App

```bash
cd /path/to/yelo_laundry_erp
flutter pub get
flutter run
```

Staff login uses **phone + password** (not OTP).

---

## 6. Local test roles

| Role | Phone | Password (local seed) |
|------|-------|------------------------|
| Owner | 081234567890 | admin123 |
| Cashier | 081234567891 | admin123 |
| Operator (Kasir Binatu) | 081234567892 | admin123 |
| Manager + Driver | 081234567893 | admin123 |
| Binatu | 081234567894 | admin123 |

**Customer UAT phones** (OTP path):

- Customer A: `081910090910`
- Customer B (ownership tests): `081910090902`

Create additional customers via Customer App register flow if needed.

---

## 7. Recommended testing order

1. **Health check** — backend + DB
2. **Admin Web login** — verify settings, services, perfumes exist
3. **Customer App** — login → profile → address → catalog → checkout → pay (wallet)
4. **Staff App (Cashier/Owner)** — verify order appears → advance lifecycle
5. **Customer App** — timeline / tracking / wallet / points
6. **Admin Web** — verify same order, payment, CS ticket
7. **Ownership** — Customer B must not access Customer A resources (403/404)
8. **RBAC** — Binatu/Operator attempt owner-only API or UI action → must be denied by backend

---

## 8. Automated smoke (optional, before manual UAT)

```bash
# Backend unit tests
cd /path/to/yelo_laundry_erp
npm test

# Full local API E2E (backend must be running)
python3 scripts/sprint9_go_live_e2e.py

# Flutter smoke
cd customer_app && flutter test
cd .. && flutter test
```

Expected E2E: **28 PASS**, **0 FAIL** (4 BLOCKED items are external/paid services).

---

## 9. Reset safe UAT state (without destroying schema)

**Do NOT** run `prisma migrate reset` on shared environments.

Safe options:

- Create **new** test customers with new phone numbers
- Use new orders for each UAT cycle
- To refresh master data only: `npm run seed` (upserts dev accounts; does not wipe orders)

For full isolated reset: restore from backup dump in `backups/` to a **separate** database — never overwrite production.

---

## 10. Where to find logs

| Component | Location |
|-----------|----------|
| Backend API | Terminal running `npm run start:dev` |
| OTP (local dev) | Same backend terminal — `OTP reference for ...` |
| Admin Web | Terminal running `npm run dev` |
| Customer / Staff | `flutter run` terminal / Android Logcat |
| E2E script output | stdout from `python3 scripts/sprint9_go_live_e2e.py` |

---

## 11. How to record bugs

Use template:

```
Title:
Environment: local / device model
Role: Customer / Owner / etc.
Steps:
Expected:
Actual:
Screenshots/logs: (no secrets)
Order number / ticket ID:
Retest result:
```

Track in `docs/SPRINT_10_UAT_CHECKLIST.md` or your issue tracker.

---

## 12. Build verification (release readiness)

```bash
# Customer
cd customer_app
flutter analyze
flutter test
flutter build apk --debug
flutter build appbundle --release

# Staff
cd ..
flutter analyze
flutter test
flutter build apk --debug
flutter build appbundle --release

# Admin
cd admin-web
npm run build
```

---

## 13. Known external blockers (not code bugs)

These do **not** block local UAT PASS:

- Production domain / VPS
- Paid WhatsApp OTP provider
- Payment gateway merchant account + webhook
- Production TLS certificates
- Store listing approval

---

## 14. UAT reference order from Sprint 10 automated run

- Order number: `YL-20260810-000027`
- Status after E2E: `COMPLETED`
- Grand total example: `35000`

Use this order to verify cross-platform consistency in Admin + Customer + Staff.
