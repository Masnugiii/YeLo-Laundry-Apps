# SPRINT 10 — UAT CHECKLIST

**Project:** Yelo Laundry ERP  
**Sprint:** 10 — Pre-UAT, Full Operational Simulation & Bug Fix  
**Test date:** 2026-08-10  
**Environment:** Local (`localhost:3000` backend, local PostgreSQL)  
**Primary UAT order:** `YL-20260810-000027` (lifecycle completed during automated E2E)

> Do **not** store passwords, OTP codes, JWT tokens, or API secrets in this document.

---

## Legend

| Status | Meaning |
|--------|---------|
| PASS | Verified in Sprint 10 |
| FAIL | Verified failure — must fix before go-live |
| BLOCKED | External/paid dependency not available locally |
| NOT TESTED | Not executed in Sprint 10 (manual UI retest recommended) |

---

## Test identities (local seed / UAT)

| Role | Label | Phone | Notes |
|------|-------|-------|-------|
| Owner | Owner | 081234567890 | Staff login (password in local seed only — ask dev lead) |
| Manager | Manajer Driver | 081234567893 | Combined manager + driver role in seed |
| Cashier | Kasir Operasional | 081234567891 | |
| Operator | Kasir Binatu | 081234567892 | Laundry operator queue |
| Binatu | Binatu Staff | 081234567894 | |
| Driver | Manajer Driver | 081234567893 | Same account as manager in local seed |
| Customer A | Sprint9 Go-Live Customer | 081910090910 | OTP local/dev path |
| Customer B | Ownership test | 081910090902 | Used for 403/404 isolation |

---

## CUSTOMER APP

| Area | Status | Evidence / Notes |
|------|--------|------------------|
| Auth (OTP local path) | PASS | `scripts/sprint9_go_live_e2e.py` — Customer auth OTP |
| Session persistence | PASS | Secure token storage + `restoreSession()` + refresh interceptor (code review); manual reopen retest recommended |
| Logout / re-login | NOT TESTED | Manual UAT tomorrow |
| Dashboard | PASS | Build + smoke test; UI colors verified in code |
| Profile | PASS | API integration baseline from Sprint 9 |
| Edit Profile | PASS | UI colors verified (`#F4E900` circle, `#F6CF00` save button) |
| Address CRUD | NOT TESTED | Manual UAT tomorrow |
| Catalog / services | PASS | E2E `GET /customer-app/services` |
| Perfume | PASS | E2E `GET /customer-app/perfumes` |
| Checkout / create order | PASS | E2E order create ×3 |
| Order detail | PASS | E2E customer order fetch |
| Payment (YELO_WALLET) | PASS | E2E `POST .../pay` |
| Wallet balance | PASS | E2E wallet top-up flow |
| Wallet history | PASS | Baseline Sprint 9; back nav code present |
| Promo quote | PASS | E2E `POST /customer-app/promos/quote` |
| Rewards / points | PASS | E2E rewards before/after mission |
| Mission claim | PASS | E2E claim + double-claim rejection |
| Notifications | NOT TESTED | Manual UAT tomorrow |
| Customer service ticket | PASS | E2E ticket create + staff reply |
| Order timeline | NOT TESTED | UI styled; manual UAT tomorrow |
| Delivery / laundry tracking | NOT TESTED | UI styled; manual UAT tomorrow |
| Receipt | PASS | Settings receipt endpoint + lifecycle order completed |
| Account / profile circle color | PASS | `#F4E900` in `profile_screen.dart` |
| Ownership isolation | PASS | E2E Customer B → 403/404 on Customer A order |

---

## STAFF APP (Flutter ERP)

| Role | Login | Dashboard | Allowed ops | Denied ops | Status |
|------|-------|-----------|-------------|------------|--------|
| Owner | PASS | PASS | Full lifecycle PATCH, settings, CS reply | — | PASS |
| Manager | PASS | NOT TESTED | Manual UAT | Manual RBAC deny test | NOT TESTED |
| Cashier | PASS | NOT TESTED | Payment / order ops in E2E | Manual RBAC | PARTIAL |
| Operator | NOT TESTED | NOT TESTED | Manual UAT | Manual RBAC | NOT TESTED |
| Binatu | PASS | NOT TESTED | Lifecycle transitions in E2E | Manual RBAC | PARTIAL |
| Driver | NOT TESTED | NOT TESTED | Manual UAT | Manual RBAC | NOT TESTED |

| Area | Status | Notes |
|------|--------|-------|
| RBAC backend enforcement | PASS | Jest guards + E2E staff tokens |
| No production dummy in `lib/` | PASS | Source audit — 0 business dummy |
| Release/debug build | PASS | `flutter build apk --debug` + `appbundle --release` |

---

## ADMIN WEB

| Area | Status | Notes |
|------|--------|-------|
| Build | PASS | `npm run build` |
| Login | NOT TESTED | Manual UAT tomorrow |
| Dashboard | NOT TESTED | Manual UAT |
| Customers | NOT TESTED | Customer A should exist after E2E |
| Orders | NOT TESTED | UAT order `YL-20260810-000027` in DB |
| Payments | NOT TESTED | Manual UAT |
| Laundry workflow | NOT TESTED | Lifecycle completed via API |
| Pickup / delivery | NOT TESTED | Manual UAT |
| Customer service | PASS | E2E staff reply on ticket |
| Promo | NOT TESTED | Promo quote API PASS |
| Loyalty / missions | PASS | E2E mission claim |
| Perfumes | NOT TESTED | API list used in order create |
| Reports | NOT TESTED | Manual UAT |
| Attendance | NOT TESTED | Manual UAT |
| Employees | NOT TESTED | Manual UAT |
| Settings (company/receipt/numbering) | PASS | E2E GET settings |
| Audit logs | NOT TESTED | Manual UAT |
| Admin not required for runtime | PASS | Architecture — stateless API |

---

## CROSS-PLATFORM CONSISTENCY

| Check | Status | Notes |
|-------|--------|-------|
| Order number match | PASS | E2E staff `invoiceNumber` = customer `orderNumber` |
| Order status match | PASS | E2E after lifecycle |
| Subtotal / tax / grand total | PASS | E2E `lifecycle_order` note |
| Payment status | PASS | Wallet payment + lifecycle |
| Wallet arithmetic | PASS | Top-up + duplicate confirm rejected |
| Points after mission | PASS | 220 → 221 in E2E run |
| Perfume on order | PASS | Included when perfumes exist |
| CS ticket + messages | PASS | E2E create + reply |

---

## UI REGRESSION (code verification — manual visual retest recommended)

| Screen | Check | Status |
|--------|-------|--------|
| Login | "People!" `#FFFF00` | PASS |
| Login | Masuk button bg `#F4E900`, text `brandBlue` | PASS |
| Splash | Background blue, loading `#FFFF00` | PASS |
| Dashboard | Profile circle `#F4E900` | PASS |
| Dashboard | Slider dots `#F4E900` | PASS |
| Dashboard | Quick action "Cek Status Laundry" + shipping icon | PASS |
| Account | Profile circle `#F4E900` | PASS |
| Edit Profile | Circle `#F4E900`, Save `#F6CF00`, text blue | PASS |
| Wallet history | Back to dashboard | PASS |
| Completed orders | Back to dashboard | PASS |
| Order timeline / tracking | Dashboard styling | PASS (code) |

---

## SECURITY & PRODUCTION DUMMY

| Check | Status |
|-------|--------|
| OTP logged only when `APP_ENV !== production` | PASS |
| No `print(token)` / secret leaks in customer `lib/` | PASS |
| Dev preview gated to `kDebugMode` only | PASS |
| Production business dummy in customer `lib/` | 0 (PASS) |
| Production business dummy in staff `lib/` | 0 (PASS) |
| Production business dummy in admin `src/` | 0 (PASS) |

**Dummy/mock classification**

| Finding | Class | Action |
|---------|-------|--------|
| `dev_preview_gate.dart` / `dev_preview_data.dart` | B — debug only | None |
| `home_shell.dart` dev preview banner | B — debug only | None |
| `help_center_content.dart` placeholder copy | D — static UI | None |
| Jest `mock*` in `test/` | C — test only | None |

---

## AUTOMATED VERIFICATION (Sprint 10 run)

| Suite | Result |
|-------|--------|
| `npm run build` | PASS |
| `npm test` | PASS — 81/81 |
| `GET /health` | PASS — DB connected |
| Prisma migrations | PASS — up to date (9 migrations) |
| `python3 scripts/sprint9_go_live_e2e.py` | PASS — 28/28 (4 external BLOCKED) |
| Customer `flutter analyze` | PASS — 0 errors |
| Customer `flutter test` | PASS — 1/1 |
| Customer `flutter build apk --debug` | PASS |
| Customer `flutter build appbundle --release` | PASS |
| Staff `flutter analyze` | PASS — 0 errors |
| Staff `flutter test` | PASS — 8/8 |
| Staff `flutter build apk --debug` | PASS |
| Staff `flutter build appbundle --release` | PASS |
| Admin `npm run build` | PASS |

---

## DEFERRED EXTERNAL DEPENDENCIES (not Sprint 10 failures)

| Item | Status |
|------|--------|
| Production domain | BLOCKED |
| Production VPS | BLOCKED |
| Paid OTP / WhatsApp provider | BLOCKED |
| Payment gateway merchant + webhook | BLOCKED |
| Production HTTPS / DNS | BLOCKED |
| App Store / Play Store approval | BLOCKED |

---

## BUGS FOUND & FIXED IN SPRINT 10

| ID | Issue | Fix | Retest |
|----|-------|-----|--------|
| — | No new critical code defects found during automated Sprint 10 run | — | — |

---

## REMAINING CODE BLOCKERS

None identified in automated Sprint 10 verification.

---

## SIGN-OFF

| Role | Name | Date | Signature |
|------|------|------|-----------|
| QA / UAT Lead | | | |
| Product Owner | | | |
| Tech Lead | | | |
