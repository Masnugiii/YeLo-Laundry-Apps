# Privacy Data Inventory

**Last updated:** 2026-08-10  
Derived from application code — not legal advice.

---

| Data | Purpose | Storage | Access | Retention | Third party |
|------|---------|---------|--------|-----------|-------------|
| Phone number | Auth (OTP), profile, orders | `customers`, `employees` tables | Customer self; staff RBAC | **NEEDS BUSINESS/LEGAL DECISION** | Future OTP provider |
| Full name, gender, age, occupation | Customer profile | `customers` | Customer self; staff RBAC | **NEEDS BUSINESS/LEGAL DECISION** | — |
| Profile photo | Avatar display | `uploads/customer-avatars/` + `photoUrl` | Customer self; staff view | Until deleted | — |
| Address (label, geo, recipient) | Pickup/delivery | `customer_addresses` | Customer CRUD; staff order ops | **NEEDS BUSINESS/LEGAL DECISION** | Google Maps (device SDK) |
| Order data (items, status, notes) | Laundry service | `orders`, related tables | Customer own orders; staff RBAC | **NEEDS BUSINESS/LEGAL DECISION** | — |
| Payment records | Billing, reconciliation | `payments`, wallet tables | Staff finance RBAC; customer own orders | **NEEDS BUSINESS/LEGAL DECISION** | Future payment gateway |
| Wallet balance / transactions | YELO wallet | `wallets`, `wallet_transactions` | Customer self; staff finance | **NEEDS BUSINESS/LEGAL DECISION** | — |
| Loyalty / Yelo points | Rewards program | loyalty tables | Customer self; staff read | **NEEDS BUSINESS/LEGAL DECISION** | — |
| CS tickets & messages | Customer support | `cs_tickets`, messages | Customer own; staff CS module | **NEEDS BUSINESS/LEGAL DECISION** | — |
| Notifications (in-app meta) | Operational alerts | `notifications` + `systemSetting` meta | Recipient only | **NEEDS BUSINESS/LEGAL DECISION** | Future push provider |
| Device tokens | Push (future) | `customer_devices` | Customer-linked | **NEEDS BUSINESS/LEGAL DECISION** | Future FCM/APNs |
| OTP codes (hashed) | Authentication | `otp_codes` | System only | Expires ~5 min | — |
| Audit logs | Security / compliance | `audit_logs` | Owner/manager | **NEEDS BUSINESS/LEGAL DECISION** | — |
| Employee HR/payroll | Internal ops | employee/payroll tables | Staff RBAC | **NEEDS BUSINESS/LEGAL DECISION** | — |

---

## In-app legal content

- Customer app: `privacy_policy_content.dart`, `terms_and_conditions_content.dart`
- Placeholder language notes official policy will be published via company channels

---

## Data not collected (verified in Sprint 12 scope)

- Production payment card PAN (no card gateway integrated)
- Social login identifiers (phone OTP only)

---

## Actions before public launch

1. Publish hosted privacy policy URL (matches store listing)
2. Complete Play Data Safety and Apple Privacy labels from this inventory
3. Define retention and deletion policy with legal counsel
4. Data Processing Agreement with OTP/payment providers when engaged
