# Yelo Laundry ERP — Role & Permission Matrix

> **Status:** Reflects current UI-level permissions. Backend authorization to be implemented.

---

## System Roles

| Role | Code | Login Mode | Device |
|------|------|------------|--------|
| Owner | `owner` | Owner | Management |
| Kasir | `cashier` | Kasir - HP Operasional | Shared cashier device |
| Operator | `cashierLaundry` | Kasir + Binatu - HP Pribadi | Personal phone |
| Manajer | `cashierLaundryDriver` | Kasir + Binatu + Driver - HP Pribadi | Personal phone |
| Binatu | `laundry` | Binatu | Ironing staff device |
| Driver | _(capability)_ | Embedded in Manajer | Personal phone |

---

## Module Permissions

| Module | Owner | Kasir | Operator | Manajer | Binatu |
|--------|:-----:|:-----:|:--------:|:-------:|:------:|
| Dashboard | ✅ | ✅ | ✅ | ✅ | ✅ |
| Customer | ✅ | ✅ | ✅ | ✅ | ❌ |
| Order | ✅ | ✅ | ✅ | ✅ | ❌ |
| Pickup & Delivery | ✅ | ✅ | ✅ | ✅ | ❌ |
| Yelo Wallet | ❌ | ✅ | ✅ | ✅ | ❌ |
| Notification Center | ✅ | ✅ | ✅ | ✅ | ✅ |
| Customer Service Center | ✅ | ✅ | ✅ | ✅ | ❌ |
| Settings | ✅ | ✅ | ✅ | ✅ | ✅ |
| Kehadiran (Personal) | ❌ | ❌ | ✅ | ✅ | ✅ |
| Kehadiran (All Employees) | ✅ | ❌ | ❌ | ❌ | ❌ |
| Expenses | ✅ | ❌ | ❌ | ❌ | ❌ |
| Reports | ✅ | ❌ | ❌ | ❌ | ❌ |
| Revenue | ✅ | ❌ | ❌ | ❌ | ❌ |
| Financial Report | ✅ | ❌ | ❌ | ❌ | ❌ |
| Employee KPI | ✅ | ❌ | ❌ | ❌ | ❌ |
| Employee Management | ✅ | ❌ | ❌ | ❌ | ❌ |
| Monitoring Binatu | ✅ | ❌ | ❌ | ❌ | ❌ |
| Ironing Queue | ❌ | ❌ | ❌ | ✅¹ | ✅ |
| Ironing Queue Assistance | ❌ | ❌ | ❌ | ✅ | ❌ |
| Kontribusi Operasional | ❌ | ❌ | ✅ | ✅ | ❌ |
| Order Queue (Binatu) | ❌ | ❌ | ❌ | ❌ | ✅ |
| AI Planner | ✅ | ❌ | ❌ | ❌ | ❌ |
| Laundry Profile | ✅ | ❌ | ❌ | ❌ | ❌ |
| Developer Menu | ✅ | ❌ | ❌ | ❌ | ❌ |

> ¹ Manager has Ironing Queue Assistance, not the full Binatu queue dashboard.

---

## Dashboard-Specific Menus

### Owner Dashboard

- Order Baru, Customer, Pickup & Delivery
- Kehadiran, Kinerja Karyawan, Monitoring Binatu
- Customer Service Center, Pengeluaran, Laporan
- Revenue, Laporan Keuangan, AI Planner

### Kasir Dashboard (HP Operasional)

- Order Baru, Customer, Yelo Wallet
- Pickup & Delivery, Notification Center, Customer Service Center
- **No** personal Kehadiran menu

### Operator Dashboard (Kasir + Binatu)

- All Kasir menus + Kehadiran (personal)
- Kontribusi Operasional
- Notification badges on Pickup & Delivery, Notification Center, CS

### Manager Dashboard (Kasir + Binatu + Driver)

- All Operator menus
- Ironing Queue Assistance
- Kontribusi Operasional
- Notification badges on Pickup & Delivery, Notification Center, CS

### Binatu Dashboard

- Ironing Queue, Currently Ironing, Finished Ironing, Ready for Pickup
- Kehadiran (personal)
- Notification badges per ironing queue category

---

## Route Access (UI Gate)

Routes are gated via `RolePermissions.moduleForPath()` in:

```
lib/core/role/role_permission.dart
```

| Route Prefix | Module |
|--------------|--------|
| `/dashboard-*` | Dashboard |
| `/customers` | Customer |
| `/new-order`, `/orders` | Order |
| `/pickup-delivery` | Pickup & Delivery |
| `/wallet` | Yelo Wallet |
| `/notifications` | Notification Center |
| `/customer-service` | Customer Service Center |
| `/attendance` | Attendance |
| `/monitoring-binatu` | Employee KPI |
| `/employee-performance` | Employee KPI |
| `/employee-master` | Employee Management |
| `/expenses` | Expenses |
| `/reports` | Reports |

---

## Notification Badge Permissions

| Dashboard | Badged Menus |
|-----------|--------------|
| Kasir | Pickup & Delivery, Notification Center, Customer Service |
| Operator | Pickup & Delivery, Notification Center, Customer Service |
| Manager | Pickup & Delivery, Notification Center, Customer Service |
| Binatu | Ironing Queue, Currently Ironing, Finished Ironing, Ready for Pickup |

Each badge resets independently when its module is opened.

---

## Future Backend Authorization

| Layer | Responsibility |
|-------|----------------|
| JWT Claims | Role + outlet ID |
| API Middleware | Route-level permission check |
| Database | Row-level security per outlet (TBD) |
| Audit Log | Permission-denied events |

---

## Role Hierarchy (Conceptual)

```
Owner
 └── Manajer (cashierLaundryDriver)
      └── Operator (cashierLaundry)
           └── Kasir (cashier)
                └── Binatu (laundry) — parallel ironing track
```

> Roles are not strictly hierarchical in permissions — Binatu has a specialized ironing-only scope.
