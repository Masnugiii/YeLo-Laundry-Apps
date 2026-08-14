# Sprint 12 — Production Readiness Report

**Date:** 2026-08-10  
**Status:** PASS  
**Release candidate:** READY (internal code)  
**External infrastructure:** NOT READY (expected)

---

## Executive summary

Sprint 12 completed production preparation and final hardening. Critical/high bugs remain at zero. BUG-002 was investigated and closed as a **UAT methodology false positive** — customer notifications are created and queryable. BUG-001 was fixed (dev-only hydration). All regression builds/tests pass. Twelve production documents created. No production secrets in source.

---

## Bug resolution

### BUG-002 — Customer notifications empty

| Item | Result |
|------|--------|
| Root cause | Sprint 11 UAT script queried `GET /notifications` **before** order creation (line 266), not after lifecycle |
| Code defect | **None** — notifications created on `order.created` and `payment.success` with customer index |
| Verification | Customer A has 24 indexed notifications; API returns 200 with items after JWT auth |
| UAT order `YL-20260810-000036` | 2 customer notifications: Order Created + Payment Successful |

Architecture trace: `NotificationEventService.publish()` → `NotificationRepository.createNotification()` → `systemSetting` customer index → `NotificationService.findAll()` scoped by `customerId`.

**Note:** Order status transitions during lifecycle do not yet emit `laundry.*` events (templates exist; handlers not wired to `OrderService.updateStatus`). This is an enhancement gap, not the cause of empty lists.

### BUG-001 — Admin login hydration warning

| Item | Result |
|------|--------|
| Cause | Default `useState("081234567890")` / `admin123` caused server/client HTML mismatch in dev |
| Production impact | **None** — overlay is Next.js dev-only |
| Fix | Removed default credential values from initial state in `admin-web/src/app/login/page.tsx` |

---

## Security audit (Sprint 12)

| Area | Status |
|------|--------|
| JWT + refresh secrets | Env-only; validated at boot |
| RBAC / permissions guards | PASS |
| Customer ownership checks | PASS (Sprint 11) |
| CORS | Explicit origin list; no wildcard |
| OTP logging | Plaintext only when `APP_ENV !== production` |
| Payment secrets | Not in source |
| Sensitive `console.log` in `src/` | None found |
| `auth.controller` Swagger example password | Documentation only |

---

## Environment safety

| Check | Status |
|-------|--------|
| `.env` gitignored | PASS |
| `.env.example` placeholders only | PASS |
| Production credentials in repo | None found |
| Private keys committed | None found |

---

## Production dummy audit

| Scope | Count |
|-------|-------|
| Production business dummy in `src/` | 0 |
| `dummy_` / `mock_` / `fake_` in app source | 0 |
| Allowed: `DevPreviewGate` | Debug-only (`kDebugMode`) |
| Allowed: receipt preview sample (staff UI) | Static preview |
| Allowed: Swagger examples | API docs only |

---

## Regression results

| Target | Result |
|--------|--------|
| Backend `npm run build` | PASS |
| Backend `npm test` | 81/81 PASS |
| Admin `npm run build` | PASS |
| Customer `flutter analyze` | 0 errors |
| Customer `flutter test` | PASS |
| Customer `flutter build apk --debug` | PASS |
| Customer `flutter build appbundle --release` | PASS |
| Staff `flutter analyze` | 0 errors |
| Staff `flutter test` | PASS |
| Staff `flutter build apk --debug` | PASS |
| Staff `flutter build appbundle --release` | PASS |

---

## Documentation created

| Document | Path |
|----------|------|
| Production environment | `docs/PRODUCTION_ENVIRONMENT.md` |
| Production build | `docs/PRODUCTION_BUILD.md` |
| Payment setup | `docs/PAYMENT_PRODUCTION_SETUP.md` |
| OTP setup | `docs/OTP_PRODUCTION_SETUP.md` |
| Database backup/restore | `docs/DATABASE_BACKUP_RESTORE.md` |
| Database deployment | `docs/DATABASE_DEPLOYMENT.md` |
| Monitoring runbook | `docs/MONITORING_RUNBOOK.md` |
| Store checklist | `docs/STORE_RELEASE_CHECKLIST.md` |
| Staff distribution | `docs/STAFF_APP_DISTRIBUTION.md` |
| Privacy inventory | `docs/PRIVACY_DATA_INVENTORY.md` |
| Legal checklist | `docs/LEGAL_RELEASE_CHECKLIST.md` |
| This report | `docs/SPRINT_12_PRODUCTION_READINESS.md` |

---

## Remaining code blockers

| Item | Severity | Notes |
|------|----------|-------|
| Staff package ID `com.example.yelo_laundry_erp` | Low | Rename before distribution |
| Release signing uses debug keys (Flutter Android) | Medium | Configure keystore before store upload |
| Lifecycle status → customer notification events | Low | Enhancement; not blocking RC |
| Payment webhook implementation | N/A | EXTERNAL DEPENDENCY |

---

## External dependencies (not Sprint 12 failures)

- Domain / DNS
- VPS / cloud hosting
- HTTPS termination
- OTP / WhatsApp provider
- Payment gateway merchant + webhook credentials
- Google Play / Apple Developer accounts and approval
- Production signing certificates (if not yet provisioned)
- Hosted privacy policy URLs

---

## Production readiness verdict

| Dimension | Status |
|-----------|--------|
| **INTERNAL CODE** | **READY** |
| **EXTERNAL INFRASTRUCTURE** | **NOT READY** |

---

## Sprint 12 pass criteria

All Sprint 12 checklist items satisfied except those explicitly marked EXTERNAL DEPENDENCY.

**SPRINT 12 = PASS**
