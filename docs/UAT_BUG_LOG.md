# UAT BUG LOG — Sprint 11

**Project:** Yelo Laundry ERP  
**Last updated:** 2026-08-10  
**Environment:** Local UAT

> Do not store passwords, OTP codes, JWT tokens, or API secrets in this file.

---

## Summary

| Severity | Open | Fixed | Won't fix |
|----------|------|-------|-----------|
| CRITICAL | 0 | 0 | 0 |
| HIGH | 0 | 0 | 0 |
| MEDIUM | 0 | 1 | 0 |
| LOW | 0 | 1 | 0 |

---

## BUG-001 — Admin login React hydration warning (dev overlay)

| Field | Value |
|-------|-------|
| **Severity** | LOW |
| **Status** | FIXED (Sprint 12) |
| **Found** | 2026-08-10 Sprint 11 |
| **Area** | Admin Web — `/login` |
| **Role** | Owner |

**Steps**
1. Open `http://localhost:3001/login` in dev mode
2. Observe Next.js dev overlay hydration warning

**Expected:** No hydration mismatch warning  
**Actual:** Dev overlay reports hydration error referencing `login/page.tsx`  
**Impact:** Login still succeeds; dashboard loads. Dev-only overlay noise.  
**Fix:** Removed default phone/password from `useState` initial values in `admin-web/src/app/login/page.tsx` (Sprint 12).  
**Retest:** PASS — production builds unaffected

---

## BUG-002 — Customer notification list empty after full order lifecycle

| Field | Value |
|-------|-------|
| **Severity** | MEDIUM |
| **Status** | FIXED (Sprint 12) — not an application bug |
| **Found** | 2026-08-10 Sprint 11 |
| **Area** | Customer notifications |
| **UAT order** | `YL-20260810-000036` |

**Steps**
1. Complete full order lifecycle (create → pay → staff transitions → COMPLETED)
2. `GET /notifications` as Customer A

**Expected:** At least one operational notification if outlet templates enabled  
**Actual:** `notification_count: 0` in Sprint 11 API UAT run  
**Root cause:** Sprint 11 script called `GET /notifications` **before** order creation, not after lifecycle  
**Verification (Sprint 12):** Customer A has indexed notifications; order `YL-20260810-000036` has Order Created + Payment Successful; API returns items with valid JWT  
**Impact:** None — notification pipeline operational  
**Retest:** PASS

---

## Fixed during Sprint 11

| ID | Issue | Resolution |
|----|-------|------------|
| — | Sprint 11 UAT script used wrong address endpoint (`/customer-app/addresses`) | Fixed script to use `/customers/:customerId/addresses` — **not an application bug** |
| — | Sprint 11 UAT script used wrong admin paths (`/reports/summary`, `/audit-logs`) | Fixed script paths — **not an application bug** |

## Fixed during Sprint 12

| ID | Issue | Resolution |
|----|-------|------------|
| BUG-001 | Admin login hydration dev warning | Empty initial login form state |
| BUG-002 | Notification count 0 in UAT | UAT script timing; notifications verified in DB + API |

---

## Deferred (not bugs)

| Item | Reason |
|------|--------|
| No dedicated DRIVER seed account | MANAGER seed covers driver permissions locally |
| Payment gateway webhook | External deferred dependency |
| Production OTP delivery | External deferred dependency |

---

## Template for new bugs

```
### BUG-XXX — Title

| Field | Value |
|-------|-------|
| Severity | CRITICAL / HIGH / MEDIUM / LOW |
| Status | OPEN / FIXED / WON'T FIX |
| Found | YYYY-MM-DD |
| Area | |
| Role | |

**Steps**
1.

**Expected:**
**Actual:**
**Impact:**
**Fix:**
**Retest:**
```
