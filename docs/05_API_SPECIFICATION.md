# Yelo Laundry ERP — REST API Specification

> **Status:** Official API contract — pre-backend implementation.  
> **Base URL:** `/api/v1`  
> **References:** [02_ERD.md](./02_ERD.md) · [03_DATA_DICTIONARY.md](./03_DATA_DICTIONARY.md) · [04_BUSINESS_RULES.md](./04_BUSINESS_RULES.md)

---

## Table of Contents

1. [Global Conventions](#1-global-conventions)
2. [Authentication](#2-authentication)
3. [Employees](#3-employees)
4. [Customers](#4-customers)
5. [Laundry Services](#5-laundry-services)
6. [Orders](#6-orders)
7. [Payments](#7-payments)
8. [Wallet](#8-wallet)
9. [Attendance](#9-attendance)
10. [Binatu](#10-binatu)
11. [Pickup & Delivery](#11-pickup--delivery)
12. [Notifications](#12-notifications)
13. [Customer Service](#13-customer-service)
14. [Settings](#14-settings)
15. [Appendix](#15-appendix)

---

## 1. Global Conventions

### 1.1 Base URL

| Environment | URL |
|-------------|-----|
| Production | `https://api.yelo-laundry.com/api/v1` |
| Staging | `https://staging-api.yelo-laundry.com/api/v1` |
| Development | `http://localhost:3000/api/v1` |

All endpoints below are relative to `/api/v1`.

### 1.2 Authentication

Protected endpoints require a JWT Bearer token:

```http
Authorization: Bearer <access_token>
```

| Token | Lifetime | Usage |
|-------|----------|-------|
| Access Token | 15 minutes | API requests |
| Refresh Token | 30 days | Token renewal via `POST /auth/refresh` |

### 1.3 Standard Response Envelope

**Success (single resource):**

```json
{
  "success": true,
  "message": "Resource retrieved successfully",
  "data": { }
}
```

**Success (collection with pagination):**

```json
{
  "success": true,
  "message": "Resources retrieved successfully",
  "data": [ ],
  "meta": {
    "page": 1,
    "per_page": 20,
    "total": 150,
    "total_pages": 8
  }
}
```

### 1.4 Standard Error Responses

| HTTP | Condition | Body |
|------|-----------|------|
| `401` | Missing or invalid token | `{ "success": false, "message": "Unauthorized" }` |
| `403` | Valid token, insufficient role | `{ "success": false, "message": "Forbidden" }` |
| `404` | Resource not found | `{ "success": false, "message": "Not Found" }` |
| `422` | Validation failed | `{ "success": false, "message": "Validation Error", "errors": { } }` |
| `500` | Server error | `{ "success": false, "message": "Internal Server Error" }` |

**Validation error example:**

```json
{
  "success": false,
  "message": "Validation Error",
  "errors": {
    "phone": ["The phone field must be a valid Indonesian mobile number."],
    "full_name": ["The full name field is required."]
  }
}
```

### 1.5 Common Query Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `page` | integer | Page number (default: `1`) |
| `per_page` | integer | Items per page (default: `20`, max: `100`) |
| `sort` | string | Sort field (prefix `-` for descending, e.g. `-created_at`) |
| `search` | string | Full-text or field search (module-specific) |

### 1.6 Role Codes

| Code | Display |
|------|---------|
| `owner` | Owner |
| `cashier` | Kasir |
| `cashier_laundry` | Operator |
| `cashier_laundry_driver` | Manajer |
| `laundry` | Binatu |

### 1.7 Data Types

| Type | Format |
|------|--------|
| UUID | `550e8400-e29b-41d4-a716-446655440000` |
| Money | `DECIMAL(15,2)` as JSON number (e.g. `125000.00`) |
| Date | `YYYY-MM-DD` |
| DateTime | ISO 8601 UTC (`2026-08-08T03:29:00Z`) |
| Phone | Normalized `+6281234567890` |

---

## 2. Authentication

### 2.1 Login

| Property | Value |
|----------|-------|
| **Endpoint Name** | Login |
| **HTTP Method** | `POST` |
| **URL** | `/auth/login` |
| **Description** | Authenticate user with phone/email and password. Returns JWT access and refresh tokens. |
| **Authentication Required** | No |

**Request Body:**

```json
{
  "identifier": "+6281234567890",
  "password": "secretPassword123",
  "device_info": "Flutter ERP / Android 14",
  "role_code": "cashier"
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `identifier` | string | Yes | Phone (`+62…`) or email |
| `password` | string | Yes | Plain-text password (hashed server-side) |
| `device_info` | string | No | Device identifier for session tracking |
| `role_code` | string | No | Preferred role when user has multiple roles |

**Success Response — `200 OK`:**

```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIs...",
    "refresh_token": "dGhpcyBpcyBhIHJlZnJlc2g...",
    "token_type": "Bearer",
    "expires_in": 900,
    "user": {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "phone": "+6281234567890",
      "email": null,
      "status": "active",
      "roles": ["cashier"],
      "employee": {
        "id": "660e8400-e29b-41d4-a716-446655440001",
        "employee_code": "EMP-001",
        "full_name": "Budi Santoso",
        "position": "Kasir"
      }
    }
  }
}
```

**Error Responses:**

| HTTP | Condition |
|------|-----------|
| `401` | Invalid credentials |
| `403` | Account `inactive` or `suspended` |
| `422` | Missing or invalid fields |

**Validation Rules:**

- `identifier` must be valid phone or email format
- `password` minimum 8 characters
- User `status` must be `active` (AUTH-004)
- `role_code`, if provided, must be assigned to the user

---

### 2.2 Logout

| Property | Value |
|----------|-------|
| **Endpoint Name** | Logout |
| **HTTP Method** | `POST` |
| **URL** | `/auth/logout` |
| **Description** | Revoke current session (sets `user_sessions.revoked_at`). |
| **Authentication Required** | Yes |

**Request Body:**

```json
{
  "refresh_token": "dGhpcyBpcyBhIHJlZnJlc2g..."
}
```

**Success Response — `200 OK`:**

```json
{
  "success": true,
  "message": "Logout successful",
  "data": null
}
```

**Error Responses:** `401`

**Validation Rules:**

- `refresh_token` required and must match an active session

---

### 2.3 Refresh Token

| Property | Value |
|----------|-------|
| **Endpoint Name** | Refresh Token |
| **HTTP Method** | `POST` |
| **URL** | `/auth/refresh` |
| **Description** | Exchange a valid refresh token for a new access token (and optionally rotated refresh token). |
| **Authentication Required** | No (uses refresh token in body) |

**Request Body:**

```json
{
  "refresh_token": "dGhpcyBpcyBhIHJlZnJlc2g..."
}
```

**Success Response — `200 OK`:**

```json
{
  "success": true,
  "message": "Token refreshed successfully",
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIs...",
    "refresh_token": "bmV3IHJlZnJlc2ggdG9rZW4...",
    "token_type": "Bearer",
    "expires_in": 900
  }
}
```

**Error Responses:**

| HTTP | Condition |
|------|-----------|
| `401` | Expired or revoked refresh token |

---

### 2.4 Send OTP

| Property | Value |
|----------|-------|
| **Endpoint Name** | Send OTP |
| **HTTP Method** | `POST` |
| **URL** | `/auth/otp/send` |
| **Description** | Send a one-time password via WhatsApp/SMS for passwordless login (ERP staff or Customer Mobile App). |
| **Authentication Required** | No |

**Request Body:**

```json
{
  "phone": "+6281234567890",
  "purpose": "login"
}
```

| Field | Type | Required | Values |
|-------|------|----------|--------|
| `phone` | string | Yes | Indonesian mobile number |
| `purpose` | string | Yes | `login`, `register`, `password_reset` |

**Success Response — `200 OK`:**

```json
{
  "success": true,
  "message": "OTP sent successfully",
  "data": {
    "otp_request_id": "770e8400-e29b-41d4-a716-446655440002",
    "expires_in": 300,
    "masked_phone": "+62812****7890"
  }
}
```

**Error Responses:** `422`, `429` (rate limit)

**Validation Rules:**

- Phone must match `^(\+62|62|0)8[1-9][0-9]{6,11}$` (CUS-004)
- Rate limit: max 3 OTP requests per phone per 15 minutes

---

### 2.5 Verify OTP

| Property | Value |
|----------|-------|
| **Endpoint Name** | Verify OTP |
| **HTTP Method** | `POST` |
| **URL** | `/auth/otp/verify` |
| **Description** | Verify OTP code and issue JWT tokens on success. |
| **Authentication Required** | No |

**Request Body:**

```json
{
  "otp_request_id": "770e8400-e29b-41d4-a716-446655440002",
  "phone": "+6281234567890",
  "otp_code": "482910",
  "device_info": "Customer App / iOS 17"
}
```

**Success Response — `200 OK`:**

```json
{
  "success": true,
  "message": "OTP verified successfully",
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIs...",
    "refresh_token": "dGhpcyBpcyBhIHJlZnJlc2g...",
    "token_type": "Bearer",
    "expires_in": 900,
    "user": {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "phone": "+6281234567890",
      "roles": ["cashier"]
    }
  }
}
```

**Error Responses:**

| HTTP | Condition |
|------|-----------|
| `401` | Invalid or expired OTP |
| `422` | Invalid request body |

**Validation Rules:**

- `otp_code` must be exactly 6 digits
- OTP expires after 5 minutes
- Max 5 failed attempts per `otp_request_id`

---

### 2.6 Profile

| Property | Value |
|----------|-------|
| **Endpoint Name** | Get Profile |
| **HTTP Method** | `GET` |
| **URL** | `/auth/profile` |
| **Description** | Return authenticated user profile, roles, and linked employee record. |
| **Authentication Required** | Yes |

**Request Parameters:** None

**Success Response — `200 OK`:**

```json
{
  "success": true,
  "message": "Profile retrieved successfully",
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "phone": "+6281234567890",
    "email": "owner@yelo-laundry.com",
    "status": "active",
    "last_login_at": "2026-08-08T03:00:00Z",
    "roles": [
      { "code": "owner", "name": "Owner" }
    ],
    "employee": {
      "id": "660e8400-e29b-41d4-a716-446655440001",
      "employee_code": "EMP-001",
      "full_name": "Ahmad Owner",
      "position": "Owner",
      "status": "active"
    },
    "preferences": {
      "language": "id",
      "theme": "light",
      "push_notifications_enabled": true
    }
  }
}
```

**Error Responses:** `401`

---

| Property | Value |
|----------|-------|
| **Endpoint Name** | Update Profile |
| **HTTP Method** | `PATCH` |
| **URL** | `/auth/profile` |
| **Description** | Update user preferences and optional email. |
| **Authentication Required** | Yes |

**Request Body:**

```json
{
  "email": "newemail@yelo-laundry.com",
  "preferences": {
    "language": "id",
    "theme": "dark",
    "push_notifications_enabled": false
  }
}
```

**Success Response — `200 OK`:** Same shape as GET profile.

**Validation Rules:**

- `email`, if provided, must be unique
- `theme` must be `light` or `dark`
- `language` must be supported locale code

---

## 3. Employees

> **Authorization:** `owner` only for all employee endpoints.

### 3.1 Employee List

| Property | Value |
|----------|-------|
| **Endpoint Name** | Employee List |
| **HTTP Method** | `GET` |
| **URL** | `/employees` |
| **Description** | Paginated list of employees with optional status and position filters. |
| **Authentication Required** | Yes (`owner`) |

**Request Parameters (Query):**

| Parameter | Type | Description |
|-----------|------|-------------|
| `page` | integer | Page number |
| `per_page` | integer | Items per page |
| `status` | string | Filter: `active`, `inactive`, `resigned` |
| `position` | string | Filter by position |
| `search` | string | Search `full_name`, `employee_code`, `phone` |

**Success Response — `200 OK`:**

```json
{
  "success": true,
  "message": "Employees retrieved successfully",
  "data": [
    {
      "id": "660e8400-e29b-41d4-a716-446655440001",
      "employee_code": "EMP-001",
      "full_name": "Budi Santoso",
      "phone": "+6281234567890",
      "position": "Kasir",
      "status": "active",
      "hired_at": "2024-01-15",
      "user_id": "550e8400-e29b-41d4-a716-446655440000",
      "created_at": "2024-01-15T08:00:00Z"
    }
  ],
  "meta": { "page": 1, "per_page": 20, "total": 12, "total_pages": 1 }
}
```

**Error Responses:** `401`, `403`

---

### 3.2 Employee Detail

| Property | Value |
|----------|-------|
| **Endpoint Name** | Employee Detail |
| **HTTP Method** | `GET` |
| **URL** | `/employees/{id}` |
| **Description** | Get single employee by UUID. |
| **Authentication Required** | Yes (`owner`) |

**Request Parameters (Path):**

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | UUID | Employee ID |

**Success Response — `200 OK`:**

```json
{
  "success": true,
  "message": "Employee retrieved successfully",
  "data": {
    "id": "660e8400-e29b-41d4-a716-446655440001",
    "employee_code": "EMP-001",
    "full_name": "Budi Santoso",
    "phone": "+6281234567890",
    "position": "Kasir",
    "status": "active",
    "hired_at": "2024-01-15",
    "user_id": "550e8400-e29b-41d4-a716-446655440000",
    "roles": [{ "code": "cashier", "name": "Kasir" }],
    "created_at": "2024-01-15T08:00:00Z",
    "updated_at": "2026-08-01T10:00:00Z"
  }
}
```

**Error Responses:** `401`, `403`, `404`

---

### 3.3 Create Employee

| Property | Value |
|----------|-------|
| **Endpoint Name** | Create Employee |
| **HTTP Method** | `POST` |
| **URL** | `/employees` |
| **Description** | Create employee record; optionally create linked user account. |
| **Authentication Required** | Yes (`owner`) |

**Request Body:**

```json
{
  "employee_code": "EMP-013",
  "full_name": "Siti Aminah",
  "phone": "+6289876543210",
  "position": "Binatu",
  "status": "active",
  "hired_at": "2026-08-08",
  "create_user": true,
  "role_codes": ["laundry"],
  "password": "TempPass123!"
}
```

**Success Response — `201 Created`:**

```json
{
  "success": true,
  "message": "Employee created successfully",
  "data": {
    "id": "770e8400-e29b-41d4-a716-446655440003",
    "employee_code": "EMP-013",
    "full_name": "Siti Aminah",
    "phone": "+6289876543210",
    "position": "Binatu",
    "status": "active",
    "user_id": "880e8400-e29b-41d4-a716-446655440004"
  }
}
```

**Validation Rules:**

- `employee_code` unique (EMP-001)
- `full_name`, `phone`, `position` required (EMP-002)
- `status` must be `active`, `inactive`, or `resigned`
- If `create_user = true`, `password` and at least one `role_code` required

**Error Responses:** `401`, `403`, `422`

---

### 3.4 Update Employee

| Property | Value |
|----------|-------|
| **Endpoint Name** | Update Employee |
| **HTTP Method** | `PATCH` |
| **URL** | `/employees/{id}` |
| **Description** | Update employee fields. Deactivating employee may suspend linked user. |
| **Authentication Required** | Yes (`owner`) |

**Request Body (partial):**

```json
{
  "full_name": "Siti Aminah Updated",
  "position": "Binatu Senior",
  "status": "inactive"
}
```

**Success Response — `200 OK`:** Updated employee object.

**Validation Rules:** Same as create for provided fields.

**Error Responses:** `401`, `403`, `404`, `422`

---

### 3.5 Delete Employee

| Property | Value |
|----------|-------|
| **Endpoint Name** | Delete Employee |
| **HTTP Method** | `DELETE` |
| **URL** | `/employees/{id}` |
| **Description** | Soft-delete employee (`deleted_at` set). Historical records retained. |
| **Authentication Required** | Yes (`owner`) |

**Success Response — `200 OK`:**

```json
{
  "success": true,
  "message": "Employee deleted successfully",
  "data": null
}
```

**Error Responses:** `401`, `403`, `404`

**Validation Rules:**

- Cannot delete employee with active assigned jobs (ironing, pickup/delivery)

---

## 4. Customers

> **Authorization:** `owner`, `cashier`, `cashier_laundry`, `cashier_laundry_driver`

### 4.1 Customer List

| Property | Value |
|----------|-------|
| **Endpoint Name** | Customer List |
| **HTTP Method** | `GET` |
| **URL** | `/customers` |
| **Description** | Paginated list of customers. |
| **Authentication Required** | Yes |

**Request Parameters (Query):**

| Parameter | Type | Description |
|-----------|------|-------------|
| `page`, `per_page` | integer | Pagination |
| `status` | string | `active`, `inactive` |
| `search` | string | Search `full_name`, `phone`, `customer_code` |

**Success Response — `200 OK`:**

```json
{
  "success": true,
  "message": "Customers retrieved successfully",
  "data": [
    {
      "id": "990e8400-e29b-41d4-a716-446655440005",
      "customer_code": "CUS-0042",
      "full_name": "Andi Wijaya",
      "phone": "+6281122334455",
      "email": null,
      "status": "active",
      "loyalty_points": 120,
      "wallet_balance": 250000.00,
      "created_at": "2025-06-10T09:00:00Z"
    }
  ],
  "meta": { "page": 1, "per_page": 20, "total": 85, "total_pages": 5 }
}
```

---

### 4.2 Customer Detail

| Property | Value |
|----------|-------|
| **Endpoint Name** | Customer Detail |
| **HTTP Method** | `GET` |
| **URL** | `/customers/{id}` |
| **Description** | Full customer profile including addresses and wallet summary. |
| **Authentication Required** | Yes |

**Success Response — `200 OK`:**

```json
{
  "success": true,
  "message": "Customer retrieved successfully",
  "data": {
    "id": "990e8400-e29b-41d4-a716-446655440005",
    "customer_code": "CUS-0042",
    "full_name": "Andi Wijaya",
    "phone": "+6281122334455",
    "email": null,
    "address": "Jl. Merdeka No. 10",
    "status": "active",
    "loyalty_points": 120,
    "notes": "Pelanggan rutin setiap minggu",
    "addresses": [
      {
        "id": "aa0e8400-e29b-41d4-a716-446655440006",
        "label": "Rumah",
        "address_line": "Jl. Merdeka No. 10",
        "maps_query": "Jl. Merdeka No. 10, Jakarta",
        "is_default": true
      }
    ],
    "wallet": {
      "id": "bb0e8400-e29b-41d4-a716-446655440007",
      "balance": 250000.00,
      "currency": "IDR",
      "is_active": true
    },
    "created_at": "2025-06-10T09:00:00Z"
  }
}
```

**Error Responses:** `401`, `403`, `404`

---

### 4.3 Create Customer

| Property | Value |
|----------|-------|
| **Endpoint Name** | Create Customer |
| **HTTP Method** | `POST` |
| **URL** | `/customers` |
| **Description** | Register a new customer. Auto-generates `customer_code` and wallet. |
| **Authentication Required** | Yes |

**Request Body:**

```json
{
  "full_name": "Andi Wijaya",
  "phone": "081122334455",
  "email": null,
  "address": "Jl. Merdeka No. 10",
  "notes": "Pelanggan baru"
}
```

**Success Response — `201 Created`:** Customer object.

**Validation Rules:**

- `full_name` required (CUS-001)
- `phone` required, unique, valid Indonesian format (CUS-001, CUS-004, CUS-005)
- `email` optional, unique if provided

**Error Responses:** `401`, `403`, `422` (duplicate phone)

---

### 4.4 Update Customer

| Property | Value |
|----------|-------|
| **Endpoint Name** | Update Customer |
| **HTTP Method** | `PATCH` |
| **URL** | `/customers/{id}` |
| **Description** | Update customer profile fields. |
| **Authentication Required** | Yes |

**Request Body (partial):**

```json
{
  "full_name": "Andi Wijaya Updated",
  "email": "andi@email.com",
  "status": "active",
  "notes": "Updated notes"
}
```

**Success Response — `200 OK`:** Updated customer object.

**Error Responses:** `401`, `403`, `404`, `422`

---

### 4.5 Delete Customer

| Property | Value |
|----------|-------|
| **Endpoint Name** | Delete Customer |
| **HTTP Method** | `DELETE` |
| **URL** | `/customers/{id}` |
| **Description** | Soft-delete customer (`deleted_at`). |
| **Authentication Required** | Yes (`owner`, `cashier`, `cashier_laundry`, `cashier_laundry_driver`) |

**Success Response — `200 OK`:**

```json
{
  "success": true,
  "message": "Customer deleted successfully",
  "data": null
}
```

**Validation Rules:**

- Cannot delete customer with open (non-completed, non-cancelled) orders

---

### 4.6 Customer Search

| Property | Value |
|----------|-------|
| **Endpoint Name** | Customer Search |
| **HTTP Method** | `GET` |
| **URL** | `/customers/search` |
| **Description** | Fast lookup by phone or name for order creation. |
| **Authentication Required** | Yes |

**Request Parameters (Query):**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `q` | string | Yes | Phone, name, or customer code (min 3 chars) |
| `limit` | integer | No | Max results (default: `10`) |

**Success Response — `200 OK`:**

```json
{
  "success": true,
  "message": "Search results retrieved successfully",
  "data": [
    {
      "id": "990e8400-e29b-41d4-a716-446655440005",
      "customer_code": "CUS-0042",
      "full_name": "Andi Wijaya",
      "phone": "+6281122334455",
      "wallet_balance": 250000.00
    }
  ]
}
```

**Validation Rules:** `q` minimum 3 characters

---

## 5. Laundry Services

> **Authorization:** Read — all cashier roles + `owner`. Write — `owner` only.

### 5.1 Service Categories

#### List Categories

| Property | Value |
|----------|-------|
| **HTTP Method** | `GET` |
| **URL** | `/service-categories` |
| **Authentication Required** | Yes |

**Query:** `is_active` (boolean), `page`, `per_page`

**Success Response — `200 OK`:**

```json
{
  "success": true,
  "message": "Service categories retrieved successfully",
  "data": [
    {
      "id": "cc0e8400-e29b-41d4-a716-446655440008",
      "code": "REGULAR",
      "name": "Regular",
      "description": "Layanan cuci regular",
      "sort_order": 1,
      "is_active": true
    }
  ]
}
```

#### Create Category — `POST /service-categories` (`owner`)

**Request Body:**

```json
{
  "code": "EXPRESS",
  "name": "Express",
  "description": "Layanan express 24 jam",
  "sort_order": 2,
  "is_active": true
}
```

**Success Response — `201 Created`**

**Validation Rules:** `code` unique, `name` required

#### Update Category — `PATCH /service-categories/{id}` (`owner`)

#### Delete Category — `DELETE /service-categories/{id}` (`owner`)

Soft-deactivate (`is_active = false`) if services exist.

---

### 5.2 Services

#### List Services

| Property | Value |
|----------|-------|
| **HTTP Method** | `GET` |
| **URL** | `/services` |
| **Authentication Required** | Yes |

**Query:** `category_id`, `is_active`, `requires_ironing`, `search`

**Success Response — `200 OK`:**

```json
{
  "success": true,
  "message": "Services retrieved successfully",
  "data": [
    {
      "id": "dd0e8400-e29b-41d4-a716-446655440009",
      "category_id": "cc0e8400-e29b-41d4-a716-446655440008",
      "code": "CUCI-SETRIKA",
      "name": "Cuci + Setrika",
      "unit": "kg",
      "price_per_unit": 8000.00,
      "requires_ironing": true,
      "estimated_hours": 48,
      "is_active": true
    }
  ]
}
```

#### Service Detail — `GET /services/{id}`

#### Create Service — `POST /services` (`owner`)

**Request Body:**

```json
{
  "category_id": "cc0e8400-e29b-41d4-a716-446655440008",
  "code": "CUCI-SETRIKA",
  "name": "Cuci + Setrika",
  "unit": "kg",
  "price_per_unit": 8000.00,
  "requires_ironing": true,
  "estimated_hours": 48,
  "is_active": true
}
```

**Validation Rules:**

- `unit` must be `kg`, `pcs`, or `item`
- `price_per_unit` > 0
- `code` unique

#### Update Service — `PATCH /services/{id}` (`owner`)

#### Delete Service — `DELETE /services/{id}` (`owner`)

---

### 5.3 Service Price

| Property | Value |
|----------|-------|
| **Endpoint Name** | Get Service Price |
| **HTTP Method** | `GET` |
| **URL** | `/services/{id}/price` |
| **Description** | Return current price snapshot for order creation. |
| **Authentication Required** | Yes |

**Success Response — `200 OK`:**

```json
{
  "success": true,
  "message": "Service price retrieved successfully",
  "data": {
    "service_id": "dd0e8400-e29b-41d4-a716-446655440009",
    "code": "CUCI-SETRIKA",
    "name": "Cuci + Setrika",
    "unit": "kg",
    "price_per_unit": 8000.00,
    "effective_at": "2026-08-08T00:00:00Z"
  }
}
```

| Property | Value |
|----------|-------|
| **Endpoint Name** | Update Service Price |
| **HTTP Method** | `PATCH` |
| **URL** | `/services/{id}/price` |
| **Authentication Required** | Yes (`owner`) |

**Request Body:**

```json
{
  "price_per_unit": 8500.00
}
```

**Validation Rules:** `price_per_unit` must be > 0. Does not affect existing orders (ORD-007).

---

## 6. Orders

> **Authorization:** Create/read/update — `owner`, `cashier`, `cashier_laundry`, `cashier_laundry_driver`. Cancel — same roles.

### 6.1 Create Order

| Property | Value |
|----------|-------|
| **Endpoint Name** | Create Order |
| **HTTP Method** | `POST` |
| **URL** | `/orders` |
| **Description** | Create order with line items. Auto-generates `order_number` and queue number. |
| **Authentication Required** | Yes |

**Request Body:**

```json
{
  "customer_id": "990e8400-e29b-41d4-a716-446655440005",
  "customer_notes": "Jangan pakai pewangi",
  "internal_notes": null,
  "estimated_completion": "2026-08-10T17:00:00Z",
  "discount_amount": 0,
  "items": [
    {
      "service_id": "dd0e8400-e29b-41d4-a716-446655440009",
      "quantity": 3.5,
      "quantity_pcs": null,
      "notes": null
    }
  ],
  "fulfillment": {
    "type": "self_pickup",
    "pickup_request": null,
    "delivery_request": null
  }
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `customer_id` | UUID | Yes | Active customer |
| `items` | array | Yes | Min 1 item |
| `items[].service_id` | UUID | Yes | Active service |
| `items[].quantity` | decimal | Yes | Weight or unit count |
| `discount_amount` | decimal | No | Default `0` |
| `fulfillment.type` | string | Yes | `self_pickup`, `pickup`, `delivery` |

**Success Response — `201 Created`:**

```json
{
  "success": true,
  "message": "Order created successfully",
  "data": {
    "id": "ee0e8400-e29b-41d4-a716-446655440010",
    "order_number": "YL-000043",
    "queue_number": "A-4289",
    "customer_id": "990e8400-e29b-41d4-a716-446655440005",
    "status": "new",
    "payment_status": "unpaid",
    "subtotal": 28000.00,
    "discount_amount": 0,
    "total_amount": 28000.00,
    "estimated_completion": "2026-08-10T17:00:00Z",
    "items": [
      {
        "id": "ff0e8400-e29b-41d4-a716-446655440011",
        "service_id": "dd0e8400-e29b-41d4-a716-446655440009",
        "service_name": "Cuci + Setrika",
        "quantity": 3.5,
        "unit_price": 8000.00,
        "line_total": 28000.00
      }
    ],
    "created_by": "660e8400-e29b-41d4-a716-446655440001",
    "order_date": "2026-08-08T03:30:00Z"
  }
}
```

**Validation Rules:**

- Customer must be `active` (ORD-001, CUS-007)
- At least one item (ORD-003)
- `total_amount = subtotal - discount_amount` (ORD-005, ORD-006)
- Triggers `new_order` notification (NOT-001)

**Error Responses:** `401`, `403`, `422`

---

### 6.2 Update Order

| Property | Value |
|----------|-------|
| **Endpoint Name** | Update Order |
| **HTTP Method** | `PATCH` |
| **URL** | `/orders/{id}` |
| **Description** | Update order notes, status, or estimated completion. Status changes logged in `order_status_logs`. |
| **Authentication Required** | Yes |

**Request Body:**

```json
{
  "status": "washing",
  "customer_notes": "Updated note",
  "internal_notes": "Prioritas",
  "estimated_completion": "2026-08-10T15:00:00Z",
  "notes": "Mulai cuci"
}
```

**Success Response — `200 OK`:** Updated order object.

**Validation Rules:**

- Status must be valid enum (ORD-011)
- Cannot set `completed` if `payment_status = unpaid` without owner override (ORD-013)
- Cannot update `cancelled` or `completed` orders (except notes by owner)

---

### 6.3 Order Detail

| Property | Value |
|----------|-------|
| **HTTP Method** | `GET` |
| **URL** | `/orders/{id}` |
| **Authentication Required** | Yes |

**Success Response — `200 OK`:**

```json
{
  "success": true,
  "message": "Order retrieved successfully",
  "data": {
    "id": "ee0e8400-e29b-41d4-a716-446655440010",
    "order_number": "YL-000043",
    "queue_number": "A-4289",
    "customer": {
      "id": "990e8400-e29b-41d4-a716-446655440005",
      "full_name": "Andi Wijaya",
      "phone": "+6281122334455"
    },
    "status": "ironing",
    "payment_status": "paid",
    "subtotal": 28000.00,
    "discount_amount": 0,
    "total_amount": 28000.00,
    "items": [],
    "ironing_jobs": [],
    "status_history": [
      {
        "from_status": "drying",
        "to_status": "ironing",
        "changed_by": "660e8400-e29b-41d4-a716-446655440001",
        "changed_at": "2026-08-09T10:00:00Z"
      }
    ],
    "payments_summary": { "total_paid": 28000.00, "remaining": 0 },
    "created_at": "2026-08-08T03:30:00Z"
  }
}
```

---

### 6.4 Order List

| Property | Value |
|----------|-------|
| **HTTP Method** | `GET` |
| **URL** | `/orders` |
| **Authentication Required** | Yes |

**Query Parameters:**

| Parameter | Description |
|-----------|-------------|
| `status` | Filter by order status |
| `payment_status` | `unpaid`, `partial`, `paid` |
| `customer_id` | Filter by customer |
| `date_from`, `date_to` | Filter by `order_date` |
| `search` | Order number, queue number, customer name |

**Success Response — `200 OK`:** Paginated order list (summary fields).

---

### 6.5 Cancel Order

| Property | Value |
|----------|-------|
| **HTTP Method** | `POST` |
| **URL** | `/orders/{id}/cancel` |
| **Authentication Required** | Yes |

**Request Body:**

```json
{
  "reason": "Customer request cancellation"
}
```

**Success Response — `200 OK`:**

```json
{
  "success": true,
  "message": "Order cancelled successfully",
  "data": {
    "id": "ee0e8400-e29b-41d4-a716-446655440010",
    "status": "cancelled"
  }
}
```

**Validation Rules:**

- Cannot cancel `completed` orders (ORD-016)
- `reason` required (min 5 chars)
- Existing payments trigger refund workflow (PAY-011)

**Error Responses:** `401`, `403`, `404`, `422`

---

### 6.6 Order History

| Property | Value |
|----------|-------|
| **HTTP Method** | `GET` |
| **URL** | `/customers/{customer_id}/orders` |
| **Description** | Paginated order history for a customer. |
| **Authentication Required** | Yes |

**Query:** `page`, `per_page`, `status`, `date_from`, `date_to`

**Success Response — `200 OK`:** Paginated order summaries.

**Alternative:** `GET /orders?customer_id={id}` (same result).

---

## 7. Payments

> **Authorization:** `owner`, `cashier`, `cashier_laundry`, `cashier_laundry_driver`

### 7.1 Cash Payment

| Property | Value |
|----------|-------|
| **Endpoint Name** | Record Cash Payment |
| **HTTP Method** | `POST` |
| **URL** | `/orders/{order_id}/payments/cash` |
| **Description** | Record immediate cash payment for an order. |
| **Authentication Required** | Yes |

**Request Body:**

```json
{
  "amount": 28000.00,
  "notes": "Bayar tunai"
}
```

**Success Response — `201 Created`:**

```json
{
  "success": true,
  "message": "Cash payment recorded successfully",
  "data": {
    "id": "110e8400-e29b-41d4-a716-446655440012",
    "order_id": "ee0e8400-e29b-41d4-a716-446655440010",
    "payment_method": "cash",
    "amount": 28000.00,
    "status": "completed",
    "paid_at": "2026-08-08T03:35:00Z",
    "processed_by": "660e8400-e29b-41d4-a716-446655440001",
    "order_payment_status": "paid"
  }
}
```

**Validation Rules:**

- `amount` > 0 (PAY-002)
- Sum of completed payments must not exceed `total_amount` (PAY-006)
- Order must not be `cancelled`
- Triggers `cash_payment` notification

**Error Responses:** `401`, `403`, `404`, `422`

---

### 7.2 QRIS Payment

| Property | Value |
|----------|-------|
| **Endpoint Name** | Record QRIS Payment |
| **HTTP Method** | `POST` |
| **URL** | `/orders/{order_id}/payments/qris` |
| **Description** | Initiate or confirm QRIS payment. May start as `pending`. |
| **Authentication Required** | Yes |

**Request Body:**

```json
{
  "amount": 28000.00,
  "reference_number": "QRIS-20260808-001",
  "confirm": true
}
```

| Field | Description |
|-------|-------------|
| `confirm` | `false` → creates `pending`; `true` → marks `completed` |

**Success Response — `201 Created` / `200 OK`:**

```json
{
  "success": true,
  "message": "QRIS payment recorded successfully",
  "data": {
    "id": "120e8400-e29b-41d4-a716-446655440013",
    "payment_method": "qris",
    "amount": 28000.00,
    "status": "completed",
    "reference_number": "QRIS-20260808-001",
    "paid_at": "2026-08-08T03:36:00Z"
  }
}
```

**Validation Rules:** Same as cash. Triggers `qris_payment` on completion.

---

### 7.3 Transfer Payment

| Property | Value |
|----------|-------|
| **Endpoint Name** | Record Transfer Payment |
| **HTTP Method** | `POST` |
| **URL** | `/orders/{order_id}/payments/transfer` |
| **Description** | Record bank transfer; supports pending → completed flow. |
| **Authentication Required** | Yes |

**Request Body:**

```json
{
  "amount": 28000.00,
  "reference_number": "TRF-BCA-123456",
  "confirm": false
}
```

**Success Response — `201 Created`:**

```json
{
  "success": true,
  "message": "Transfer payment recorded successfully",
  "data": {
    "id": "130e8400-e29b-41d4-a716-446655440014",
    "payment_method": "transfer",
    "amount": 28000.00,
    "status": "pending",
    "reference_number": "TRF-BCA-123456"
  }
}
```

**Confirm pending transfer:** `PATCH /payments/{id}` with `{ "status": "completed" }`

**Validation Rules:** Triggers `transfer_payment` on completion.

---

### 7.4 Payment Detail

| Property | Value |
|----------|-------|
| **HTTP Method** | `GET` |
| **URL** | `/payments/{id}` |
| **Authentication Required** | Yes |

**Success Response — `200 OK`:**

```json
{
  "success": true,
  "message": "Payment retrieved successfully",
  "data": {
    "id": "110e8400-e29b-41d4-a716-446655440012",
    "order_id": "ee0e8400-e29b-41d4-a716-446655440010",
    "order_number": "YL-000043",
    "payment_method": "cash",
    "amount": 28000.00,
    "status": "completed",
    "reference_number": null,
    "paid_at": "2026-08-08T03:35:00Z",
    "processed_by": {
      "id": "660e8400-e29b-41d4-a716-446655440001",
      "full_name": "Budi Santoso"
    }
  }
}
```

---

### 7.5 Payment History

| Property | Value |
|----------|-------|
| **HTTP Method** | `GET` |
| **URL** | `/payments` |
| **Authentication Required** | Yes |

**Query:** `order_id`, `payment_method`, `status`, `date_from`, `date_to`, `page`, `per_page`

**Success Response — `200 OK`:** Paginated payment list.

**Alternative:** `GET /orders/{order_id}/payments`

---

## 8. Wallet

> **Authorization:** `owner`, `cashier`, `cashier_laundry`, `cashier_laundry_driver`

### 8.1 Top Up

| Property | Value |
|----------|-------|
| **HTTP Method** | `POST` |
| **URL** | `/customers/{customer_id}/wallet/top-up` |
| **Description** | Credit customer wallet after payment confirmation. |
| **Authentication Required** | Yes |

**Request Body:**

```json
{
  "amount": 500000.00,
  "payment_method": "cash",
  "reference_number": "TOPUP-001",
  "notes": "Top up saldo"
}
```

**Success Response — `201 Created`:**

```json
{
  "success": true,
  "message": "Wallet top-up successful",
  "data": {
    "transaction": {
      "id": "140e8400-e29b-41d4-a716-446655440015",
      "transaction_type": "top_up",
      "amount": 500000.00,
      "balance_before": 250000.00,
      "balance_after": 750000.00,
      "reference_number": "TOPUP-001",
      "transaction_at": "2026-08-08T04:00:00Z"
    },
    "wallet": {
      "balance": 750000.00,
      "currency": "IDR"
    }
  }
}
```

**Validation Rules:**

- `amount` > 0 (WAL-007)
- `payment_method` must be `cash`, `qris`, or `transfer`
- Atomic balance update (WAL-009)
- Triggers `wallet_top_up` notification

---

### 8.2 Deduction

| Property | Value |
|----------|-------|
| **HTTP Method** | `POST` |
| **URL** | `/customers/{customer_id}/wallet/deduction` |
| **Description** | Deduct wallet balance for order payment. |
| **Authentication Required** | Yes |

**Request Body:**

```json
{
  "order_id": "ee0e8400-e29b-41d4-a716-446655440010",
  "amount": 28000.00,
  "notes": "Pembayaran order YL-000043"
}
```

**Success Response — `201 Created`:**

```json
{
  "success": true,
  "message": "Wallet deduction successful",
  "data": {
    "transaction": {
      "id": "150e8400-e29b-41d4-a716-446655440016",
      "transaction_type": "deduction",
      "amount": 28000.00,
      "balance_before": 750000.00,
      "balance_after": 722000.00,
      "order_id": "ee0e8400-e29b-41d4-a716-446655440010",
      "payment_id": "160e8400-e29b-41d4-a716-446655440017"
    }
  }
}
```

**Validation Rules:**

- Sufficient balance (WAL-014, PAY-005)
- `order_id` required (WAL-013)
- Creates linked `payments` record with `payment_method = wallet`
- Triggers `wallet_deduction` notification

**Error Responses:** `422` (insufficient balance)

---

### 8.3 Balance

| Property | Value |
|----------|-------|
| **HTTP Method** | `GET` |
| **URL** | `/customers/{customer_id}/wallet/balance` |
| **Authentication Required** | Yes |

**Success Response — `200 OK`:**

```json
{
  "success": true,
  "message": "Wallet balance retrieved successfully",
  "data": {
    "wallet_id": "bb0e8400-e29b-41d4-a716-446655440007",
    "customer_id": "990e8400-e29b-41d4-a716-446655440005",
    "balance": 722000.00,
    "currency": "IDR",
    "is_active": true,
    "updated_at": "2026-08-08T04:05:00Z"
  }
}
```

---

### 8.4 Wallet History

| Property | Value |
|----------|-------|
| **HTTP Method** | `GET` |
| **URL** | `/customers/{customer_id}/wallet/transactions` |
| **Authentication Required** | Yes |

**Query:** `transaction_type` (`top_up`, `deduction`, `refund`), `date_from`, `date_to`, `page`, `per_page`

**Success Response — `200 OK`:**

```json
{
  "success": true,
  "message": "Wallet transactions retrieved successfully",
  "data": [
    {
      "id": "150e8400-e29b-41d4-a716-446655440016",
      "transaction_type": "deduction",
      "amount": 28000.00,
      "balance_before": 750000.00,
      "balance_after": 722000.00,
      "reference_number": "WLT-DED-000016",
      "order_id": "ee0e8400-e29b-41d4-a716-446655440010",
      "transaction_at": "2026-08-08T04:05:00Z"
    }
  ],
  "meta": { "page": 1, "per_page": 20, "total": 5, "total_pages": 1 }
}
```

---

## 9. Attendance

### 9.1 Check In

| Property | Value |
|----------|-------|
| **HTTP Method** | `POST` |
| **URL** | `/attendance/check-in` |
| **Description** | Record employee clock-in for today. |
| **Authentication Required** | Yes (`cashier_laundry`, `cashier_laundry_driver`, `laundry`) |

**Request Body:**

```json
{
  "latitude": -6.2087634,
  "longitude": 106.8455990
}
```

**Success Response — `201 Created`:**

```json
{
  "success": true,
  "message": "Check-in recorded successfully",
  "data": {
    "id": "170e8400-e29b-41d4-a716-446655440018",
    "employee_id": "660e8400-e29b-41d4-a716-446655440001",
    "work_date": "2026-08-08",
    "clock_in": "2026-08-08T01:00:00Z",
    "status": "present"
  }
}
```

**Validation Rules:**

- One check-in per day (ATT-002, ATT-004)
- Reject if leave day (ATT-005)
- Set `late` if after threshold (ATT-006)
- Kasir (`cashier`) **forbidden** (AUTH-011) → `403`

---

### 9.2 Check Out

| Property | Value |
|----------|-------|
| **HTTP Method** | `POST` |
| **URL** | `/attendance/check-out` |
| **Authentication Required** | Yes (`cashier_laundry`, `cashier_laundry_driver`, `laundry`) |

**Request Body:**

```json
{
  "latitude": -6.2087634,
  "longitude": 106.8455990
}
```

**Success Response — `200 OK`:**

```json
{
  "success": true,
  "message": "Check-out recorded successfully",
  "data": {
    "id": "170e8400-e29b-41d4-a716-446655440018",
    "clock_out": "2026-08-08T10:00:00Z",
    "working_hours": "8 Jam 00 Menit",
    "status": "present"
  }
}
```

**Validation Rules:**

- Requires prior check-in (ATT-007)
- No double check-out (ATT-009)

---

### 9.3 Attendance History

| Property | Value |
|----------|-------|
| **HTTP Method** | `GET` |
| **URL** | `/attendance/history` |
| **Authentication Required** | Yes |

**Query:**

| Parameter | Description |
|-----------|-------------|
| `employee_id` | Required for `owner`; defaults to self for others |
| `date_from`, `date_to` | Date range |
| `status` | `present`, `late`, `absent`, `half_day` |

**Success Response — `200 OK`:**

```json
{
  "success": true,
  "message": "Attendance history retrieved successfully",
  "data": [
    {
      "id": "170e8400-e29b-41d4-a716-446655440018",
      "work_date": "2026-08-08",
      "clock_in": "2026-08-08T01:00:00Z",
      "clock_out": "2026-08-08T10:00:00Z",
      "status": "present",
      "working_hours": "8 Jam 00 Menit"
    }
  ]
}
```

**Authorization:**

- `owner` → any employee
- Others → own records only

---

### 9.4 Attendance Summary

| Property | Value |
|----------|-------|
| **HTTP Method** | `GET` |
| **URL** | `/attendance/summary` |
| **Authentication Required** | Yes |

**Query:** `date` (default: today), `employee_id` (owner only)

**Success Response — `200 OK`:**

```json
{
  "success": true,
  "message": "Attendance summary retrieved successfully",
  "data": {
    "date": "2026-08-08",
    "present_today": 8,
    "late_today": 2,
    "leave_today": 1,
    "not_checked_in": 1,
    "employees": [
      {
        "employee_id": "660e8400-e29b-41d4-a716-446655440001",
        "full_name": "Budi Santoso",
        "status": "present",
        "clock_in": "07:55 WIB",
        "clock_out": null
      }
    ]
  }
}
```

**Authorization:** `owner` gets team summary; others get personal today summary only.

---

## 10. Binatu

> **Authorization:** Queue read — `owner`, `cashier_laundry`, `cashier_laundry_driver`, `laundry`. Job actions — `laundry` (Binatu accept), `cashier_laundry` / `cashier_laundry_driver` (operator assistance accept).

### 10.1 Ironing Queue

| Property | Value |
|----------|-------|
| **Endpoint Name** | Ironing Queue |
| **HTTP Method** | `GET` |
| **URL** | `/ironing-jobs/queue` |
| **Description** | List ironing jobs filtered by queue view. |
| **Authentication Required** | Yes |

**Query Parameters:**

| Parameter | Values | Description |
|-----------|--------|-------------|
| `filter` | `ironing_queue`, `currently_ironing`, `finished_ironing`, `ready_for_pickup` | Queue view (BIN-027) |
| `assigned_to` | UUID | Filter by assigned employee |
| `page`, `per_page` | integer | Pagination |

**Success Response — `200 OK`:**

```json
{
  "success": true,
  "message": "Ironing queue retrieved successfully",
  "data": [
    {
      "id": "180e8400-e29b-41d4-a716-446655440019",
      "order_id": "ee0e8400-e29b-41d4-a716-446655440010",
      "order_number": "YL-000043",
      "queue_number": "A-4289",
      "customer_name": "Andi Wijaya",
      "service_name": "Cuci + Setrika",
      "weight_kg": 3.5,
      "status": "waiting_for_binatu",
      "waiting_started_at": "2026-08-09T08:00:00Z",
      "priority_remaining_seconds": 180,
      "deadline": "2026-08-10T17:00:00Z",
      "assigned_employee_id": null,
      "is_operator_assistance": false
    }
  ],
  "meta": { "page": 1, "per_page": 20, "total": 5, "total_pages": 1 }
}
```

---

### 10.2 Accept Job

| Property | Value |
|----------|-------|
| **HTTP Method** | `POST` |
| **URL** | `/ironing-jobs/{id}/accept` |
| **Description** | Binatu accepts job in `waiting_for_binatu`, or Operator accepts in `waiting_for_operator_assistance`. |
| **Authentication Required** | Yes |

**Request Body:**

```json
{
  "accept_as": "binatu"
}
```

| `accept_as` | Required Role | From Status |
|-------------|---------------|-------------|
| `binatu` | `laundry`, `cashier_laundry`, `cashier_laundry_driver` | `waiting_for_binatu` |
| `operator` | `cashier_laundry`, `cashier_laundry_driver` | `waiting_for_operator_assistance` |

**Success Response — `200 OK`:**

```json
{
  "success": true,
  "message": "Ironing job accepted successfully",
  "data": {
    "id": "180e8400-e29b-41d4-a716-446655440019",
    "status": "accepted_by_binatu",
    "assigned_employee_id": "660e8400-e29b-41d4-a716-446655440001",
    "accepted_at": "2026-08-09T08:03:00Z",
    "is_operator_assistance": false
  }
}
```

**Validation Rules:**

- BIN-011 through BIN-018
- Triggers `binatu_accepted` notification
- Resolves operator assistance notification

**Error Responses:** `403` (wrong role/status), `404`, `422`

---

### 10.3 Start Ironing

| Property | Value |
|----------|-------|
| **HTTP Method** | `POST` |
| **URL** | `/ironing-jobs/{id}/start` |
| **Authentication Required** | Yes (`laundry`, `cashier_laundry`, `cashier_laundry_driver`) |

**Request Body:** `{}` (empty)

**Success Response — `200 OK`:**

```json
{
  "success": true,
  "message": "Ironing started successfully",
  "data": {
    "id": "180e8400-e29b-41d4-a716-446655440019",
    "status": "currently_ironing",
    "started_at": "2026-08-09T08:05:00Z"
  }
}
```

**Validation Rules:** Status must be `accepted_by_binatu` (BIN-019)

---

### 10.4 Finish Ironing

| Property | Value |
|----------|-------|
| **HTTP Method** | `POST` |
| **URL** | `/ironing-jobs/{id}/finish` |
| **Authentication Required** | Yes |

**Success Response — `200 OK`:**

```json
{
  "success": true,
  "message": "Ironing finished successfully",
  "data": {
    "id": "180e8400-e29b-41d4-a716-446655440019",
    "status": "finished_ironing",
    "finished_at": "2026-08-09T09:30:00Z"
  }
}
```

**Validation Rules:** Status must be `currently_ironing` (BIN-020). Triggers `ironing_finished`.

---

### 10.5 Ready for Pickup

| Property | Value |
|----------|-------|
| **HTTP Method** | `POST` |
| **URL** | `/ironing-jobs/{id}/ready-for-pickup` |
| **Authentication Required** | Yes |

**Success Response — `200 OK`:**

```json
{
  "success": true,
  "message": "Job marked ready for pickup",
  "data": {
    "id": "180e8400-e29b-41d4-a716-446655440019",
    "status": "ready_for_pickup",
    "ready_at": "2026-08-09T09:35:00Z"
  }
}
```

**Validation Rules:** Status must be `finished_ironing` (BIN-023). Triggers `ready_for_pickup`.

---

## 11. Pickup & Delivery

> **Authorization:** List — cashier roles + `owner`. Accept/complete — `cashier_laundry_driver` (Driver) + `owner`.

### 11.1 Pickup List

| Property | Value |
|----------|-------|
| **HTTP Method** | `GET` |
| **URL** | `/pickups` |
| **Authentication Required** | Yes |

**Query:** `status`, `scheduled_date`, `assigned_employee_id`, `page`, `per_page`

**Success Response — `200 OK`:**

```json
{
  "success": true,
  "message": "Pickup requests retrieved successfully",
  "data": [
    {
      "id": "190e8400-e29b-41d4-a716-446655440020",
      "order_id": "ee0e8400-e29b-41d4-a716-446655440010",
      "order_number": "YL-000043",
      "request_type": "pickup",
      "status": "scheduled",
      "customer_name": "Andi Wijaya",
      "customer_phone": "+6281122334455",
      "address": "Jl. Merdeka No. 10",
      "scheduled_date": "2026-08-08",
      "pickup_time": "10:00:00",
      "assigned_employee_id": null
    }
  ]
}
```

---

### 11.2 Accept Pickup

| Property | Value |
|----------|-------|
| **HTTP Method** | `POST` |
| **URL** | `/pickups/{id}/accept` |
| **Authentication Required** | Yes (`cashier_laundry_driver`, `owner`) |

**Request Body:**

```json
{
  "assigned_employee_id": "660e8400-e29b-41d4-a716-446655440001"
}
```

**Success Response — `200 OK`:**

```json
{
  "success": true,
  "message": "Pickup accepted successfully",
  "data": {
    "id": "190e8400-e29b-41d4-a716-446655440020",
    "status": "in_progress",
    "assigned_employee_id": "660e8400-e29b-41d4-a716-446655440001"
  }
}
```

**Validation Rules:** Status must be `scheduled` (PICK-005)

---

### 11.3 Complete Pickup

| Property | Value |
|----------|-------|
| **HTTP Method** | `POST` |
| **URL** | `/pickups/{id}/complete` |
| **Authentication Required** | Yes (`cashier_laundry_driver`, `owner`) |

**Request Body:**

```json
{
  "notes": "Barang sudah diterima di outlet"
}
```

**Success Response — `200 OK`:**

```json
{
  "success": true,
  "message": "Pickup completed successfully",
  "data": {
    "id": "190e8400-e29b-41d4-a716-446655440020",
    "status": "completed",
    "completed_at": "2026-08-08T03:30:00Z",
    "order_status": "washing"
  }
}
```

**Validation Rules:** Status must be `in_progress` (PICK-006). Triggers `pickup_request` notification.

---

### 11.4 Delivery List

| Property | Value |
|----------|-------|
| **HTTP Method** | `GET` |
| **URL** | `/deliveries` |
| **Authentication Required** | Yes |

**Query:** Same as pickups (`status`, `scheduled_date`, `assigned_employee_id`)

**Success Response — `200 OK`:** Same structure as pickup list with `request_type: "delivery"`.

---

### 11.5 Complete Delivery

| Property | Value |
|----------|-------|
| **HTTP Method** | `POST` |
| **URL** | `/deliveries/{id}/complete` |
| **Authentication Required** | Yes (`cashier_laundry_driver`, `owner`) |

**Request Body:**

```json
{
  "notes": "Barang sudah diserahkan ke pelanggan"
}
```

**Success Response — `200 OK`:**

```json
{
  "success": true,
  "message": "Delivery completed successfully",
  "data": {
    "id": "1a0e8400-e29b-41d4-a716-446655440021",
    "status": "completed",
    "completed_at": "2026-08-10T18:00:00Z",
    "order_status": "completed"
  }
}
```

**Validation Rules:**

- Status must be `in_progress` (DEL-007)
- Order must be paid unless owner override (DEL-010)
- Triggers `delivery_request` notification

---

## 12. Notifications

> **Authorization:** All authenticated staff roles.

### 12.1 Notification List

| Property | Value |
|----------|-------|
| **HTTP Method** | `GET` |
| **URL** | `/notifications` |
| **Authentication Required** | Yes |

**Query:** `type`, `is_read` (boolean), `page`, `per_page`

**Success Response — `200 OK`:**

```json
{
  "success": true,
  "message": "Notifications retrieved successfully",
  "data": [
    {
      "id": "1b0e8400-e29b-41d4-a716-446655440022",
      "type": "new_order",
      "title": "Order Baru",
      "message": "Order YL-000043 dari Andi Wijaya",
      "order_id": "ee0e8400-e29b-41d4-a716-446655440010",
      "metadata": { "queue_number": "A-4289" },
      "is_read": false,
      "created_at": "2026-08-08T03:30:00Z"
    }
  ],
  "meta": { "page": 1, "per_page": 20, "total": 15, "total_pages": 1 }
}
```

---

### 12.2 Unread Count

| Property | Value |
|----------|-------|
| **HTTP Method** | `GET` |
| **URL** | `/notifications/unread-count` |
| **Authentication Required** | Yes |

**Success Response — `200 OK`:**

```json
{
  "success": true,
  "message": "Unread count retrieved successfully",
  "data": {
    "total": 7,
    "by_type": {
      "new_order": 2,
      "cash_payment": 1,
      "ready_for_pickup": 3,
      "pickup_request": 1
    },
    "by_module": {
      "notification_center": 7,
      "pickup_delivery": 1,
      "customer_service": 3,
      "ironing_queue": 2
    }
  }
}
```

---

### 12.3 Mark as Read

| Property | Value |
|----------|-------|
| **HTTP Method** | `POST` |
| **URL** | `/notifications/{id}/read` |
| **Authentication Required** | Yes |

**Request Body:** `{}`

**Success Response — `200 OK`:**

```json
{
  "success": true,
  "message": "Notification marked as read",
  "data": {
    "id": "1b0e8400-e29b-41d4-a716-446655440022",
    "read_at": "2026-08-08T04:00:00Z"
  }
}
```

Creates `notification_reads` record (NOT-004).

---

### 12.4 Read All

| Property | Value |
|----------|-------|
| **HTTP Method** | `POST` |
| **URL** | `/notifications/read-all` |
| **Authentication Required** | Yes |

**Request Body (optional):**

```json
{
  "type": "new_order"
}
```

**Success Response — `200 OK`:**

```json
{
  "success": true,
  "message": "All notifications marked as read",
  "data": {
    "marked_count": 7
  }
}
```

---

## 13. Customer Service

> **Authorization:** `owner`, `cashier`, `cashier_laundry`, `cashier_laundry_driver`

### 13.1 Conversation List

| Property | Value |
|----------|-------|
| **HTTP Method** | `GET` |
| **URL** | `/customer-service/conversations` |
| **Authentication Required** | Yes |

**Query:** `is_unread`, `ai_category`, `search`, `page`, `per_page`

**Success Response — `200 OK`:**

```json
{
  "success": true,
  "message": "Conversations retrieved successfully",
  "data": [
    {
      "id": "1c0e8400-e29b-41d4-a716-446655440023",
      "customer_id": "990e8400-e29b-41d4-a716-446655440005",
      "customer_name": "Andi Wijaya",
      "whatsapp_number": "+6281122334455",
      "ai_category": "tracking_order",
      "ai_confidence": 92,
      "is_unread": true,
      "last_message_preview": "Kapan laundry saya selesai?",
      "last_message_at": "2026-08-08T02:00:00Z",
      "order_id": "ee0e8400-e29b-41d4-a716-446655440010"
    }
  ]
}
```

---

### 13.2 Conversation Detail

| Property | Value |
|----------|-------|
| **HTTP Method** | `GET` |
| **URL** | `/customer-service/conversations/{id}` |
| **Authentication Required** | Yes |

**Success Response — `200 OK`:**

```json
{
  "success": true,
  "message": "Conversation retrieved successfully",
  "data": {
    "id": "1c0e8400-e29b-41d4-a716-446655440023",
    "customer": {
      "id": "990e8400-e29b-41d4-a716-446655440005",
      "full_name": "Andi Wijaya",
      "phone": "+6281122334455"
    },
    "ai_category": "tracking_order",
    "is_unread": false,
    "related_order": {
      "id": "ee0e8400-e29b-41d4-a716-446655440010",
      "order_number": "YL-000043",
      "queue_number": "A-4289",
      "status": "ironing"
    },
    "messages": [
      {
        "id": "1d0e8400-e29b-41d4-a716-446655440024",
        "is_from_customer": true,
        "content": "Kapan laundry saya selesai?",
        "sent_at": "2026-08-08T02:00:00Z",
        "sent_by": null
      },
      {
        "id": "1e0e8400-e29b-41d4-a716-446655440025",
        "is_from_customer": false,
        "content": "Halo Andi, laundry Anda sedang disetrika. Estimasi selesai 10 Agustus 17.00 WIB.",
        "sent_at": "2026-08-08T02:05:00Z",
        "sent_by": {
          "id": "660e8400-e29b-41d4-a716-446655440001",
          "full_name": "Budi Santoso"
        }
      }
    ]
  }
}
```

**Side effect:** Sets `is_unread = false` (CS-004, NOT-009).

---

### 13.3 Send Message

| Property | Value |
|----------|-------|
| **HTTP Method** | `POST` |
| **URL** | `/customer-service/conversations/{id}/messages` |
| **Authentication Required** | Yes |

**Request Body:**

```json
{
  "content": "Halo Andi, laundry Anda sedang disetrika.",
  "use_order_status_template": false,
  "order_id": null
}
```

| Field | Description |
|-------|-------------|
| `use_order_status_template` | When `true`, auto-generate WhatsApp status message from linked order |
| `order_id` | Required when using template |

**Success Response — `201 Created`:**

```json
{
  "success": true,
  "message": "Message sent successfully",
  "data": {
    "id": "1e0e8400-e29b-41d4-a716-446655440025",
    "content": "Halo Andi, laundry Anda sedang disetrika.",
    "is_from_customer": false,
    "sent_at": "2026-08-08T02:05:00Z"
  }
}
```

**Validation Rules:**

- `content` required unless `use_order_status_template = true` (CS-009, CS-012)
- `content` max 4096 characters

---

### 13.4 Upload Attachment

| Property | Value |
|----------|-------|
| **HTTP Method** | `POST` |
| **URL** | `/customer-service/conversations/{id}/attachments` |
| **Description** | Upload image or document attachment to a conversation (multipart). |
| **Authentication Required** | Yes |

**Request Body (multipart/form-data):**

| Field | Type | Required |
|-------|------|----------|
| `file` | file | Yes |
| `caption` | string | No |

**Success Response — `201 Created`:**

```json
{
  "success": true,
  "message": "Attachment uploaded successfully",
  "data": {
    "message_id": "1f0e8400-e29b-41d4-a716-446655440026",
    "attachment_url": "https://cdn.yelo-laundry.com/cs/attachments/abc123.jpg",
    "file_name": "bukti_transfer.jpg",
    "mime_type": "image/jpeg",
    "file_size": 245760
  }
}
```

**Validation Rules:**

- Max file size: 5 MB
- Allowed types: `image/jpeg`, `image/png`, `application/pdf`

**Error Responses:** `401`, `403`, `404`, `422`

---

## 14. Settings

> **Authorization:** See per-endpoint table in [04_BUSINESS_RULES.md](./04_BUSINESS_RULES.md) Section 16.

### 14.1 Receipt Settings

| Property | Value |
|----------|-------|
| **HTTP Method** | `GET` |
| **URL** | `/settings/receipt` |
| **Authentication Required** | Yes |

**Success Response — `200 OK`:**

```json
{
  "success": true,
  "message": "Receipt settings retrieved successfully",
  "data": {
    "header_text": "Yelo Laundry - Bersih & Wangi",
    "footer_text": "Terima kasih atas kepercayaan Anda.",
    "show_logo": true,
    "show_qr_code": false,
    "printer_name": "EPSON-TM-T82"
  }
}
```

| Property | Value |
|----------|-------|
| **HTTP Method** | `PATCH` |
| **URL** | `/settings/receipt` |
| **Authentication Required** | Yes (`owner` for template; cashier roles for `printer_name` only) |

**Request Body:**

```json
{
  "header_text": "Updated header",
  "footer_text": "Updated footer",
  "show_logo": true,
  "show_qr_code": true,
  "printer_name": "EPSON-TM-T82"
}
```

---

### 14.2 Company Profile

| Property | Value |
|----------|-------|
| **HTTP Method** | `GET` |
| **URL** | `/settings/company-profile` |
| **Authentication Required** | Yes |

**Success Response — `200 OK`:**

```json
{
  "success": true,
  "message": "Company profile retrieved successfully",
  "data": {
    "id": "200e8400-e29b-41d4-a716-446655440027",
    "business_name": "Yelo Laundry",
    "address": "Jl. Sudirman No. 1, Jakarta",
    "phone": "+622112345678",
    "email": "info@yelo-laundry.com",
    "logo_url": "https://cdn.yelo-laundry.com/logo.png",
    "timezone": "Asia/Jakarta",
    "currency": "IDR",
    "is_active": true
  }
}
```

| Property | Value |
|----------|-------|
| **HTTP Method** | `PATCH` |
| **URL** | `/settings/company-profile` |
| **Authentication Required** | Yes (`owner`) |

**Request Body (partial):** `business_name`, `address`, `phone`, `email`, `logo_url`

**Validation Rules:** `business_name` required (SET-001)

---

### 14.3 Queue Settings

| Property | Value |
|----------|-------|
| **HTTP Method** | `GET` |
| **URL** | `/settings/queue` |
| **Description** | Order number format and customer-facing queue number settings. |
| **Authentication Required** | Yes |

**Success Response — `200 OK`:**

```json
{
  "success": true,
  "message": "Queue settings retrieved successfully",
  "data": {
    "order_number": {
      "prefix": "YL",
      "separator": "-",
      "padding_length": 6,
      "current_sequence": 43,
      "reset_period": "never",
      "next_order_number": "YL-000044"
    },
    "queue_number": {
      "prefix": "A-",
      "starting_queue_number": "4289",
      "next_queue_number": "A-4290"
    }
  }
}
```

| Property | Value |
|----------|-------|
| **HTTP Method** | `PATCH` |
| **URL** | `/settings/queue` |
| **Authentication Required** | Yes (`owner` edit; cashier roles read-only → `403` on PATCH) |

**Request Body:**

```json
{
  "order_number": {
    "prefix": "YL",
    "separator": "-",
    "padding_length": 6,
    "reset_period": "monthly"
  },
  "queue_number": {
    "prefix": "A-",
    "starting_queue_number": "4300"
  }
}
```

**Validation Rules:** QUE-001 through QUE-012

---

### 14.4 System Settings

| Property | Value |
|----------|-------|
| **HTTP Method** | `GET` |
| **URL** | `/settings/system` |
| **Description** | Notification toggles, ironing queue priority, and user preferences. |
| **Authentication Required** | Yes |

**Success Response — `200 OK`:**

```json
{
  "success": true,
  "message": "System settings retrieved successfully",
  "data": {
    "notification_settings": {
      "notify_new_order": true,
      "notify_payment": true,
      "notify_ironing_finished": true,
      "notify_pickup_delivery": true,
      "notify_wallet": true
    },
    "ironing_queue_settings": {
      "binatu_priority_minutes": 5,
      "is_enabled": true,
      "allow_operator_assistance": true
    },
    "user_preferences": {
      "language": "id",
      "theme": "light",
      "push_notifications_enabled": true
    }
  }
}
```

| Property | Value |
|----------|-------|
| **HTTP Method** | `PATCH` |
| **URL** | `/settings/system` |
| **Authentication Required** | Yes |

**Request Body (partial):**

```json
{
  "notification_settings": {
    "notify_wallet": false
  },
  "ironing_queue_settings": {
    "binatu_priority_minutes": 10,
    "is_enabled": true
  },
  "user_preferences": {
    "theme": "dark"
  }
}
```

**Authorization:**

| Section | Edit Role |
|---------|-----------|
| `notification_settings` | `owner` |
| `ironing_queue_settings` | `owner` |
| `user_preferences` | Self (any authenticated user) |

---

## 15. Appendix

### 15.1 Endpoint Index

| # | Method | Endpoint | Module |
|---|--------|----------|--------|
| 1 | POST | `/auth/login` | Authentication |
| 2 | POST | `/auth/logout` | Authentication |
| 3 | POST | `/auth/refresh` | Authentication |
| 4 | POST | `/auth/otp/send` | Authentication |
| 5 | POST | `/auth/otp/verify` | Authentication |
| 6 | GET | `/auth/profile` | Authentication |
| 7 | PATCH | `/auth/profile` | Authentication |
| 8 | GET | `/employees` | Employees |
| 9 | GET | `/employees/{id}` | Employees |
| 10 | POST | `/employees` | Employees |
| 11 | PATCH | `/employees/{id}` | Employees |
| 12 | DELETE | `/employees/{id}` | Employees |
| 13 | GET | `/customers` | Customers |
| 14 | GET | `/customers/{id}` | Customers |
| 15 | POST | `/customers` | Customers |
| 16 | PATCH | `/customers/{id}` | Customers |
| 17 | DELETE | `/customers/{id}` | Customers |
| 18 | GET | `/customers/search` | Customers |
| 19 | GET | `/service-categories` | Laundry Services |
| 20 | POST | `/service-categories` | Laundry Services |
| 21 | PATCH | `/service-categories/{id}` | Laundry Services |
| 22 | DELETE | `/service-categories/{id}` | Laundry Services |
| 23 | GET | `/services` | Laundry Services |
| 24 | GET | `/services/{id}` | Laundry Services |
| 25 | POST | `/services` | Laundry Services |
| 26 | PATCH | `/services/{id}` | Laundry Services |
| 27 | DELETE | `/services/{id}` | Laundry Services |
| 28 | GET | `/services/{id}/price` | Laundry Services |
| 29 | PATCH | `/services/{id}/price` | Laundry Services |
| 30 | POST | `/orders` | Orders |
| 31 | PATCH | `/orders/{id}` | Orders |
| 32 | GET | `/orders/{id}` | Orders |
| 33 | GET | `/orders` | Orders |
| 34 | POST | `/orders/{id}/cancel` | Orders |
| 35 | GET | `/customers/{customer_id}/orders` | Orders |
| 36 | POST | `/orders/{order_id}/payments/cash` | Payments |
| 37 | POST | `/orders/{order_id}/payments/qris` | Payments |
| 38 | POST | `/orders/{order_id}/payments/transfer` | Payments |
| 39 | GET | `/payments/{id}` | Payments |
| 40 | GET | `/payments` | Payments |
| 41 | POST | `/customers/{customer_id}/wallet/top-up` | Wallet |
| 42 | POST | `/customers/{customer_id}/wallet/deduction` | Wallet |
| 43 | GET | `/customers/{customer_id}/wallet/balance` | Wallet |
| 44 | GET | `/customers/{customer_id}/wallet/transactions` | Wallet |
| 45 | POST | `/attendance/check-in` | Attendance |
| 46 | POST | `/attendance/check-out` | Attendance |
| 47 | GET | `/attendance/history` | Attendance |
| 48 | GET | `/attendance/summary` | Attendance |
| 49 | GET | `/ironing-jobs/queue` | Binatu |
| 50 | POST | `/ironing-jobs/{id}/accept` | Binatu |
| 51 | POST | `/ironing-jobs/{id}/start` | Binatu |
| 52 | POST | `/ironing-jobs/{id}/finish` | Binatu |
| 53 | POST | `/ironing-jobs/{id}/ready-for-pickup` | Binatu |
| 54 | GET | `/pickups` | Pickup & Delivery |
| 55 | POST | `/pickups/{id}/accept` | Pickup & Delivery |
| 56 | POST | `/pickups/{id}/complete` | Pickup & Delivery |
| 57 | GET | `/deliveries` | Pickup & Delivery |
| 58 | POST | `/deliveries/{id}/complete` | Pickup & Delivery |
| 59 | GET | `/notifications` | Notifications |
| 60 | GET | `/notifications/unread-count` | Notifications |
| 61 | POST | `/notifications/{id}/read` | Notifications |
| 62 | POST | `/notifications/read-all` | Notifications |
| 63 | GET | `/customer-service/conversations` | Customer Service |
| 64 | GET | `/customer-service/conversations/{id}` | Customer Service |
| 65 | POST | `/customer-service/conversations/{id}/messages` | Customer Service |
| 66 | POST | `/customer-service/conversations/{id}/attachments` | Customer Service |
| 67 | GET | `/settings/receipt` | Settings |
| 68 | PATCH | `/settings/receipt` | Settings |
| 69 | GET | `/settings/company-profile` | Settings |
| 70 | PATCH | `/settings/company-profile` | Settings |
| 71 | GET | `/settings/queue` | Settings |
| 72 | PATCH | `/settings/queue` | Settings |
| 73 | GET | `/settings/system` | Settings |
| 74 | PATCH | `/settings/system` | Settings |

### 15.2 HTTP Status Code Summary

| Code | Usage |
|------|-------|
| `200` | Successful GET, PATCH, POST (action) |
| `201` | Successful resource creation |
| `401` | Unauthorized — missing or invalid JWT |
| `403` | Forbidden — insufficient role |
| `404` | Resource not found |
| `422` | Validation error |
| `429` | Rate limit exceeded (OTP) |
| `500` | Internal server error |

### 15.3 Related Documents

| Document | Purpose |
|----------|---------|
| [02_ERD.md](./02_ERD.md) | Database entity relationships |
| [03_DATA_DICTIONARY.md](./03_DATA_DICTIONARY.md) | Column definitions and enums |
| [04_BUSINESS_RULES.md](./04_BUSINESS_RULES.md) | Domain rules and lifecycle flows |

---

*This document is the authoritative REST API contract for Yelo Laundry ERP.*

