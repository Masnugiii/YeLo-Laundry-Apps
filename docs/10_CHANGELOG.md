# Yelo Laundry ERP — Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Planned
- Backend REST API implementation
- Database schema & migrations
- Real authentication (JWT / OTP)
- Push notifications
- WhatsApp API integration
- Receipt printer integration
- Offline mode support

---

## [1.0.0] — 2026-08-08

### Added

#### Core
- Flutter project setup with Material Design 3 theme
- Google Fonts (Poppins) typography
- Primary color `#033B8E`, accent `#F8D613`
- go_router navigation with role-based route guards
- Riverpod state management
- Shared `ErpNotificationBadge` component

#### Authentication (UI)
- Login mode selection (5 modes: Owner, Kasir, Operator, Manager, Binatu)
- Login, OTP, signup, and register screens
- Dummy session provider

#### Dashboards
- Owner Dashboard with operational summary, financial KPIs, and full menu
- Kasir Dashboard (HP Operasional)
- Operator Dashboard (Kasir + Binatu - HP Pribadi)
- Manager Dashboard (Kasir + Binatu + Driver - HP Pribadi)
- Binatu Dashboard with ironing queue menus

#### Features (UI + Dummy Data)
- Customer management (list, detail, add)
- Order management (incoming, today, unpaid, new order)
- Payment processing (Cash, QRIS, Transfer, Wallet)
- Yelo Wallet (top-up, deduction, QRIS payment)
- Pickup & Delivery management
- Customer Service Center (WhatsApp conversations, AI categorization)
- Notification Center (role-scoped notifications)
- Employee attendance (all employees + personal)
- Employee master & performance KPI
- Binatu ironing queue with priority settings
- Operator ironing assistance flow
- Owner Monitoring Binatu with date filters
- Expenses, reports, revenue, AI planner
- Loyalty points system
- Receipt preview
- Settings (notifications, security, receipt customization)

#### Notification Badges
- Kasir, Operator, Manager: Pickup & Delivery, Notification Center, Customer Service
- Binatu: Ironing Queue, Currently Ironing, Finished Ironing, Ready for Pickup
- Independent badge reset per module

#### Documentation
- Project documentation structure in `docs/`
- ERD, data dictionary, business rules, API spec placeholders
- Role permission matrix, order flow, database flow
- Folder structure reference

### Changed
- N/A (initial release)

### Fixed
- GridView overflow on Monitoring Binatu summary cards
- Riverpod notifier modification during build (BinatuOrderNotifier)
- Date selector horizontal overflow on small screens

### Removed
- Driver menu from Manager dashboard (permissions retained)

---

## Version History Template

Use this template for future entries:

```markdown
## [X.Y.Z] — YYYY-MM-DD

### Added
- New feature description

### Changed
- Change description

### Fixed
- Bug fix description

### Removed
- Removed feature description

### Security
- Security fix description
```

---

## Versioning Guide

| Version Part | When to Increment |
|--------------|-------------------|
| **MAJOR** (X.0.0) | Breaking API changes, major architecture overhaul |
| **MINOR** (0.X.0) | New features, new modules, backward-compatible |
| **PATCH** (0.0.X) | Bug fixes, UI tweaks, documentation updates |

---

## Sprint Log

| Sprint | Focus | Status |
|--------|-------|--------|
| Sprint 01 | Flutter UI architecture, role dashboards, dummy data | ✅ Complete |
| Sprint 02 | Backend API & database | ⏳ Planned |
| Sprint 03 | Authentication & authorization | ⏳ Planned |
| Sprint 04 | Push notifications & integrations | ⏳ Planned |
