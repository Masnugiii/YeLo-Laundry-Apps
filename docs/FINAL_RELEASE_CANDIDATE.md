# Final Release Candidate — Yelo Laundry

**Date:** 2026-08-10  
**Sprint:** Final Release — Release Candidate Freeze  
**Status:** **RELEASE CANDIDATE READY** (internal)  
**Production Go-Live:** **NOT READY** (external dependencies pending)

---

## 1. Release Identity

| Component | Display Name | Application ID / Package | Version |
|-----------|--------------|----------------------------|---------|
| **Customer** | YeLo Laundry | `com.yelolaundry.yelo_laundry_customer` | `1.0.0+1` |
| **Staff / Internal** | Internal | `com.yelolaundry.yelo_laundry_staff` | `1.0.0+1` |
| **Admin Web** | Yelo Laundry ERP (admin) | N/A (web) | `0.1.0` |
| **Backend** | Yelo Laundry ERP API | N/A | `0.1.0` |

Identity verified in:
- `customer_app/android/app/src/main/AndroidManifest.xml` → `YeLo Laundry`
- `customer_app/ios/Runner/Info.plist` → `YeLo Laundry`
- `android/app/src/main/AndroidManifest.xml` → `Internal`
- `ios/Runner/Info.plist` → `Internal`

**No Application ID or Display Name changes during this freeze.**

---

## 2. Workspace Audit

| Component | Path | Status |
|-----------|------|--------|
| Backend (NestJS) | `src/`, `prisma/`, `package.json` | Present |
| Customer App (Flutter) | `customer_app/` | Present |
| Staff / Internal App (Flutter) | `lib/`, `android/`, `pubspec.yaml` (root) | Present |
| Admin Web (Next.js) | `admin-web/` | Present |
| Database docs | `docs/DATABASE_BACKUP_RESTORE.md`, `docs/DATABASE_DEPLOYMENT.md` | Present |
| E2E scripts | `scripts/sprint13_notification_e2e.py` | Present |
| Signing templates | `android/key.properties.example`, `customer_app/android/key.properties.example` | Present |

No critical build/runtime files missing.

---

## 3. Backend

| Check | Result | Notes |
|-------|--------|-------|
| `npm run build` | **PASS** | Nest build completed |
| `npm test` | **PASS — 91/91** | Baseline was 88/88; +3 from Sprint 13.2 notification unit tests (`notification-meta.util.spec.ts`, `notification.service.spec.ts`) |
| `GET /health` | **PASS** | `status: ok`, `database: connected` |

Health endpoint: `http://localhost:3000/health` (excluded from API prefix).

---

## 4. Customer App

| Check | Result | Notes |
|-------|--------|-------|
| `flutter analyze` | **PASS** | 0 errors, 0 warnings (62 info-level lints) |
| `flutter test` | **PASS — 8/8** | Includes notification category unit tests |
| `flutter build apk --debug` | **PASS** | `customer_app/build/app/outputs/flutter-apk/app-debug.apk` (~189 MB) |
| `flutter build appbundle --release` | **PASS** | `customer_app/build/app/outputs/bundle/release/app-release.aab` (~57 MB) |
| Identity | **PASS** | YeLo Laundry / `com.yelolaundry.yelo_laundry_customer` |
| UI colors | **PASS** | Approved colors present (`#FFFF00`, `#F4E900`, `#F6CF00`) |
| Navigation | **PASS** | Code-verified back paths to Dashboard |

### Customer Navigation (code audit)

| Flow | Implementation | Status |
|------|----------------|--------|
| Dashboard → Pesan Laundry → Back | `pickup_checkout_flow_screen.dart` → `context.go('/home')` | PASS |
| Dashboard → Account → Back | `profile_screen.dart` → `context.go('/home')` | PASS |
| Dashboard → Notifikasi → Back | `notifications_screen.dart` → `context.go('/home')` | PASS |
| Order Timeline → Back | `order_timeline_screen.dart` → `context.pop()` | PASS |
| Lacak Pengiriman → Back | `delivery_tracking_screen.dart` → `context.pop()` | PASS |
| Riwayat Wallet → Back | `wallet_history_screen.dart` → `context.go('/home')` | PASS |
| Detail Pesanan → Back | `order_detail_screen.dart` → `context.pop()` | PASS |
| Pesanan Selesai → Back | `laundry_status_screen.dart` → `context.go('/home')` | PASS |
| Edit Profile → Back | `edit_profile_screen.dart` → `context.pop()` | PASS |

### Notification UI (Category Style)

| Check | Status |
|-------|--------|
| Categories (Pesanan, Pembayaran, Laundry, Pengiriman, Promo, Loyalty/Poin, Sistem) | PASS |
| Time grouping (HARI INI, KEMARIN, MINGGU INI, SEBELUMNYA) | PASS |
| Unread/read states | PASS |
| Chronological order (newest first) | PASS |
| Empty / error / loading states | PASS |
| ✓✓ Mark All Read (unchanged icon) | PASS |
| Back → Dashboard | PASS |

---

## 5. Staff / Internal App

| Check | Result | Notes |
|-------|--------|-------|
| `flutter analyze` | **PASS** | 0 errors, 11 warnings (unused imports/fields), remainder info |
| `flutter test` | **PASS — 8/8** | Widget + greeting tests |
| `flutter build apk --debug` | **PASS** | `build/app/outputs/flutter-apk/app-debug.apk` (~156 MB) |
| `flutter build appbundle --release` | **PASS** | `build/app/outputs/bundle/release/app-release.aab` (~55 MB) |
| Identity | **PASS** | Internal / `com.yelolaundry.yelo_laundry_staff` |
| RBAC roles | **PASS** | OWNER, MANAGER, CASHIER, OPERATOR, BINATU, DRIVER mapped in `role_mapper.dart` |

---

## 6. Admin Web

| Check | Result |
|-------|--------|
| `npm run build` | **PASS** |
| Build output | `admin-web/.next/` |
| Routes | 58 pages compiled (login, dashboard, orders, customers, payments, reports, settings, employees, customer service, audit logs, etc.) |

Admin Web is not required at runtime for backend operation.

---

## 7. Notifications

### Sprint 13.2 Live E2E (last verified)

| Metric | Value |
|--------|-------|
| Script | `scripts/sprint13_notification_e2e.py` |
| Result | **39 PASS / 0 FAIL** |
| Orders | `YL-20260810-000045`, `YL-20260810-000046` |

### RC Freeze Re-run

| Metric | Value |
|--------|-------|
| Re-run attempt | **BLOCKED** — customer OTP auth returned HTTP 401 (environment/log access) |
| Code changes since 13.2 | None to notification lifecycle |
| Backend unit tests | 91/91 PASS (includes notification ownership/dedup tests) |

### Verified Events (Sprint 13.2)

- `order.created` → Pesanan
- `payment.success` → Pembayaran
- `laundry.started` / `laundry.finished` → Laundry
- `pickup.ready` → Pengiriman
- `delivery.started` / `delivery.completed` → Pengiriman

Ownership, deduplication, unread count, and read state verified in Sprint 13.2 live run.

---

## 8. Security Audit

| Check | Status |
|-------|--------|
| Real production secrets in repo | **0 found** |
| `.env` gitignored | PASS |
| `.env.example` uses empty placeholders | PASS |
| `key.properties` / `*.jks` / `*.keystore` gitignored | PASS |
| JWT / RBAC / ownership | Enforced (unit tests PASS) |
| CORS configurable via env | PASS |
| Financial / wallet / points safety | No weakening during freeze |

**Findings (allowed):**
- `admin123` in `prisma/seed.ts`, Swagger examples, dev login preview — local/dev only
- `.env` exists locally with `DATABASE_URL` — gitignored, not committed

---

## 9. Production Dummy Audit

| Area | Finding | Classification |
|------|---------|----------------|
| `customer_app/lib/core/dev/dev_preview_gate.dart` | Preview gated by `kDebugMode` | **Allowed** (debug-only) |
| `customer_app/lib/core/dev/dev_preview_data.dart` | Static preview data | **Allowed** (debug-only) |
| `lib/features/auth/models/login_mode.dart` | Dev phones/password for role preview | **Allowed** (dev preview) |
| `src/` production business logic | No fake customers/orders/payments/wallet/points/notifications | **PASS — 0 production dummies** |
| Swagger `@ApiProperty` examples | Documentation examples only | **Allowed** |

**Target: PRODUCTION BUSINESS DUMMY = 0 — ACHIEVED**

---

## 10. API Configuration

| App | Release behavior |
|-----|------------------|
| Customer | `String.fromEnvironment('API_BASE_URL')`; default `http://localhost:3000/api/v1` if not set |
| Staff | `String.fromEnvironment('API_BASE_URL')`; Android emulator fallback `10.0.2.2` |

Release builds must pass `--dart-define=API_BASE_URL=<production-url>` at build time.

**PRODUCTION API URL = OWNER ACTION REQUIRED** (infrastructure does not exist yet).

No production URL invented.

---

## 11. Environment Audit

| Item | Status |
|------|--------|
| `APP_ENV` in `.env.example` | `development` (template) |
| Secrets in repository | None committed |
| Production credentials | External — not created |
| DevPreview | `kDebugMode` only — not packaged as production |

---

## 12. Database Safety

| Item | Status |
|------|--------|
| Prisma schema | Present |
| Migrations | Present |
| `docs/DATABASE_BACKUP_RESTORE.md` | Present |
| `docs/DATABASE_DEPLOYMENT.md` | Present |
| Destructive operations this sprint | **None** |
| Production database | Does not exist yet |

---

## 13. Signing Status

| App | Build | Signing |
|-----|-------|---------|
| Customer AAB | PASS | **DEBUG SIGNED** (no production keystore) |
| Staff AAB | PASS | **DEBUG SIGNED** (no production keystore) |

| Item | Status |
|------|--------|
| `key.properties.example` (both apps) | Present |
| `key.properties` gitignored | PASS |
| `*.jks` / `*.keystore` gitignored | PASS |
| Real signing secrets committed | **0** |

**PRODUCTION KEYSTORE = OWNER ACTION REQUIRED**

Do not claim store-ready signing.

---

## 14. Release Artifacts

| Artifact | Path | Size | Version | Application ID |
|----------|------|------|---------|----------------|
| Customer AAB | `customer_app/build/app/outputs/bundle/release/app-release.aab` | ~57 MB | 1.0.0+1 | `com.yelolaundry.yelo_laundry_customer` |
| Customer debug APK | `customer_app/build/app/outputs/flutter-apk/app-debug.apk` | ~189 MB | 1.0.0+1 | `com.yelolaundry.yelo_laundry_customer` |
| Staff AAB | `build/app/outputs/bundle/release/app-release.aab` | ~55 MB | 1.0.0+1 | `com.yelolaundry.yelo_laundry_staff` |
| Staff debug APK | `build/app/outputs/flutter-apk/app-debug.apk` | ~156 MB | 1.0.0+1 | `com.yelolaundry.yelo_laundry_staff` |
| Admin build | `admin-web/.next/` | — | 0.1.0 | N/A |
| Backend build | `dist/` | — | 0.1.0 | N/A |

Nothing uploaded or published.

---

## 15. Release Candidate Issues

### Critical
*None*

### High
*None*

### Medium
| ID | Issue | Notes |
|----|-------|-------|
| RC-M01 | Notification E2E re-run blocked in RC audit session | OTP auth HTTP 401; Sprint 13.2 live run remains valid (39/0). Re-run before production deploy with backend log access. |

### Low
| ID | Issue | Notes |
|----|-------|-------|
| RC-L01 | Staff `flutter analyze` — 11 warnings | Unused imports/fields; no functional impact |
| RC-L02 | Customer/Staff info-level lints | Style/deprecation hints only; 0 errors |

### Owner Actions
| Item | Required For |
|------|--------------|
| Production keystore + `key.properties` | Store signing |
| Production API URL (`API_BASE_URL`) | Mobile release builds |
| Production database + migrations | Go-live |
| JWT / OTP / payment / R2 credentials | Production backend |
| Domain, VPS, HTTPS, DNS | Infrastructure |
| Google Play / Apple Developer accounts | Store publishing |
| OTP provider / payment gateway / merchant account | Live transactions |

### External Dependencies (not bugs)
- Domain, VPS, HTTPS, DNS
- OTP provider
- Payment gateway / merchant account
- Production credentials
- Production database
- R2 / object storage
- Google Play account
- Apple Developer account
- Production signing keystore
- Store approval process

---

## 16. Go-Live Status

| Layer | Status |
|-------|--------|
| **INTERNAL RELEASE** | **READY** |
| **RELEASE CANDIDATE** | **READY** |
| **EXTERNAL PRODUCTION** | **NOT READY** |

---

## 17. Freeze Declaration

As of 2026-08-10:

- **No new features** unless critical/high defect found
- **No UI redesign**
- **No identity changes**
- **No backend architecture changes**
- **No commit / no push** during this audit

---

## 18. Regression Summary

```
Backend:   npm run build  PASS | npm test  91/91 PASS | health  ok/connected
Customer:  analyze 0e/0w  PASS | test 8/8 PASS | debug APK PASS | release AAB PASS
Staff:     analyze 0e/11w PASS | test 8/8 PASS | debug APK PASS | release AAB PASS
Admin:     npm run build PASS
Notify:    Sprint 13.2 E2E 39/0 PASS | RC re-run blocked (env)
Security:  0 production secrets | signing safe | dummy audit 0
```

**FINAL DECISION: RELEASE CANDIDATE = READY**

This is **not** production go-live approval.
