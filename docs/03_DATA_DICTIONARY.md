# Yelo Laundry ERP — Data Dictionary

> **Status:** Official database reference — pre-Prisma implementation.  
> **Reference:** [02_ERD.md](./02_ERD.md)  
> **Database:** PostgreSQL-compatible types  
> **Total tables:** 33

---

## Conventions

| Convention | Rule |
|------------|------|
| Primary keys | `UUID` via `gen_random_uuid()` |
| Timestamps | `TIMESTAMP WITH TIME ZONE` stored as UTC |
| Money | `DECIMAL(15,2)` — never store calculated totals without source |
| Status fields | `VARCHAR` with application-layer enum validation |
| Soft delete | `deleted_at` on master and transactional tables where noted |
| Naming | `snake_case` for tables and columns |

---

## Module 1 — Authentication

---

### `users`

**Purpose:** Store system login accounts for all roles (Owner, Kasir, Operator, Manajer, Binatu).

**Primary Key:** `id`

**Foreign Keys:** None

| Column | Type | Nullable | Default | Constraint | Description |
|--------|------|----------|---------|------------|-------------|
| id | UUID | No | gen_random_uuid() | PK | Primary key |
| email | VARCHAR(150) | Yes | NULL | UNIQUE | Login email address |
| phone | VARCHAR(20) | No | — | UNIQUE | Login phone number (WhatsApp) |
| password_hash | VARCHAR(255) | No | — | | Bcrypt hashed password |
| status | VARCHAR(20) | No | 'active' | | Account status: active, inactive, suspended |
| last_login_at | TIMESTAMP | Yes | NULL | | Last successful login timestamp |
| created_at | TIMESTAMP | No | NOW() | | Record creation time |
| updated_at | TIMESTAMP | No | NOW() | | Last update time |
| deleted_at | TIMESTAMP | Yes | NULL | | Soft delete timestamp |

**Index Recommendations:**

| Index | Columns | Type | Reason |
|-------|---------|------|--------|
| `idx_users_phone` | `phone` | UNIQUE | Login lookup |
| `idx_users_email` | `email` | UNIQUE | Email login lookup |
| `idx_users_status` | `status` | BTREE | Filter active accounts |

---

### `roles`

**Purpose:** Define system roles and their codes for authorization.

**Primary Key:** `id`

**Foreign Keys:** None

| Column | Type | Nullable | Default | Constraint | Description |
|--------|------|----------|---------|------------|-------------|
| id | UUID | No | gen_random_uuid() | PK | Primary key |
| code | VARCHAR(50) | No | — | UNIQUE | Role code: owner, cashier, cashier_laundry, cashier_laundry_driver, laundry |
| name | VARCHAR(100) | No | — | | Display name: Owner, Kasir, Operator, Manajer, Binatu |
| description | TEXT | Yes | NULL | | Role description |
| is_active | BOOLEAN | No | TRUE | | Whether role is active |
| created_at | TIMESTAMP | No | NOW() | | Record creation time |
| updated_at | TIMESTAMP | No | NOW() | | Last update time |

**Index Recommendations:**

| Index | Columns | Type | Reason |
|-------|---------|------|--------|
| `idx_roles_code` | `code` | UNIQUE | Authorization lookup |

---

### `user_roles`

**Purpose:** Junction table assigning one or more roles to a user.

**Primary Key:** `id`

**Foreign Keys:**

| Column | References |
|--------|------------|
| `user_id` | `users.id` |
| `role_id` | `roles.id` |

| Column | Type | Nullable | Default | Constraint | Description |
|--------|------|----------|---------|------------|-------------|
| id | UUID | No | gen_random_uuid() | PK | Primary key |
| user_id | UUID | No | — | FK | Reference to users |
| role_id | UUID | No | — | FK | Reference to roles |
| assigned_at | TIMESTAMP | No | NOW() | | Role assignment timestamp |
| assigned_by | UUID | Yes | NULL | | User who assigned the role |
| created_at | TIMESTAMP | No | NOW() | | Record creation time |

**Index Recommendations:**

| Index | Columns | Type | Reason |
|-------|---------|------|--------|
| `idx_user_roles_user_id` | `user_id` | BTREE | User role lookup |
| `idx_user_roles_unique` | `user_id, role_id` | UNIQUE | Prevent duplicate assignments |

---

### `user_sessions`

**Purpose:** Store active login sessions and refresh tokens.

**Primary Key:** `id`

**Foreign Keys:**

| Column | References |
|--------|------------|
| `user_id` | `users.id` |

| Column | Type | Nullable | Default | Constraint | Description |
|--------|------|----------|---------|------------|-------------|
| id | UUID | No | gen_random_uuid() | PK | Primary key |
| user_id | UUID | No | — | FK | Reference to users |
| refresh_token_hash | VARCHAR(255) | No | — | UNIQUE | Hashed refresh token |
| device_info | VARCHAR(255) | Yes | NULL | | Device or browser identifier |
| ip_address | VARCHAR(45) | Yes | NULL | | Client IP address |
| expires_at | TIMESTAMP | No | — | | Session expiry time |
| revoked_at | TIMESTAMP | Yes | NULL | | Session revocation time |
| created_at | TIMESTAMP | No | NOW() | | Session creation time |

**Index Recommendations:**

| Index | Columns | Type | Reason |
|-------|---------|------|--------|
| `idx_user_sessions_user_id` | `user_id` | BTREE | Active sessions per user |
| `idx_user_sessions_expires_at` | `expires_at` | BTREE | Session cleanup job |

---

## Module 2 — Employee

---

### `employees`

**Purpose:** Store employee master data linked to system user accounts.

**Primary Key:** `id`

**Foreign Keys:**

| Column | References |
|--------|------------|
| `user_id` | `users.id` |

| Column | Type | Nullable | Default | Constraint | Description |
|--------|------|----------|---------|------------|-------------|
| id | UUID | No | gen_random_uuid() | PK | Primary key |
| user_id | UUID | Yes | NULL | FK, UNIQUE | Linked user account (nullable for non-login staff) |
| employee_code | VARCHAR(20) | No | — | UNIQUE | Internal employee code |
| full_name | VARCHAR(150) | No | — | | Employee full name |
| phone | VARCHAR(20) | No | — | | Contact phone number |
| position | VARCHAR(100) | No | — | | Job position: Kasir, Binatu, Driver, etc. |
| status | VARCHAR(20) | No | 'active' | | Employment status: active, inactive, resigned |
| hired_at | DATE | Yes | NULL | | Date of hire |
| created_at | TIMESTAMP | No | NOW() | | Record creation time |
| updated_at | TIMESTAMP | No | NOW() | | Last update time |
| deleted_at | TIMESTAMP | Yes | NULL | | Soft delete timestamp |

**Index Recommendations:**

| Index | Columns | Type | Reason |
|-------|---------|------|--------|
| `idx_employees_user_id` | `user_id` | UNIQUE | User-to-employee lookup |
| `idx_employees_code` | `employee_code` | UNIQUE | Employee code lookup |
| `idx_employees_status` | `status` | BTREE | Active employee filter |

---

## Module 3 — Customer

---

### `customers`

**Purpose:** Store all customer information for laundry service.

**Primary Key:** `id`

**Foreign Keys:** None

| Column | Type | Nullable | Default | Constraint | Description |
|--------|------|----------|---------|------------|-------------|
| id | UUID | No | gen_random_uuid() | PK | Primary key |
| customer_code | VARCHAR(20) | No | — | UNIQUE | Auto-generated customer code |
| full_name | VARCHAR(150) | No | — | | Customer full name |
| phone | VARCHAR(20) | No | — | UNIQUE | WhatsApp / contact number |
| email | VARCHAR(150) | Yes | NULL | | Email address |
| address | TEXT | Yes | NULL | | Primary address |
| loyalty_points | INTEGER | No | 0 | | Current loyalty point balance |
| status | VARCHAR(20) | No | 'active' | | Customer status: active, inactive |
| notes | TEXT | Yes | NULL | | Internal notes about customer |
| created_at | TIMESTAMP | No | NOW() | | Record creation time |
| updated_at | TIMESTAMP | No | NOW() | | Last update time |
| deleted_at | TIMESTAMP | Yes | NULL | | Soft delete timestamp |

**Index Recommendations:**

| Index | Columns | Type | Reason |
|-------|---------|------|--------|
| `idx_customers_phone` | `phone` | UNIQUE | Customer lookup by phone |
| `idx_customers_code` | `customer_code` | UNIQUE | Customer code lookup |
| `idx_customers_full_name` | `full_name` | BTREE | Name search |

---

### `customer_addresses`

**Purpose:** Store multiple delivery/pickup addresses per customer.

**Primary Key:** `id`

**Foreign Keys:**

| Column | References |
|--------|------------|
| `customer_id` | `customers.id` |

| Column | Type | Nullable | Default | Constraint | Description |
|--------|------|----------|---------|------------|-------------|
| id | UUID | No | gen_random_uuid() | PK | Primary key |
| customer_id | UUID | No | — | FK | Reference to customers |
| label | VARCHAR(50) | Yes | NULL | | Address label: Rumah, Kantor, etc. |
| address_line | TEXT | No | — | | Full address text |
| maps_query | VARCHAR(255) | Yes | NULL | | Google Maps search query |
| is_default | BOOLEAN | No | FALSE | | Default address flag |
| created_at | TIMESTAMP | No | NOW() | | Record creation time |
| updated_at | TIMESTAMP | No | NOW() | | Last update time |

**Index Recommendations:**

| Index | Columns | Type | Reason |
|-------|---------|------|--------|
| `idx_customer_addresses_customer_id` | `customer_id` | BTREE | Addresses per customer |

---

## Module 4 — Laundry Services

---

### `service_categories`

**Purpose:** Group laundry services into categories.

**Primary Key:** `id`

**Foreign Keys:** None

| Column | Type | Nullable | Default | Constraint | Description |
|--------|------|----------|---------|------------|-------------|
| id | UUID | No | gen_random_uuid() | PK | Primary key |
| code | VARCHAR(50) | No | — | UNIQUE | Category code |
| name | VARCHAR(100) | No | — | | Category display name |
| description | TEXT | Yes | NULL | | Category description |
| sort_order | INTEGER | No | 0 | | Display sort order |
| is_active | BOOLEAN | No | TRUE | | Active flag |
| created_at | TIMESTAMP | No | NOW() | | Record creation time |
| updated_at | TIMESTAMP | No | NOW() | | Last update time |

**Index Recommendations:**

| Index | Columns | Type | Reason |
|-------|---------|------|--------|
| `idx_service_categories_code` | `code` | UNIQUE | Category lookup |

---

### `services`

**Purpose:** Store laundry service catalog with pricing.

**Primary Key:** `id`

**Foreign Keys:**

| Column | References |
|--------|------------|
| `category_id` | `service_categories.id` |

| Column | Type | Nullable | Default | Constraint | Description |
|--------|------|----------|---------|------------|-------------|
| id | UUID | No | gen_random_uuid() | PK | Primary key |
| category_id | UUID | No | — | FK | Reference to service_categories |
| code | VARCHAR(50) | No | — | UNIQUE | Service code |
| name | VARCHAR(150) | No | — | | Service name |
| unit | VARCHAR(20) | No | 'kg' | | Pricing unit: kg, pcs, item |
| price_per_unit | DECIMAL(15,2) | No | — | | Price per unit in IDR |
| requires_ironing | BOOLEAN | No | FALSE | | Whether service requires Binatu |
| estimated_hours | INTEGER | Yes | NULL | | Estimated completion hours |
| is_active | BOOLEAN | No | TRUE | | Active flag |
| created_at | TIMESTAMP | No | NOW() | | Record creation time |
| updated_at | TIMESTAMP | No | NOW() | | Last update time |

**Index Recommendations:**

| Index | Columns | Type | Reason |
|-------|---------|------|--------|
| `idx_services_category_id` | `category_id` | BTREE | Services per category |
| `idx_services_code` | `code` | UNIQUE | Service lookup |
| `idx_services_is_active` | `is_active` | BTREE | Active service filter |

---

## Module 5 — Orders

---

### `orders`

**Purpose:** Store laundry order header information.

**Primary Key:** `id`

**Foreign Keys:**

| Column | References |
|--------|------------|
| `customer_id` | `customers.id` |
| `created_by` | `employees.id` |

| Column | Type | Nullable | Default | Constraint | Description |
|--------|------|----------|---------|------------|-------------|
| id | UUID | No | gen_random_uuid() | PK | Primary key |
| order_number | VARCHAR(30) | No | — | UNIQUE | Human-readable order number |
| customer_id | UUID | No | — | FK | Reference to customers |
| created_by | UUID | No | — | FK | Employee who created the order |
| status | VARCHAR(30) | No | 'new' | | Order status (see order_status_logs) |
| payment_status | VARCHAR(20) | No | 'unpaid' | | Payment status: unpaid, partial, paid |
| subtotal | DECIMAL(15,2) | No | 0 | | Sum of line items before discount |
| discount_amount | DECIMAL(15,2) | No | 0 | | Discount amount applied |
| total_amount | DECIMAL(15,2) | No | 0 | | Final order total |
| customer_notes | TEXT | Yes | NULL | | Notes from customer |
| internal_notes | TEXT | Yes | NULL | | Internal staff notes |
| order_date | TIMESTAMP | No | NOW() | | Order creation date |
| estimated_completion | TIMESTAMP | Yes | NULL | | Estimated completion datetime |
| completed_at | TIMESTAMP | Yes | NULL | | Actual completion datetime |
| created_at | TIMESTAMP | No | NOW() | | Record creation time |
| updated_at | TIMESTAMP | No | NOW() | | Last update time |
| deleted_at | TIMESTAMP | Yes | NULL | | Soft delete timestamp |

**Index Recommendations:**

| Index | Columns | Type | Reason |
|-------|---------|------|--------|
| `idx_orders_order_number` | `order_number` | UNIQUE | Order lookup |
| `idx_orders_customer_id` | `customer_id` | BTREE | Customer order history |
| `idx_orders_status` | `status` | BTREE | Status filter |
| `idx_orders_order_date` | `order_date` | BTREE | Date range queries |
| `idx_orders_payment_status` | `payment_status` | BTREE | Unpaid order filter |

---

### `order_items`

**Purpose:** Store individual service line items within an order.

**Primary Key:** `id`

**Foreign Keys:**

| Column | References |
|--------|------------|
| `order_id` | `orders.id` |
| `service_id` | `services.id` |

| Column | Type | Nullable | Default | Constraint | Description |
|--------|------|----------|---------|------------|-------------|
| id | UUID | No | gen_random_uuid() | PK | Primary key |
| order_id | UUID | No | — | FK | Reference to orders |
| service_id | UUID | No | — | FK | Reference to services |
| quantity | DECIMAL(10,3) | No | — | | Quantity (kg or pcs) |
| quantity_pcs | INTEGER | Yes | NULL | | Piece count if applicable |
| unit_price | DECIMAL(15,2) | No | — | | Price per unit at time of order |
| line_total | DECIMAL(15,2) | No | — | | Line item total |
| notes | TEXT | Yes | NULL | | Item-specific notes |
| created_at | TIMESTAMP | No | NOW() | | Record creation time |
| updated_at | TIMESTAMP | No | NOW() | | Last update time |

**Index Recommendations:**

| Index | Columns | Type | Reason |
|-------|---------|------|--------|
| `idx_order_items_order_id` | `order_id` | BTREE | Items per order |
| `idx_order_items_service_id` | `service_id` | BTREE | Service usage report |

---

### `order_status_logs`

**Purpose:** Audit trail of order status changes.

**Primary Key:** `id`

**Foreign Keys:**

| Column | References |
|--------|------------|
| `order_id` | `orders.id` |
| `changed_by` | `employees.id` |

| Column | Type | Nullable | Default | Constraint | Description |
|--------|------|----------|---------|------------|-------------|
| id | UUID | No | gen_random_uuid() | PK | Primary key |
| order_id | UUID | No | — | FK | Reference to orders |
| from_status | VARCHAR(30) | Yes | NULL | | Previous status |
| to_status | VARCHAR(30) | No | — | | New status |
| changed_by | UUID | Yes | NULL | FK | Employee who changed status |
| notes | TEXT | Yes | NULL | | Change notes |
| changed_at | TIMESTAMP | No | NOW() | | Status change timestamp |

**Index Recommendations:**

| Index | Columns | Type | Reason |
|-------|---------|------|--------|
| `idx_order_status_logs_order_id` | `order_id` | BTREE | Status history per order |
| `idx_order_status_logs_changed_at` | `changed_at` | BTREE | Timeline queries |

---

## Module 6 — Finance

---

### `wallets`

**Purpose:** Store customer prepaid wallet balance (one wallet per customer).

**Primary Key:** `id`

**Foreign Keys:**

| Column | References |
|--------|------------|
| `customer_id` | `customers.id` |

| Column | Type | Nullable | Default | Constraint | Description |
|--------|------|----------|---------|------------|-------------|
| id | UUID | No | gen_random_uuid() | PK | Primary key |
| customer_id | UUID | No | — | FK, UNIQUE | Reference to customers (1:1) |
| balance | DECIMAL(15,2) | No | 0 | | Current wallet balance in IDR |
| currency | VARCHAR(3) | No | 'IDR' | | Currency code |
| is_active | BOOLEAN | No | TRUE | | Wallet active flag |
| created_at | TIMESTAMP | No | NOW() | | Record creation time |
| updated_at | TIMESTAMP | No | NOW() | | Last update time |

**Index Recommendations:**

| Index | Columns | Type | Reason |
|-------|---------|------|--------|
| `idx_wallets_customer_id` | `customer_id` | UNIQUE | One wallet per customer |

---

### `wallet_transactions`

**Purpose:** Record all wallet credit and debit transactions.

**Primary Key:** `id`

**Foreign Keys:**

| Column | References |
|--------|------------|
| `wallet_id` | `wallets.id` |
| `customer_id` | `customers.id` |
| `order_id` | `orders.id` |
| `payment_id` | `payments.id` |
| `processed_by` | `employees.id` |

| Column | Type | Nullable | Default | Constraint | Description |
|--------|------|----------|---------|------------|-------------|
| id | UUID | No | gen_random_uuid() | PK | Primary key |
| wallet_id | UUID | No | — | FK | Reference to wallets |
| customer_id | UUID | No | — | FK | Reference to customers |
| order_id | UUID | Yes | NULL | FK | Related order (for deductions) |
| payment_id | UUID | Yes | NULL | FK | Related payment record |
| processed_by | UUID | Yes | NULL | FK | Employee who processed |
| transaction_type | VARCHAR(20) | No | — | | Type: top_up, deduction, refund |
| amount | DECIMAL(15,2) | No | — | | Transaction amount (always positive) |
| balance_before | DECIMAL(15,2) | No | — | | Balance before transaction |
| balance_after | DECIMAL(15,2) | No | — | | Balance after transaction |
| reference_number | VARCHAR(50) | Yes | NULL | UNIQUE | Transaction reference number |
| notes | TEXT | Yes | NULL | | Transaction notes |
| transaction_at | TIMESTAMP | No | NOW() | | Transaction timestamp |
| created_at | TIMESTAMP | No | NOW() | | Record creation time |

**Index Recommendations:**

| Index | Columns | Type | Reason |
|-------|---------|------|--------|
| `idx_wallet_transactions_wallet_id` | `wallet_id` | BTREE | Transaction history |
| `idx_wallet_transactions_customer_id` | `customer_id` | BTREE | Customer transaction history |
| `idx_wallet_transactions_reference` | `reference_number` | UNIQUE | Reference lookup |
| `idx_wallet_transactions_at` | `transaction_at` | BTREE | Date range reports |

---

### `payments`

**Purpose:** Record order payment transactions.

**Primary Key:** `id`

**Foreign Keys:**

| Column | References |
|--------|------------|
| `order_id` | `orders.id` |
| `processed_by` | `employees.id` |

| Column | Type | Nullable | Default | Constraint | Description |
|--------|------|----------|---------|------------|-------------|
| id | UUID | No | gen_random_uuid() | PK | Primary key |
| order_id | UUID | No | — | FK | Reference to orders |
| processed_by | UUID | No | — | FK | Employee who processed payment |
| payment_method | VARCHAR(20) | No | — | | Method: cash, qris, transfer, wallet |
| amount | DECIMAL(15,2) | No | — | | Payment amount in IDR |
| status | VARCHAR(20) | No | 'completed' | | Payment status: pending, completed, failed |
| reference_number | VARCHAR(50) | Yes | NULL | | External payment reference |
| paid_at | TIMESTAMP | No | NOW() | | Payment timestamp |
| created_at | TIMESTAMP | No | NOW() | | Record creation time |
| updated_at | TIMESTAMP | No | NOW() | | Last update time |

**Index Recommendations:**

| Index | Columns | Type | Reason |
|-------|---------|------|--------|
| `idx_payments_order_id` | `order_id` | BTREE | Payments per order |
| `idx_payments_paid_at` | `paid_at` | BTREE | Daily revenue report |
| `idx_payments_method` | `payment_method` | BTREE | Payment method report |

---

### `expenses`

**Purpose:** Record business operational expenses.

**Primary Key:** `id`

**Foreign Keys:**

| Column | References |
|--------|------------|
| `recorded_by` | `employees.id` |

| Column | Type | Nullable | Default | Constraint | Description |
|--------|------|----------|---------|------------|-------------|
| id | UUID | No | gen_random_uuid() | PK | Primary key |
| recorded_by | UUID | No | — | FK | Employee who recorded expense |
| category | VARCHAR(50) | No | — | | Expense category |
| description | TEXT | No | — | | Expense description |
| amount | DECIMAL(15,2) | No | — | | Expense amount in IDR |
| expense_date | DATE | No | — | | Date of expense |
| receipt_url | VARCHAR(500) | Yes | NULL | | Receipt image URL |
| created_at | TIMESTAMP | No | NOW() | | Record creation time |
| updated_at | TIMESTAMP | No | NOW() | | Last update time |

**Index Recommendations:**

| Index | Columns | Type | Reason |
|-------|---------|------|--------|
| `idx_expenses_expense_date` | `expense_date` | BTREE | Date range reports |
| `idx_expenses_category` | `category` | BTREE | Category reports |
| `idx_expenses_recorded_by` | `recorded_by` | BTREE | Expenses per employee |

---

## Module 7 — Attendance

---

### `attendances`

**Purpose:** Store daily employee attendance records.

**Primary Key:** `id`

**Foreign Keys:**

| Column | References |
|--------|------------|
| `employee_id` | `employees.id` |

| Column | Type | Nullable | Default | Constraint | Description |
|--------|------|----------|---------|------------|-------------|
| id | UUID | No | gen_random_uuid() | PK | Primary key |
| employee_id | UUID | No | — | FK | Reference to employees |
| work_date | DATE | No | — | | Attendance date |
| clock_in | TIMESTAMP | Yes | NULL | | Clock-in timestamp |
| clock_out | TIMESTAMP | Yes | NULL | | Clock-out timestamp |
| status | VARCHAR(20) | No | 'present' | | Status: present, absent, late, half_day |
| notes | TEXT | Yes | NULL | | Attendance notes |
| created_at | TIMESTAMP | No | NOW() | | Record creation time |
| updated_at | TIMESTAMP | No | NOW() | | Last update time |

**Index Recommendations:**

| Index | Columns | Type | Reason |
|-------|---------|------|--------|
| `idx_attendances_employee_date` | `employee_id, work_date` | UNIQUE | One record per employee per day |
| `idx_attendances_work_date` | `work_date` | BTREE | Daily attendance report |

---

### `attendance_logs`

**Purpose:** Audit trail of attendance clock-in/out events.

**Primary Key:** `id`

**Foreign Keys:**

| Column | References |
|--------|------------|
| `attendance_id` | `attendances.id` |

| Column | Type | Nullable | Default | Constraint | Description |
|--------|------|----------|---------|------------|-------------|
| id | UUID | No | gen_random_uuid() | PK | Primary key |
| attendance_id | UUID | No | — | FK | Reference to attendances |
| event_type | VARCHAR(20) | No | — | | Event: clock_in, clock_out |
| event_at | TIMESTAMP | No | NOW() | | Event timestamp |
| latitude | DECIMAL(10,7) | Yes | NULL | | GPS latitude |
| longitude | DECIMAL(10,7) | Yes | NULL | | GPS longitude |
| created_at | TIMESTAMP | No | NOW() | | Record creation time |

**Index Recommendations:**

| Index | Columns | Type | Reason |
|-------|---------|------|--------|
| `idx_attendance_logs_attendance_id` | `attendance_id` | BTREE | Events per attendance record |

---

## Module 8 — Binatu

---

### `ironing_jobs`

**Purpose:** Store ironing work assignments for Binatu staff.

**Primary Key:** `id`

**Foreign Keys:**

| Column | References |
|--------|------------|
| `order_id` | `orders.id` |
| `order_item_id` | `order_items.id` |
| `assigned_employee_id` | `employees.id` |

| Column | Type | Nullable | Default | Constraint | Description |
|--------|------|----------|---------|------------|-------------|
| id | UUID | No | gen_random_uuid() | PK | Primary key |
| order_id | UUID | No | — | FK | Reference to orders |
| order_item_id | UUID | Yes | NULL | FK | Reference to order_items |
| assigned_employee_id | UUID | Yes | NULL | FK | Assigned Binatu employee |
| status | VARCHAR(40) | No | 'waiting_for_binatu' | | Ironing status |
| weight_kg | DECIMAL(10,3) | Yes | NULL | | Ironing weight in kg |
| waiting_started_at | TIMESTAMP | Yes | NULL | | Queue wait start time |
| accepted_at | TIMESTAMP | Yes | NULL | | Job acceptance timestamp |
| started_at | TIMESTAMP | Yes | NULL | | Ironing start timestamp |
| finished_at | TIMESTAMP | Yes | NULL | | Ironing finish timestamp |
| ready_at | TIMESTAMP | Yes | NULL | | Ready for pickup timestamp |
| is_operator_assistance | BOOLEAN | No | FALSE | | Accepted via operator assistance |
| created_at | TIMESTAMP | No | NOW() | | Record creation time |
| updated_at | TIMESTAMP | No | NOW() | | Last update time |

**Index Recommendations:**

| Index | Columns | Type | Reason |
|-------|---------|------|--------|
| `idx_ironing_jobs_order_id` | `order_id` | BTREE | Jobs per order |
| `idx_ironing_jobs_status` | `status` | BTREE | Queue filter by status |
| `idx_ironing_jobs_assigned` | `assigned_employee_id` | BTREE | Jobs per Binatu employee |
| `idx_ironing_jobs_waiting_started` | `waiting_started_at` | BTREE | Priority queue sorting |

---

### `ironing_job_status_logs`

**Purpose:** Audit trail of ironing job status transitions.

**Primary Key:** `id`

**Foreign Keys:**

| Column | References |
|--------|------------|
| `ironing_job_id` | `ironing_jobs.id` |
| `changed_by` | `employees.id` |

| Column | Type | Nullable | Default | Constraint | Description |
|--------|------|----------|---------|------------|-------------|
| id | UUID | No | gen_random_uuid() | PK | Primary key |
| ironing_job_id | UUID | No | — | FK | Reference to ironing_jobs |
| from_status | VARCHAR(40) | Yes | NULL | | Previous status |
| to_status | VARCHAR(40) | No | — | | New status |
| changed_by | UUID | Yes | NULL | FK | Employee who changed status |
| notes | TEXT | Yes | NULL | | Change notes |
| changed_at | TIMESTAMP | No | NOW() | | Status change timestamp |

**Index Recommendations:**

| Index | Columns | Type | Reason |
|-------|---------|------|--------|
| `idx_ironing_job_status_logs_job_id` | `ironing_job_id` | BTREE | Status history per job |

---

### `ironing_queue_settings`

**Purpose:** Store Binatu ironing queue priority configuration per laundry outlet.

**Primary Key:** `id`

**Foreign Keys:**

| Column | References |
|--------|------------|
| `laundry_profile_id` | `laundry_profiles.id` |

| Column | Type | Nullable | Default | Constraint | Description |
|--------|------|----------|---------|------------|-------------|
| id | UUID | No | gen_random_uuid() | PK | Primary key |
| laundry_profile_id | UUID | No | — | FK | Reference to laundry_profiles |
| binatu_priority_minutes | INTEGER | No | 5 | | Minutes before operator assistance |
| is_enabled | BOOLEAN | No | TRUE | | Priority queue enabled flag |
| created_at | TIMESTAMP | No | NOW() | | Record creation time |
| updated_at | TIMESTAMP | No | NOW() | | Last update time |

**Index Recommendations:**

| Index | Columns | Type | Reason |
|-------|---------|------|--------|
| `idx_ironing_queue_settings_profile` | `laundry_profile_id` | BTREE | Settings per outlet |

---

## Module 9 — Pickup & Delivery

---

### `pickup_delivery_requests`

**Purpose:** Store pickup and delivery scheduling requests.

**Primary Key:** `id`

**Foreign Keys:**

| Column | References |
|--------|------------|
| `order_id` | `orders.id` |
| `customer_id` | `customers.id` |
| `assigned_employee_id` | `employees.id` |

| Column | Type | Nullable | Default | Constraint | Description |
|--------|------|----------|---------|------------|-------------|
| id | UUID | No | gen_random_uuid() | PK | Primary key |
| order_id | UUID | No | — | FK | Reference to orders |
| customer_id | UUID | No | — | FK | Reference to customers |
| assigned_employee_id | UUID | Yes | NULL | FK | Assigned driver/employee |
| request_type | VARCHAR(20) | No | — | | Type: pickup, delivery |
| status | VARCHAR(30) | No | 'scheduled' | | Status: scheduled, in_progress, completed, cancelled |
| customer_name | VARCHAR(150) | No | — | | Customer name snapshot |
| customer_phone | VARCHAR(20) | No | — | | Customer phone snapshot |
| address | TEXT | No | — | | Pickup/delivery address |
| maps_query | VARCHAR(255) | Yes | NULL | | Google Maps query string |
| scheduled_date | DATE | No | — | | Scheduled date |
| pickup_time | TIME | Yes | NULL | | Scheduled pickup time |
| delivery_time | TIME | Yes | NULL | | Scheduled delivery time |
| notes | TEXT | Yes | NULL | | Special instructions |
| completed_at | TIMESTAMP | Yes | NULL | | Completion timestamp |
| created_at | TIMESTAMP | No | NOW() | | Record creation time |
| updated_at | TIMESTAMP | No | NOW() | | Last update time |

**Index Recommendations:**

| Index | Columns | Type | Reason |
|-------|---------|------|--------|
| `idx_pickup_delivery_order_id` | `order_id` | BTREE | Requests per order |
| `idx_pickup_delivery_scheduled_date` | `scheduled_date` | BTREE | Today's schedule filter |
| `idx_pickup_delivery_status` | `status` | BTREE | Status filter |
| `idx_pickup_delivery_assigned` | `assigned_employee_id` | BTREE | Driver assignment lookup |

---

### `pickup_delivery_status_logs`

**Purpose:** Audit trail of pickup/delivery status changes.

**Primary Key:** `id`

**Foreign Keys:**

| Column | References |
|--------|------------|
| `request_id` | `pickup_delivery_requests.id` |
| `changed_by` | `employees.id` |

| Column | Type | Nullable | Default | Constraint | Description |
|--------|------|----------|---------|------------|-------------|
| id | UUID | No | gen_random_uuid() | PK | Primary key |
| request_id | UUID | No | — | FK | Reference to pickup_delivery_requests |
| from_status | VARCHAR(30) | Yes | NULL | | Previous status |
| to_status | VARCHAR(30) | No | — | | New status |
| changed_by | UUID | Yes | NULL | FK | Employee who changed status |
| notes | TEXT | Yes | NULL | | Change notes |
| changed_at | TIMESTAMP | No | NOW() | | Status change timestamp |

**Index Recommendations:**

| Index | Columns | Type | Reason |
|-------|---------|------|--------|
| `idx_pickup_delivery_status_logs_request` | `request_id` | BTREE | Status history per request |

---

## Module 10 — Notifications

---

### `notifications`

**Purpose:** Store in-app notifications for users and employees.

**Primary Key:** `id`

**Foreign Keys:**

| Column | References |
|--------|------------|
| `user_id` | `users.id` |
| `employee_id` | `employees.id` |
| `order_id` | `orders.id` |

| Column | Type | Nullable | Default | Constraint | Description |
|--------|------|----------|---------|------------|-------------|
| id | UUID | No | gen_random_uuid() | PK | Primary key |
| user_id | UUID | Yes | NULL | FK | Target user (if user-scoped) |
| employee_id | UUID | Yes | NULL | FK | Target employee (if employee-scoped) |
| order_id | UUID | Yes | NULL | FK | Related order |
| type | VARCHAR(50) | No | — | | Notification type code |
| title | VARCHAR(200) | No | — | | Notification title |
| message | TEXT | No | — | | Notification body |
| metadata | JSONB | Yes | NULL | | Additional structured data |
| created_at | TIMESTAMP | No | NOW() | | Notification creation time |

**Index Recommendations:**

| Index | Columns | Type | Reason |
|-------|---------|------|--------|
| `idx_notifications_user_id` | `user_id` | BTREE | Notifications per user |
| `idx_notifications_employee_id` | `employee_id` | BTREE | Notifications per employee |
| `idx_notifications_type` | `type` | BTREE | Filter by type |
| `idx_notifications_created_at` | `created_at` | BTREE | Chronological listing |

---

### `notification_reads`

**Purpose:** Track per-user read status for notifications.

**Primary Key:** `id`

**Foreign Keys:**

| Column | References |
|--------|------------|
| `notification_id` | `notifications.id` |
| `user_id` | `users.id` |

| Column | Type | Nullable | Default | Constraint | Description |
|--------|------|----------|---------|------------|-------------|
| id | UUID | No | gen_random_uuid() | PK | Primary key |
| notification_id | UUID | No | — | FK | Reference to notifications |
| user_id | UUID | No | — | FK | User who read notification |
| read_at | TIMESTAMP | No | NOW() | | Read timestamp |

**Index Recommendations:**

| Index | Columns | Type | Reason |
|-------|---------|------|--------|
| `idx_notification_reads_unique` | `notification_id, user_id` | UNIQUE | One read record per user per notification |
| `idx_notification_reads_user_id` | `user_id` | BTREE | Unread count queries |

---

## Module 11 — Customer Service

---

### `customer_service_conversations`

**Purpose:** Store WhatsApp customer service conversation threads.

**Primary Key:** `id`

**Foreign Keys:**

| Column | References |
|--------|------------|
| `customer_id` | `customers.id` |
| `order_id` | `orders.id` |

| Column | Type | Nullable | Default | Constraint | Description |
|--------|------|----------|---------|------------|-------------|
| id | UUID | No | gen_random_uuid() | PK | Primary key |
| customer_id | UUID | No | — | FK | Reference to customers |
| order_id | UUID | Yes | NULL | FK | Related order (if applicable) |
| whatsapp_number | VARCHAR(20) | No | — | | Customer WhatsApp number |
| ai_category | VARCHAR(30) | Yes | NULL | | AI-assigned category |
| ai_confidence | INTEGER | Yes | NULL | | AI confidence score (0–100) |
| is_unread | BOOLEAN | No | TRUE | | Unread conversation flag |
| last_message_at | TIMESTAMP | Yes | NULL | | Last message timestamp |
| created_at | TIMESTAMP | No | NOW() | | Record creation time |
| updated_at | TIMESTAMP | No | NOW() | | Last update time |

**Index Recommendations:**

| Index | Columns | Type | Reason |
|-------|---------|------|--------|
| `idx_cs_conversations_customer_id` | `customer_id` | BTREE | Conversations per customer |
| `idx_cs_conversations_is_unread` | `is_unread` | BTREE | Unread badge count |
| `idx_cs_conversations_last_message` | `last_message_at` | BTREE | Sort by recency |

---

### `customer_service_messages`

**Purpose:** Store individual messages within a customer service conversation.

**Primary Key:** `id`

**Foreign Keys:**

| Column | References |
|--------|------------|
| `conversation_id` | `customer_service_conversations.id` |
| `sent_by` | `employees.id` |

| Column | Type | Nullable | Default | Constraint | Description |
|--------|------|----------|---------|------------|-------------|
| id | UUID | No | gen_random_uuid() | PK | Primary key |
| conversation_id | UUID | No | — | FK | Reference to conversations |
| sent_by | UUID | Yes | NULL | FK | Employee sender (null if from customer) |
| is_from_customer | BOOLEAN | No | TRUE | | Message direction flag |
| content | TEXT | No | — | | Message text content |
| sent_at | TIMESTAMP | No | NOW() | | Message send timestamp |
| created_at | TIMESTAMP | No | NOW() | | Record creation time |

**Index Recommendations:**

| Index | Columns | Type | Reason |
|-------|---------|------|--------|
| `idx_cs_messages_conversation_id` | `conversation_id` | BTREE | Messages per conversation |
| `idx_cs_messages_sent_at` | `sent_at` | BTREE | Chronological message order |

---

## Module 12 — Settings

---

### `laundry_profiles`

**Purpose:** Store laundry outlet profile and business identity (root settings entity).

**Primary Key:** `id`

**Foreign Keys:** None

| Column | Type | Nullable | Default | Constraint | Description |
|--------|------|----------|---------|------------|-------------|
| id | UUID | No | gen_random_uuid() | PK | Primary key |
| business_name | VARCHAR(150) | No | — | | Laundry business name |
| address | TEXT | Yes | NULL | | Business address |
| phone | VARCHAR(20) | Yes | NULL | | Business phone |
| email | VARCHAR(150) | Yes | NULL | | Business email |
| logo_url | VARCHAR(500) | Yes | NULL | | Logo image URL |
| timezone | VARCHAR(50) | No | 'Asia/Jakarta' | | Business timezone |
| currency | VARCHAR(3) | No | 'IDR' | | Default currency |
| is_active | BOOLEAN | No | TRUE | | Outlet active flag |
| created_at | TIMESTAMP | No | NOW() | | Record creation time |
| updated_at | TIMESTAMP | No | NOW() | | Last update time |

**Index Recommendations:**

| Index | Columns | Type | Reason |
|-------|---------|------|--------|
| `idx_laundry_profiles_is_active` | `is_active` | BTREE | Active outlet filter |

---

### `receipt_settings`

**Purpose:** Store receipt printing and customization settings per outlet.

**Primary Key:** `id`

**Foreign Keys:**

| Column | References |
|--------|------------|
| `laundry_profile_id` | `laundry_profiles.id` |

| Column | Type | Nullable | Default | Constraint | Description |
|--------|------|----------|---------|------------|-------------|
| id | UUID | No | gen_random_uuid() | PK | Primary key |
| laundry_profile_id | UUID | No | — | FK, UNIQUE | Reference to laundry_profiles (1:1) |
| header_text | TEXT | Yes | NULL | | Receipt header text |
| footer_text | TEXT | Yes | NULL | | Receipt footer text |
| show_logo | BOOLEAN | No | TRUE | | Show logo on receipt |
| show_qr_code | BOOLEAN | No | FALSE | | Show QR code on receipt |
| printer_name | VARCHAR(100) | Yes | NULL | | Default printer name |
| created_at | TIMESTAMP | No | NOW() | | Record creation time |
| updated_at | TIMESTAMP | No | NOW() | | Last update time |

**Index Recommendations:**

| Index | Columns | Type | Reason |
|-------|---------|------|--------|
| `idx_receipt_settings_profile` | `laundry_profile_id` | UNIQUE | One settings record per outlet |

---

### `notification_settings`

**Purpose:** Store notification preference settings per outlet.

**Primary Key:** `id`

**Foreign Keys:**

| Column | References |
|--------|------------|
| `laundry_profile_id` | `laundry_profiles.id` |

| Column | Type | Nullable | Default | Constraint | Description |
|--------|------|----------|---------|------------|-------------|
| id | UUID | No | gen_random_uuid() | PK | Primary key |
| laundry_profile_id | UUID | No | — | FK, UNIQUE | Reference to laundry_profiles (1:1) |
| notify_new_order | BOOLEAN | No | TRUE | | Notify on new order |
| notify_payment | BOOLEAN | No | TRUE | | Notify on payment success |
| notify_ironing_finished | BOOLEAN | No | TRUE | | Notify on ironing complete |
| notify_pickup_delivery | BOOLEAN | No | TRUE | | Notify on pickup/delivery |
| notify_wallet | BOOLEAN | No | TRUE | | Notify on wallet transactions |
| created_at | TIMESTAMP | No | NOW() | | Record creation time |
| updated_at | TIMESTAMP | No | NOW() | | Last update time |

**Index Recommendations:**

| Index | Columns | Type | Reason |
|-------|---------|------|--------|
| `idx_notification_settings_profile` | `laundry_profile_id` | UNIQUE | One settings record per outlet |

---

### `order_number_settings`

**Purpose:** Store order number format configuration per outlet.

**Primary Key:** `id`

**Foreign Keys:**

| Column | References |
|--------|------------|
| `laundry_profile_id` | `laundry_profiles.id` |

| Column | Type | Nullable | Default | Constraint | Description |
|--------|------|----------|---------|------------|-------------|
| id | UUID | No | gen_random_uuid() | PK | Primary key |
| laundry_profile_id | UUID | No | — | FK, UNIQUE | Reference to laundry_profiles (1:1) |
| prefix | VARCHAR(10) | No | 'YL' | | Order number prefix |
| separator | VARCHAR(5) | No | '-' | | Number separator character |
| padding_length | INTEGER | No | 6 | | Numeric sequence padding |
| current_sequence | INTEGER | No | 0 | | Current sequence counter |
| reset_period | VARCHAR(10) | No | 'never' | | Reset period: never, daily, monthly, yearly |
| created_at | TIMESTAMP | No | NOW() | | Record creation time |
| updated_at | TIMESTAMP | No | NOW() | | Last update time |

**Index Recommendations:**

| Index | Columns | Type | Reason |
|-------|---------|------|--------|
| `idx_order_number_settings_profile` | `laundry_profile_id` | UNIQUE | One settings record per outlet |

---

### `user_preferences`

**Purpose:** Store per-user application preferences.

**Primary Key:** `id`

**Foreign Keys:**

| Column | References |
|--------|------------|
| `user_id` | `users.id` |

| Column | Type | Nullable | Default | Constraint | Description |
|--------|------|----------|---------|------------|-------------|
| id | UUID | No | gen_random_uuid() | PK | Primary key |
| user_id | UUID | No | — | FK, UNIQUE | Reference to users (1:1) |
| language | VARCHAR(10) | No | 'id' | | UI language preference |
| theme | VARCHAR(10) | No | 'light' | | UI theme: light, dark |
| push_notifications_enabled | BOOLEAN | No | TRUE | | Push notification opt-in |
| created_at | TIMESTAMP | No | NOW() | | Record creation time |
| updated_at | TIMESTAMP | No | NOW() | | Last update time |

**Index Recommendations:**

| Index | Columns | Type | Reason |
|-------|---------|------|--------|
| `idx_user_preferences_user_id` | `user_id` | UNIQUE | One preference record per user |

---

## Table Index

| # | Module | Table | PK | FK Count |
|---|--------|-------|----|----------|
| 1 | Authentication | `users` | `id` | 0 |
| 2 | Authentication | `roles` | `id` | 0 |
| 3 | Authentication | `user_roles` | `id` | 2 |
| 4 | Authentication | `user_sessions` | `id` | 1 |
| 5 | Employee | `employees` | `id` | 1 |
| 6 | Customer | `customers` | `id` | 0 |
| 7 | Customer | `customer_addresses` | `id` | 1 |
| 8 | Laundry Services | `service_categories` | `id` | 0 |
| 9 | Laundry Services | `services` | `id` | 1 |
| 10 | Orders | `orders` | `id` | 2 |
| 11 | Orders | `order_items` | `id` | 2 |
| 12 | Orders | `order_status_logs` | `id` | 2 |
| 13 | Finance | `wallets` | `id` | 1 |
| 14 | Finance | `wallet_transactions` | `id` | 5 |
| 15 | Finance | `payments` | `id` | 2 |
| 16 | Finance | `expenses` | `id` | 1 |
| 17 | Attendance | `attendances` | `id` | 1 |
| 18 | Attendance | `attendance_logs` | `id` | 1 |
| 19 | Binatu | `ironing_jobs` | `id` | 3 |
| 20 | Binatu | `ironing_job_status_logs` | `id` | 2 |
| 21 | Binatu | `ironing_queue_settings` | `id` | 1 |
| 22 | Pickup & Delivery | `pickup_delivery_requests` | `id` | 3 |
| 23 | Pickup & Delivery | `pickup_delivery_status_logs` | `id` | 2 |
| 24 | Notifications | `notifications` | `id` | 3 |
| 25 | Notifications | `notification_reads` | `id` | 2 |
| 26 | Customer Service | `customer_service_conversations` | `id` | 2 |
| 27 | Customer Service | `customer_service_messages` | `id` | 2 |
| 28 | Settings | `laundry_profiles` | `id` | 0 |
| 29 | Settings | `receipt_settings` | `id` | 1 |
| 30 | Settings | `notification_settings` | `id` | 1 |
| 31 | Settings | `order_number_settings` | `id` | 1 |
| 32 | Settings | `user_preferences` | `id` | 1 |

**Total: 32 tables documented** (matches ERD entity relationships; `ironing_queue_settings` counted under Binatu module per ERD Section 8)

---

## Enum Reference (Application Layer)

These values are stored as `VARCHAR` and validated in application code:

| Field | Allowed Values |
|-------|----------------|
| `users.status` | `active`, `inactive`, `suspended` |
| `roles.code` | `owner`, `cashier`, `cashier_laundry`, `cashier_laundry_driver`, `laundry` |
| `orders.status` | `new`, `in_progress`, `washing`, `drying`, `ironing`, `quality_check`, `ready_for_pickup`, `completed`, `cancelled` |
| `orders.payment_status` | `unpaid`, `partial`, `paid` |
| `payments.payment_method` | `cash`, `qris`, `transfer`, `wallet` |
| `wallet_transactions.transaction_type` | `top_up`, `deduction`, `refund` |
| `ironing_jobs.status` | `waiting_for_binatu`, `waiting_for_operator_assistance`, `accepted_by_binatu`, `currently_ironing`, `finished_ironing`, `ready_for_pickup` |
| `pickup_delivery_requests.request_type` | `pickup`, `delivery` |
| `pickup_delivery_requests.status` | `scheduled`, `in_progress`, `completed`, `cancelled` |
| `attendances.status` | `present`, `absent`, `late`, `half_day` |
| `notifications.type` | `new_order`, `cash_payment`, `qris_payment`, `transfer_payment`, `wallet_top_up`, `wallet_deduction`, `binatu_accepted`, `ironing_finished`, `ready_for_pickup`, `pickup_request`, `delivery_request`, `expense_recorded` |
| `customer_service_conversations.ai_category` | `order_baru`, `komplain`, `pertanyaan`, `tracking_order`, `promo`, `lainnya` |

---

## Related Documents

- [02_ERD.md](./02_ERD.md) — Entity Relationship Diagram (unchanged)
