# Store Release Checklist

**Last updated:** 2026-08-10  
Store approval is an **EXTERNAL DEPENDENCY**.

---

## Google Play — Customer App

| Item | Value / status |
|------|----------------|
| Application name | Yelo Laundry (customer-facing) |
| Package / application ID | `com.yelolaundry.yelo_laundry_customer` |
| Release artifact | `app-release.aab` |
| App icon | Verify `customer_app` launcher assets |
| Feature graphic | **NEEDS MARKETING ASSET** |
| Screenshots | Phone + optional tablet |
| Short description | **NEEDS COPY** |
| Full description | **NEEDS COPY** |
| Privacy policy URL | Host public URL matching in-app policy |
| Content rating | Complete Play questionnaire |
| Data safety form | Map to `PRIVACY_DATA_INVENTORY.md` |
| Target audience | **NEEDS BUSINESS DECISION** |
| Testing track | Internal → closed → production |
| Production release | After UAT on production API |

---

## Google Play — Staff App (if published)

| Item | Notes |
|------|-------|
| Distribution | Prefer **internal / private** track (see `STAFF_APP_DISTRIBUTION.md`) |
| Package ID | Update from `com.example.yelo_laundry_erp` before listing |
| Not public by default | RBAC is security boundary |

---

## Apple App Store — Customer App

| Item | Value / status |
|------|----------------|
| Bundle ID | Configure in Xcode / Apple Developer |
| App name | Yelo Laundry Customer |
| Subtitle | **NEEDS COPY** |
| Description | **NEEDS COPY** |
| Screenshots | Required device sizes |
| App icon | 1024×1024 |
| Privacy nutrition labels | Map collected data types |
| Age rating | Complete questionnaire |
| Support URL | **NEEDS PUBLIC URL** |
| Privacy policy URL | **NEEDS PUBLIC URL** |
| TestFlight | Internal QA before submission |
| App Review | **EXTERNAL DEPENDENCY** |
| Production release | Manual release after approval |

---

## Apple — Staff App

| Item | Notes |
|------|-------|
| Distribution | Enterprise / Custom / TestFlight internal |
| App Store public listing | Not recommended by default |

---

## Pre-submission technical checks

- [ ] Release build uses production `API_BASE_URL` dart-define
- [ ] No dev preview entry in release binary (`DevPreviewGate` is `kDebugMode` only)
- [ ] Privacy policy and terms screens reachable in app
- [ ] OTP and payment flows tested against production backend
- [ ] Version/build number incremented
