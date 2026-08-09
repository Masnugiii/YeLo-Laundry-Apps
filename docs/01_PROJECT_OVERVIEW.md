# Yelo Laundry ERP — Project Overview

## Project Name

**Yelo Laundry ERP**

## Objective

Yelo Laundry ERP is a mobile-first enterprise resource planning application for laundry businesses. It centralizes daily operations including customer management, order processing, payments, wallet transactions, employee attendance, ironing workflow (Binatu), pickup & delivery, customer service, notifications, and owner reporting.

The current phase focuses on **Flutter UI implementation with dummy data**. Backend integration is planned for a future sprint.

## Target Platform

| Platform | Status |
|----------|--------|
| Android | Primary target |
| iOS | Primary target |
| Web | Future consideration |
| Desktop | Not in scope (Phase 1) |

### Device Context

| Login Mode | Device Context |
|------------|----------------|
| Owner | Management device |
| Kasir - HP Operasional | Shared cashier device at front desk |
| Kasir + Binatu - HP Pribadi | Employee personal phone (Operator) |
| Kasir + Binatu + Driver - HP Pribadi | Employee personal phone (Manager) |
| Binatu | Ironing staff device |

## User Roles

| Role | Code | Description |
|------|------|-------------|
| Owner | `owner` | Full access to business operations, reports, employee KPI, monitoring |
| Kasir | `cashier` | Operational cashier on shared device |
| Operator | `cashierLaundry` | Kasir + Binatu on personal device |
| Manajer | `cashierLaundryDriver` | Kasir + Binatu + Driver on personal device |
| Binatu | `laundry` | Ironing staff — queue and job management |
| Driver | _(embedded in Manager role)_ | Pickup & delivery operations |

> **Note:** Driver is currently implemented as a capability within the Manager (`cashierLaundryDriver`) role, not as a standalone dashboard.

## Technology Stack

### Frontend (Current)

| Layer | Technology |
|-------|------------|
| Framework | Flutter 3.x |
| Language | Dart 3.12+ |
| State Management | Riverpod |
| Routing | go_router |
| Typography | Google Fonts (Poppins) |
| Design System | Material Design 3 |
| Primary Color | `#033B8E` |
| Accent Color | `#F8D613` |

### Backend (Planned — Not Implemented)

| Layer | Technology (TBD) |
|-------|------------------|
| API | REST |
| Authentication | JWT / Session-based (TBD) |
| Database | Relational DB (TBD) |
| ORM | TBD |
| Push Notifications | TBD |
| WhatsApp Integration | TBD |

### Project Structure

```
yelo_laundry_erp/
├── lib/           # Flutter application source
├── assets/        # Images, fonts, static files
├── test/          # Unit & widget tests
├── docs/          # Project documentation
└── pubspec.yaml   # Dependencies & metadata
```

## Current Development Status

- ✅ Role-based dashboards (Owner, Kasir, Operator, Manager, Binatu)
- ✅ Feature modules with dummy data
- ✅ Navigation, permissions (UI-level), and notification badges
- ⏳ Backend API — not started
- ⏳ Database — not started
- ⏳ Real authentication — not started

## Related Documentation

| Document | Description |
|----------|-------------|
| [02_ERD.md](./02_ERD.md) | Entity Relationship Diagram |
| [03_DATA_DICTIONARY.md](./03_DATA_DICTIONARY.md) | Table & field definitions |
| [04_BUSINESS_RULES.md](./04_BUSINESS_RULES.md) | Business logic rules |
| [05_API_SPECIFICATION.md](./05_API_SPECIFICATION.md) | REST API specification (placeholder) |
| [06_ROLE_PERMISSION.md](./06_ROLE_PERMISSION.md) | Role & permission matrix |
| [07_ORDER_FLOW.md](./07_ORDER_FLOW.md) | Order lifecycle |
| [08_DATABASE_FLOW.md](./08_DATABASE_FLOW.md) | Database relationships |
| [09_FOLDER_STRUCTURE.md](./09_FOLDER_STRUCTURE.md) | Flutter project structure |
| [10_CHANGELOG.md](./10_CHANGELOG.md) | Version history |
