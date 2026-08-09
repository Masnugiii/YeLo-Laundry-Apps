# Yelo Laundry ERP — Folder Structure

> Documents the Flutter project structure as of the current UI implementation phase.

---

## Root Structure

```
yelo_laundry_erp/
├── android/                 # Android platform code
├── ios/                     # iOS platform code
├── assets/                  # Static assets (images, logos)
├── docs/                    # Project documentation
├── lib/                     # Application source code
├── test/                    # Unit & widget tests
├── pubspec.yaml             # Dependencies & project metadata
└── README.md                # Project readme
```

---

## `lib/` Structure

```
lib/
├── main.dart                # Application entry point
├── app/                     # App-level configuration
│   ├── app.dart             # MaterialApp root widget
│   ├── router/
│   │   └── app_router.dart  # go_router route definitions
│   ├── theme/               # Design tokens
│   │   ├── app_colors.dart
│   │   ├── app_radius.dart
│   │   ├── app_shadows.dart
│   │   ├── app_spacing.dart
│   │   ├── app_theme.dart
│   │   └── app_typography.dart
│   └── widgets/             # App-wide shared widgets
├── core/                    # Cross-cutting concerns
│   ├── constants/
│   ├── role/
│   │   ├── role.dart        # UserRole enum
│   │   └── role_permission.dart  # Module permissions
│   ├── session/
│   │   ├── dummy_session.dart
│   │   └── session_provider.dart
│   ├── services/
│   ├── storage/
│   └── utils/
│       ├── date_display_helper.dart
│       └── greeting_helper.dart
├── features/                # Feature modules (domain-driven)
│   └── <feature_name>/
│       ├── data/            # Dummy data & repositories (future)
│       ├── models/          # Domain models / entities
│       ├── providers/       # Riverpod state notifiers
│       ├── presentation/    # Screens & UI
│       │   └── widgets/     # Feature-specific widgets
│       └── utils/           # Feature-specific utilities
└── shared/
    └── widgets/             # Reusable widgets across features
        ├── erp_notification_badge.dart
        └── selectable_chip.dart
```

---

## Feature Modules

| Feature | Path | Description |
|---------|------|-------------|
| Auth | `lib/features/auth/` | Login, OTP, signup, login mode selection |
| Splash | `lib/features/splash/` | Splash screen |
| Dashboard | `lib/features/dashboard/` | Role-based dashboards (Owner, Kasir, Operator, Manager, Binatu) |
| Customer | `lib/features/customer/` | Customer list, detail, add customer |
| Orders | `lib/features/orders/` | Incoming orders, today orders, unpaid, laundry job queue |
| New Order | `lib/features/new_order/` | Order creation flow |
| Payments | `lib/features/payments/` | Payment transactions |
| Wallet | `lib/features/wallet/` | Yelo Wallet top-up, deduction, QRIS |
| Binatu | `lib/features/binatu/` | Ironing queue, order detail, settings |
| Binatu Monitoring | `lib/features/binatu_monitoring/` | Owner monitoring dashboard |
| Pickup & Delivery | `lib/features/pickup_delivery/` | Pickup/delivery requests |
| Attendance | `lib/features/attendance/` | Employee & personal attendance |
| Customer Service | `lib/features/customer_service/` | WhatsApp CS conversations |
| Notifications | `lib/features/notifications/` | Notification center |
| Employee Master | `lib/features/employee_master/` | Employee CRUD |
| Employee Performance | `lib/features/employee_performance/` | KPI & performance |
| Expenses | `lib/features/expenses/` | Expense tracking |
| Reports | `lib/features/reports/` | Revenue reports, AI planner |
| Points | `lib/features/points/` | Loyalty points |
| Receipt | `lib/features/receipt/` | Receipt preview & printing |
| Settings | `lib/features/settings/` | App settings, laundry profile |
| Setup Wizard | `lib/features/setup_wizard/` | Initial setup flow |
| Developer Tools | `lib/features/developer_tools/` | Dev utilities |
| Yelo Team | `lib/features/yelo_team/` | Team management |

---

## Dashboard Presentation Structure

```
lib/features/dashboard/presentation/
├── owner/
│   ├── owner_dashboard_screen.dart
│   └── widgets/              # PosHeader, PosMenuCard, PosStatCard, etc.
├── cashier/
│   ├── cashier_dashboard_screen.dart           # Kasir
│   ├── cashier_laundry_dashboard_screen.dart   # Operator
│   ├── cashier_laundry_driver_dashboard_screen.dart  # Manager
│   └── cashier_settings_screen.dart
├── binatu/
│   └── binatu_dashboard_screen.dart
└── widgets/
    ├── erp_bottom_navigation.dart
    ├── role_dashboard_shell.dart
    └── stat_card.dart
```

---

## Provider / State Management

```
lib/features/dashboard/providers/
├── cashier_dashboard_badge_provider.dart
├── operator_dashboard_badge_provider.dart
├── manager_dashboard_badge_provider.dart
├── dashboard_menu_badge_actions.dart
└── user_role_provider.dart

lib/features/binatu/providers/
├── binatu_order_provider.dart
├── binatu_dashboard_badge_provider.dart
├── binatu_notification_provider.dart
└── ironing_queue_priority_provider.dart
```

---

## Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Screen | `*_screen.dart` | `customers_screen.dart` |
| Widget | `*_card.dart`, `*_widget.dart` | `customer_card.dart` |
| Model | `*.dart` in `models/` | `customer.dart` |
| Provider | `*_provider.dart` | `binatu_order_provider.dart` |
| Dummy data | `dummy_*.dart` in `data/` | `dummy_customers.dart` |
| Theme token | `app_*.dart` in `app/theme/` | `app_colors.dart` |

---

## Feature Module Pattern

Each feature follows a consistent layered structure:

```
features/<name>/
├── data/           # Static dummy data (current phase)
├── models/         # Immutable data classes / enums
├── providers/      # Riverpod NotifierProvider
├── presentation/   # Screens
│   └── widgets/    # Private feature widgets
└── utils/          # Helpers (optional)
```

When backend is integrated, `data/` will expand to include:

```
data/
├── datasources/    # API & local data sources
├── repositories/   # Repository implementations
└── dummy_*.dart    # Fallback / dev data
```

---

## Assets

```
assets/
└── images/
    ├── Logo.png
    └── ...
```

Referenced in `pubspec.yaml` under `flutter: assets:`.

---

## Tests

```
test/
├── widget_test.dart         # App launch & dashboard overflow tests
└── greeting_helper_test.dart  # Unit tests
```

---

## Documentation

```
docs/
├── 01_PROJECT_OVERVIEW.md
├── 02_ERD.md
├── 03_DATA_DICTIONARY.md
├── 04_BUSINESS_RULES.md
├── 05_API_SPECIFICATION.md
├── 06_ROLE_PERMISSION.md
├── 07_ORDER_FLOW.md
├── 08_DATABASE_FLOW.md
├── 09_FOLDER_STRUCTURE.md
├── 10_CHANGELOG.md
└── cursor/                  # Sprint-specific notes
    └── sprint_01_architecture.md
```
