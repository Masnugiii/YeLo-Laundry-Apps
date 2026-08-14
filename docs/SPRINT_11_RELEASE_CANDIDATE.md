# SPRINT 11 — RELEASE CANDIDATE

**Project:** Yelo Laundry ERP  
**Release candidate date:** 2026-08-10  
**Status:** READY FOR PRODUCTION PREPARATION (local UAT complete)

---

## Application versions

| Component | Version | Build |
|-----------|---------|-------|
| Backend API | `0.1.0` | NestJS build from `npm run build` |
| Customer App | `1.0.0+1` | `customer_app/pubspec.yaml` |
| Staff App | `1.0.0+1` | root `pubspec.yaml` |
| Admin Web | `0.1.0` | `admin-web/package.json` |
| Database | Prisma | 9 migrations — **up to date** |

---

## Automated test results (Sprint 11 final regression)

| Suite | Command | Result |
|-------|---------|--------|
| Backend build | `npm run build` | **PASS** |
| Backend tests | `npm test` | **PASS — 81/81** |
| Health | `GET /health` | **PASS** — DB connected |
| Sprint 11 API UAT | `python3 scripts/sprint11_manual_uat.py` | **PASS — 48/48** |
| Customer analyze | `flutter analyze` | **PASS** — 0 errors |
| Customer tests | `flutter test` | **PASS — 1/1** |
| Customer debug APK | `flutter build apk --debug` | **PASS** |
| Customer release AAB | `flutter build appbundle --release` | **PASS** (59.5MB) |
| Staff analyze | `flutter analyze` | **PASS** — 0 errors |
| Staff tests | `flutter test` | **PASS — 8/8** |
| Staff debug APK | `flutter build apk --debug` | **PASS** |
| Staff release AAB | `flutter build appbundle --release` | **PASS** (58.0MB) |
| Admin build | `npm run build` | **PASS** |

---

## Manual UAT summary

### Customer App

| Area | API UAT | Visual on-device |
|------|---------|------------------|
| Auth / session | PASS | Requires device tester |
| Dashboard / profile / edit profile | PASS (API + color audit) | Requires device tester |
| Address CRUD | PASS | Requires device tester |
| Catalog / checkout / order / payment | PASS | Requires device tester |
| Wallet / rewards / mission | PASS | Requires device tester |
| Timeline / tracking APIs | PASS | Visual NOT TESTED on device |
| Notifications API | PASS (endpoints) | List empty — see BUG-002 |
| Customer service | PASS | Requires device tester |
| Ownership | PASS | — |

### Staff App (all seeded roles)

| Role | Login | RBAC negative | Operational |
|------|-------|---------------|-------------|
| OWNER | PASS | — | PASS |
| MANAGER | PASS | PATCH settings denied | GET settings allowed |
| CASHIER | PASS | POST employees denied | E2E lifecycle |
| OPERATOR | PASS | PATCH numbering denied | — |
| BINATU | PASS | wallet adjustment denied | Lifecycle transitions |
| DRIVER | BLOCKED | No seed account | MANAGER covers driver perms |

### Admin Web

| Area | Result |
|------|--------|
| Login (browser) | PASS |
| Dashboard (browser) | PASS |
| Orders page (browser) | PASS |
| API reads (owner token) | PASS — customers, orders, payments, reports/dashboard, settings, employees, admin/audit-logs |
| Full 18-module walkthrough | Partial — core paths verified |

---

## UAT simulation record

**Customer A:** `081910090910`  
**UAT order:** `YL-20260810-000036`  
**Order ID:** `b19c7b1e-335c-40ec-a275-94a3bbe3820b`

| Field | Value |
|-------|-------|
| Subtotal | 70000 |
| Tax | 0 |
| Grand total | 70000 |
| Payment status | PAID |
| Order status | COMPLETED |
| Points before | 361 |
| Wallet before | 0 |

Numbering: 3 consecutive unique order numbers verified (`000034`–`000036` range in same run).

---

## Production dummy audit

**Target: 0 business dummy in production source**

| Path | Result |
|------|--------|
| `customer_app/lib/` | 0 — only debug preview banner (class B) |
| `lib/` (Staff) | 0 |
| `admin-web/src/` | 0 |

---

## UI brand regression (code verified)

| Screen | Spec | Status |
|--------|------|--------|
| Login "People!" | `#FFFF00` | PASS |
| Login Masuk button | bg `#F4E900`, text blue | PASS |
| Splash loading | `#FFFF00`, bg blue | PASS |
| Dashboard profile + slider | `#F4E900` | PASS |
| Account profile circle | `#F4E900` | PASS |
| Edit Profile circle / Save | `#F4E900` / `#F6CF00` | PASS |

---

## Known issues

See [UAT_BUG_LOG.md](./UAT_BUG_LOG.md):

- **BUG-001** (LOW): Admin login hydration dev warning
- **BUG-002** (MEDIUM): Customer notifications empty after lifecycle — verify notification settings

**Critical:** 0  
**High:** 0

---

## Deferred external dependencies

Not release blockers:

- Production domain / VPS
- Paid OTP / WhatsApp provider
- Payment gateway merchant + webhook
- Production HTTPS / DNS
- App Store / Play Store approval

---

## Release artifacts

| Artifact | Path |
|----------|------|
| Customer debug APK | `customer_app/build/app/outputs/flutter-apk/app-debug.apk` |
| Customer release AAB | `customer_app/build/app/outputs/bundle/release/app-release.aab` |
| Staff debug APK | `build/app/outputs/flutter-apk/app-debug.apk` |
| Staff release AAB | `build/app/outputs/bundle/release/app-release.aab` |
| Admin production build | `admin-web/.next/` |
| Backend dist | `dist/` |

---

## Release checklist

- [x] Backend boots and health OK
- [x] All automated tests PASS
- [x] Full order lifecycle PASS
- [x] Cross-platform consistency PASS
- [x] RBAC positive + negative PASS
- [x] Ownership PASS
- [x] Wallet / points safety PASS (duplicate reject)
- [x] Customer service round-trip PASS
- [x] Receipt / numbering settings accessible
- [x] Production business dummy = 0
- [x] Critical / high bugs = 0
- [x] Release AAB builds PASS
- [ ] On-device Flutter visual sign-off (recommended before store submission)
- [ ] Notification template settings review (BUG-002)
- [ ] Production secrets & infrastructure (deferred)

---

## Sign-off

| Role | Name | Date | Approved |
|------|------|------|----------|
| QA Lead | | | |
| Tech Lead | | | |
| Product Owner | | | |
