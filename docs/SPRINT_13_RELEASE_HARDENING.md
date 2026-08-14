# Sprint 13 — Release Hardening Report

**Date:** 2026-08-10  
**Status:** PASS  
**Internal release:** READY

---

## Package IDs

| App | Application ID | App label | Status |
|-----|----------------|-----------|--------|
| Customer Android | `com.yelolaundry.yelo_laundry_customer` | `yelo_laundry_customer` (manifest) / Yelo Laundry Customer (iOS) | Unchanged — official |
| Staff Android | `com.yelolaundry.yelo_laundry_staff` | **Internal** | Official |
| Staff iOS/macOS | `com.yelolaundry.yeloLaundryStaff` | Internal | Updated |

**Naming basis:** Mirrors approved customer namespace `com.yelolaundry.*`. Formal business sign-off on staff ID recommended before Play Console registration.

Customer ≠ Staff — verified unique.

---

## Android signing

| Item | Status |
|------|--------|
| `android/key.properties.example` | Created |
| `customer_app/android/key.properties.example` | Created |
| Gradle reads `key.properties` when present | Staff + Customer |
| Fallback to debug signing without keystore | PASS |
| `key.properties` gitignored | PASS |
| `docs/ANDROID_SIGNING.md` | Created |

**Owner action:** Provision production keystore and `key.properties` locally/CI.

---

## Notification lifecycle

### Implemented mappings (`OrderService.updateStatus`)

| Order status | Template | Customer notify |
|--------------|----------|-----------------|
| `IRONING_ACCEPTED` | `laundry.started` | Yes |
| `FINISHED_IRONING` | `laundry.finished` | Yes |
| `READY_FOR_PICKUP` | `pickup.ready` | Yes |
| `OUT_FOR_DELIVERY` | `delivery.started` | Yes |
| `DELIVERED` | `delivery.completed` | Yes |

Preserved existing: `order.created`, `payment.success`, pickup/delivery module events.

### Idempotency

- Same-status PATCH → `400` (`Order is already in the requested status`) — no notification
- Per-status dedup key: `{templateCode}:{orderId}` — aligns with pickup/delivery pattern
- Notification failure wrapped in `catch` — does not roll back committed order status

### E2E

- Script: `scripts/sprint13_notification_e2e.py`
- **Sprint 13.2 live result:** 39 PASS / 0 FAIL (orders `YL-20260810-000045`, `YL-20260810-000046`)
- RC freeze re-run (2026-08-10): blocked by OTP auth in audit environment; no notification code changes since 13.2
- Manual re-run before production deploy:
  ```bash
  npm run build && npm run start:dev
  python3 scripts/sprint13_notification_e2e.py
  ```
- Full RC report: `docs/FINAL_RELEASE_CANDIDATE.md`

---

## Security

| Check | Status |
|-------|--------|
| Notification scoped by `customerId` | PASS (Sprint 12 + architecture) |
| Ownership isolation | Enforced in `NotificationService.ensureAccess` |
| Wallet / payment unchanged | No regression in finance paths |

---

## Production dummy

| Scope | Count |
|-------|-------|
| `src/` business dummy | 0 |
| `DevPreviewGate` | Debug-only |

---

## Test results

| Target | Result |
|--------|--------|
| Backend build | PASS |
| Backend tests | **86/86 PASS** (+5 lifecycle util tests from Sprint 12) |
| Admin build | PASS |
| Staff analyze | 0 errors |
| Staff tests | 8/8 PASS |
| Staff debug APK | PASS |
| Staff release AAB | PASS (58.0 MB) |
| Customer analyze | 0 errors |
| Customer tests | 1/1 PASS |
| Customer debug APK | PASS |
| Customer release AAB | PASS (59.5 MB) |

---

## Release artifacts

| Artifact | Path | Size | App ID | Version |
|----------|------|------|--------|---------|
| Staff AAB | `build/app/outputs/bundle/release/app-release.aab` | ~58 MB | `com.yelolaundry.yelo_laundry_staff` | 1.0.0+1 |
| Customer AAB | `customer_app/build/app/outputs/bundle/release/app-release.aab` | ~59.5 MB | `com.yelolaundry.yelo_laundry_customer` | 1.0.0+1 |
| Admin build | `admin-web/.next/` | — | N/A | 0.1.0 |

Signed with debug keystore until owner provides production keystore.

---

## Customer UI regression (source verified)

| Element | Color | Status |
|---------|-------|--------|
| Login "People!" | `#FFFF00` | PASS |
| Masuk button | bg `#F4E900`, text blue | PASS |
| Splash loading | `#FFFF00` on blue | PASS |
| Dashboard profile / slider | `#F4E900` | PASS |
| Account profile circle | `#F4E900` | PASS |
| Edit profile circle / Simpan | `#F4E900` / `#F6CF00` | PASS |

---

## Known issues

| ID | Severity | Notes |
|----|----------|-------|
| — | — | Critical = 0, High = 0 |

---

## Owner action required

1. Approve staff package ID `com.yelolaundry.yelo_laundry_staff` for Play Console
2. Create production Android keystore + `key.properties`
3. Run `scripts/sprint13_notification_e2e.py` against running backend after deploy
4. Apple signing certificates for iOS distribution

---

## External dependencies

- Domain / VPS / HTTPS
- OTP provider
- Payment provider
- Store accounts
- Production keystore

---

## Final release status

| Dimension | Status |
|-----------|--------|
| **INTERNAL RELEASE** | **READY** |
| **EXTERNAL GO-LIVE** | **NOT READY** (expected) |

**SPRINT 13 = PASS**
