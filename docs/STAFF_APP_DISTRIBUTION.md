# Staff App Distribution

**Last updated:** 2026-08-10

---

## Recommendation

The Staff app is an **internal operations tool**. Do not publish to public store listings by default.

Security boundary: **backend authentication + RBAC** (roles: Owner, Manager, Cashier, Operator, Binatu, Driver).

---

## Android

| Option | Use case |
|--------|----------|
| Google Play Internal testing | Small team, Google accounts required |
| Google Play Closed testing | Wider staff, invite-only |
| MDM / private APK | Direct install on company devices |
| Firebase App Distribution | Fast iteration without Play review |

**Current package ID:** `com.example.yelo_laundry_erp` — rename before distribution.

Build:

```bash
flutter build appbundle --release --dart-define=API_BASE_URL=<PRODUCTION_API_URL>
```

---

## iOS

| Option | Use case |
|--------|----------|
| TestFlight (internal) | Up to 100 internal testers |
| Custom / Enterprise distribution | Organization Apple Enterprise Program |
| Ad hoc (legacy) | Limited device UDIDs |

Requires Apple Developer Program (**EXTERNAL DEPENDENCY**).

---

## Operational controls

1. Issue staff credentials via admin employee module only
2. Disable departed employees (`status != active`)
3. Enforce strong passwords / **NEEDS POLICY** for password rotation
4. Distribute updates through same private channel
5. Log admin actions via audit logs

---

## Customer vs Staff

| App | Audience | Store visibility |
|-----|----------|------------------|
| Customer | End users | Public Play / App Store |
| Staff | Employees | Private / internal |
| Admin Web | Back office | Browser URL (not a store app) |
