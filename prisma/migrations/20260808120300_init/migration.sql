-- CreateSchema
CREATE SCHEMA IF NOT EXISTS "public";

-- CreateEnum
CREATE TYPE "employee_status" AS ENUM ('active', 'inactive', 'suspended', 'resigned');

-- CreateEnum
CREATE TYPE "role_code" AS ENUM ('owner', 'cashier', 'cashier_laundry', 'cashier_laundry_driver', 'laundry', 'driver');

-- CreateEnum
CREATE TYPE "otp_purpose" AS ENUM ('login', 'register', 'password_reset');

-- CreateEnum
CREATE TYPE "otp_status" AS ENUM ('pending', 'verified', 'expired', 'failed');

-- CreateEnum
CREATE TYPE "gender" AS ENUM ('male', 'female', 'other');

-- CreateEnum
CREATE TYPE "wallet_transaction_type" AS ENUM ('top_up', 'deduction', 'refund', 'adjustment');

-- CreateEnum
CREATE TYPE "reward_point_type" AS ENUM ('earn', 'redeem', 'expired');

-- CreateEnum
CREATE TYPE "device_platform" AS ENUM ('android', 'ios');

-- CreateEnum
CREATE TYPE "priority_level" AS ENUM ('LOW', 'NORMAL', 'HIGH', 'URGENT');

-- CreateEnum
CREATE TYPE "service_unit_type" AS ENUM ('kg', 'piece', 'item');

-- CreateEnum
CREATE TYPE "order_payment_status" AS ENUM ('UNPAID', 'PAID', 'CANCELLED', 'REFUNDED');

-- CreateEnum
CREATE TYPE "order_status" AS ENUM ('CREATED', 'WAITING_PAYMENT', 'PAYMENT_CONFIRMED', 'WAITING_BINATU', 'IRONING_ACCEPTED', 'CURRENTLY_IRONING', 'FINISHED_IRONING', 'READY_FOR_PICKUP', 'WAITING_PICKUP_DRIVER', 'PICKUP_COMPLETED', 'WAITING_DELIVERY', 'OUT_FOR_DELIVERY', 'DELIVERED', 'COMPLETED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "photo_type" AS ENUM ('CUSTOMER_ITEM', 'BEFORE_WASH', 'AFTER_WASH', 'AFTER_IRONING', 'DELIVERY_PROOF', 'RECEIPT', 'OTHER');

-- CreateEnum
CREATE TYPE "timeline_type" AS ENUM ('ORDER', 'PAYMENT', 'IRONING', 'PICKUP', 'DELIVERY', 'NOTIFICATION', 'CUSTOMER_SERVICE', 'SYSTEM');

-- CreateEnum
CREATE TYPE "order_payment_method" AS ENUM ('CASH', 'QRIS', 'BANK_TRANSFER', 'YELO_WALLET');

-- CreateEnum
CREATE TYPE "payment_transaction_status" AS ENUM ('PENDING', 'PAID', 'FAILED', 'REFUNDED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "cashflow_type" AS ENUM ('INCOME', 'EXPENSE');

-- CreateEnum
CREATE TYPE "reference_type" AS ENUM ('ORDER_PAYMENT', 'WALLET_TOPUP', 'REFUND', 'EXPENSE', 'SYSTEM');

-- CreateEnum
CREATE TYPE "attendance_status" AS ENUM ('PRESENT', 'LATE', 'ABSENT', 'LEAVE', 'SICK');

-- CreateEnum
CREATE TYPE "attendance_activity_type" AS ENUM ('CHECK_IN', 'CHECK_OUT');

-- CreateEnum
CREATE TYPE "ironing_status" AS ENUM ('WAITING', 'ACCEPTED', 'IN_PROGRESS', 'FINISHED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "pickup_status" AS ENUM ('WAITING_ASSIGNMENT', 'ASSIGNED', 'ACCEPTED', 'ON_THE_WAY', 'ARRIVED', 'COMPLETED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "delivery_status" AS ENUM ('WAITING_ASSIGNMENT', 'ASSIGNED', 'ACCEPTED', 'OUT_FOR_DELIVERY', 'ARRIVED', 'COMPLETED', 'FAILED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "driver_activity_type" AS ENUM ('ASSIGNMENT_RECEIVED', 'PICKUP_STARTED', 'PICKUP_COMPLETED', 'DELIVERY_STARTED', 'DELIVERY_COMPLETED', 'LOCATION_UPDATED');

-- CreateEnum
CREATE TYPE "notification_type" AS ENUM ('ORDER', 'PAYMENT', 'IRONING', 'PICKUP', 'DELIVERY', 'SYSTEM', 'CUSTOMER_SERVICE');

-- CreateEnum
CREATE TYPE "ticket_status" AS ENUM ('OPEN', 'IN_PROGRESS', 'WAITING_CUSTOMER', 'RESOLVED', 'CLOSED');

-- CreateEnum
CREATE TYPE "sender_type" AS ENUM ('CUSTOMER', 'EMPLOYEE', 'SYSTEM');

-- CreateTable
CREATE TABLE "employees" (
    "id" UUID NOT NULL,
    "employee_code" VARCHAR(20) NOT NULL,
    "full_name" VARCHAR(150) NOT NULL,
    "phone" VARCHAR(20) NOT NULL,
    "email" VARCHAR(150),
    "password_hash" VARCHAR(255) NOT NULL,
    "photo_url" VARCHAR(500),
    "position" VARCHAR(100) NOT NULL,
    "status" "employee_status" NOT NULL DEFAULT 'active',
    "hired_at" DATE,
    "last_login_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "employees_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "roles" (
    "id" UUID NOT NULL,
    "code" "role_code" NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "description" TEXT,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "roles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "permissions" (
    "id" UUID NOT NULL,
    "code" VARCHAR(100) NOT NULL,
    "name" VARCHAR(150) NOT NULL,
    "module" VARCHAR(50) NOT NULL,
    "description" TEXT,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "permissions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "employee_roles" (
    "id" UUID NOT NULL,
    "employee_id" UUID NOT NULL,
    "role_id" UUID NOT NULL,
    "assigned_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "assigned_by_employee_id" UUID,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "employee_roles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "role_permissions" (
    "id" UUID NOT NULL,
    "role_id" UUID NOT NULL,
    "permission_id" UUID NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "role_permissions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "employee_sessions" (
    "id" UUID NOT NULL,
    "employee_id" UUID NOT NULL,
    "refresh_token_hash" VARCHAR(255) NOT NULL,
    "device_info" VARCHAR(255),
    "ip_address" VARCHAR(45),
    "expires_at" TIMESTAMPTZ(6) NOT NULL,
    "revoked_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "employee_sessions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "otp_codes" (
    "id" UUID NOT NULL,
    "employee_id" UUID,
    "phone" VARCHAR(20) NOT NULL,
    "code_hash" VARCHAR(255) NOT NULL,
    "purpose" "otp_purpose" NOT NULL,
    "status" "otp_status" NOT NULL DEFAULT 'pending',
    "attempts" INTEGER NOT NULL DEFAULT 0,
    "max_attempts" INTEGER NOT NULL DEFAULT 5,
    "expires_at" TIMESTAMPTZ(6) NOT NULL,
    "verified_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "otp_codes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "customers" (
    "id" UUID NOT NULL,
    "customer_code" VARCHAR(20) NOT NULL,
    "full_name" VARCHAR(150) NOT NULL,
    "phone" VARCHAR(20) NOT NULL,
    "email" VARCHAR(150),
    "gender" "gender",
    "birth_date" DATE,
    "default_address_id" UUID,
    "photo_url" VARCHAR(500),
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "customers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "customer_addresses" (
    "id" UUID NOT NULL,
    "customer_id" UUID NOT NULL,
    "recipient_name" VARCHAR(150) NOT NULL,
    "phone" VARCHAR(20) NOT NULL,
    "province" VARCHAR(100) NOT NULL,
    "city" VARCHAR(100) NOT NULL,
    "district" VARCHAR(100) NOT NULL,
    "postal_code" VARCHAR(10),
    "address_detail" TEXT NOT NULL,
    "latitude" DECIMAL(10,7),
    "longitude" DECIMAL(10,7),
    "is_default" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "customer_addresses_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "customer_wallets" (
    "id" UUID NOT NULL,
    "customer_id" UUID NOT NULL,
    "current_balance" DECIMAL(15,2) NOT NULL DEFAULT 0,
    "currency" VARCHAR(3) NOT NULL DEFAULT 'IDR',
    "balance_updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "customer_wallets_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "wallet_transactions" (
    "id" UUID NOT NULL,
    "customer_id" UUID NOT NULL,
    "wallet_id" UUID NOT NULL,
    "reference_number" VARCHAR(50),
    "amount" DECIMAL(15,2) NOT NULL,
    "type" "wallet_transaction_type" NOT NULL,
    "description" TEXT,
    "created_by_employee_id" UUID,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "wallet_transactions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "reward_points" (
    "id" UUID NOT NULL,
    "customer_id" UUID NOT NULL,
    "point" INTEGER NOT NULL,
    "type" "reward_point_type" NOT NULL,
    "description" TEXT,
    "expired_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "reward_points_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "customer_notes" (
    "id" UUID NOT NULL,
    "customer_id" UUID NOT NULL,
    "employee_id" UUID NOT NULL,
    "note" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "customer_notes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "customer_devices" (
    "id" UUID NOT NULL,
    "customer_id" UUID NOT NULL,
    "device_token" VARCHAR(500) NOT NULL,
    "platform" "device_platform" NOT NULL,
    "last_login_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "customer_devices_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "service_categories" (
    "id" UUID NOT NULL,
    "code" VARCHAR(50) NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "description" TEXT,
    "display_order" INTEGER NOT NULL DEFAULT 0,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "service_categories_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "services" (
    "id" UUID NOT NULL,
    "category_id" UUID NOT NULL,
    "service_code" VARCHAR(50) NOT NULL,
    "service_name" VARCHAR(150) NOT NULL,
    "description" TEXT,
    "unit_type" "service_unit_type" NOT NULL DEFAULT 'kg',
    "weight" BOOLEAN NOT NULL DEFAULT true,
    "piece" BOOLEAN NOT NULL DEFAULT false,
    "duration_day" INTEGER,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "services_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "service_prices" (
    "id" UUID NOT NULL,
    "service_id" UUID NOT NULL,
    "price" DECIMAL(15,2) NOT NULL,
    "effective_date" DATE NOT NULL,
    "expired_date" DATE,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "service_prices_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "orders" (
    "id" UUID NOT NULL,
    "queue_number" VARCHAR(20) NOT NULL,
    "invoice_number" VARCHAR(30) NOT NULL,
    "customer_id" UUID NOT NULL,
    "order_date" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "received_date" TIMESTAMPTZ(6),
    "estimated_finish_date" TIMESTAMPTZ(6),
    "completed_date" TIMESTAMPTZ(6),
    "pickup_required" BOOLEAN NOT NULL DEFAULT false,
    "delivery_required" BOOLEAN NOT NULL DEFAULT false,
    "pickup_address_id" UUID,
    "delivery_address_id" UUID,
    "payment_status" "order_payment_status" NOT NULL DEFAULT 'UNPAID',
    "order_status" "order_status" NOT NULL DEFAULT 'CREATED',
    "payment_method" "order_payment_method",
    "notes" TEXT,
    "created_by_employee_id" UUID NOT NULL,
    "updated_by_employee_id" UUID,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "orders_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "order_items" (
    "id" UUID NOT NULL,
    "order_id" UUID NOT NULL,
    "service_id" UUID NOT NULL,
    "service_price_id" UUID NOT NULL,
    "quantity" DECIMAL(10,3) NOT NULL,
    "weight" DECIMAL(10,3),
    "unit_price" DECIMAL(15,2) NOT NULL,
    "subtotal" DECIMAL(15,2) NOT NULL,
    "notes" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "order_items_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "order_status_histories" (
    "id" UUID NOT NULL,
    "order_id" UUID NOT NULL,
    "previous_status" "order_status",
    "current_status" "order_status" NOT NULL,
    "changed_by_employee_id" UUID,
    "notes" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "order_status_histories_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "order_photos" (
    "id" UUID NOT NULL,
    "order_id" UUID NOT NULL,
    "photo_type" "photo_type" NOT NULL,
    "photo_url" VARCHAR(500) NOT NULL,
    "uploaded_by_employee_id" UUID NOT NULL,
    "description" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "order_photos_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "order_timelines" (
    "id" UUID NOT NULL,
    "order_id" UUID NOT NULL,
    "timeline_type" "timeline_type" NOT NULL,
    "title" VARCHAR(200) NOT NULL,
    "description" TEXT,
    "employee_id" UUID,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "order_timelines_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "payment_methods" (
    "id" UUID NOT NULL,
    "code" VARCHAR(30) NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "payment_methods_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "payments" (
    "id" UUID NOT NULL,
    "order_id" UUID NOT NULL,
    "payment_method_id" UUID NOT NULL,
    "amount" DECIMAL(15,2) NOT NULL,
    "paid_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "reference_number" VARCHAR(50),
    "payment_status" "payment_transaction_status" NOT NULL DEFAULT 'PENDING',
    "received_by_employee_id" UUID NOT NULL,
    "notes" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "payments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "expense_categories" (
    "id" UUID NOT NULL,
    "code" VARCHAR(50) NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "description" TEXT,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "expense_categories_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "expenses" (
    "id" UUID NOT NULL,
    "expense_category_id" UUID NOT NULL,
    "employee_id" UUID NOT NULL,
    "title" VARCHAR(200) NOT NULL,
    "description" TEXT,
    "amount" DECIMAL(15,2) NOT NULL,
    "expense_date" DATE NOT NULL,
    "receipt_photo_url" VARCHAR(500),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "expenses_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "cashflows" (
    "id" UUID NOT NULL,
    "type" "cashflow_type" NOT NULL,
    "reference_type" "reference_type" NOT NULL,
    "reference_id" UUID NOT NULL,
    "amount" DECIMAL(15,2) NOT NULL,
    "transaction_date" TIMESTAMPTZ(6) NOT NULL,
    "description" TEXT,
    "created_by_employee_id" UUID NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "cashflows_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "attendances" (
    "id" UUID NOT NULL,
    "employee_id" UUID NOT NULL,
    "attendance_date" DATE NOT NULL,
    "check_in" TIMESTAMPTZ(6),
    "check_out" TIMESTAMPTZ(6),
    "working_minutes" INTEGER,
    "late_minutes" INTEGER NOT NULL DEFAULT 0,
    "status" "attendance_status" NOT NULL DEFAULT 'PRESENT',
    "notes" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "attendances_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "attendance_logs" (
    "id" UUID NOT NULL,
    "attendance_id" UUID NOT NULL,
    "employee_id" UUID NOT NULL,
    "activity_type" "attendance_activity_type" NOT NULL,
    "activity_time" TIMESTAMPTZ(6) NOT NULL,
    "latitude" DECIMAL(10,7),
    "longitude" DECIMAL(10,7),
    "device_info" VARCHAR(255),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "attendance_logs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "attendance_settings" (
    "id" UUID NOT NULL,
    "work_start_time" TIME(0) NOT NULL,
    "work_end_time" TIME(0) NOT NULL,
    "late_tolerance_minutes" INTEGER NOT NULL DEFAULT 0,
    "overtime_enabled" BOOLEAN NOT NULL DEFAULT false,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "attendance_settings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ironing_jobs" (
    "id" UUID NOT NULL,
    "order_id" UUID NOT NULL,
    "employee_id" UUID,
    "accepted_at" TIMESTAMPTZ(6),
    "started_at" TIMESTAMPTZ(6),
    "finished_at" TIMESTAMPTZ(6),
    "status" "ironing_status" NOT NULL DEFAULT 'WAITING',
    "priority" "priority_level" NOT NULL DEFAULT 'NORMAL',
    "estimated_minutes" INTEGER,
    "actual_minutes" INTEGER,
    "notes" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "ironing_jobs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ironing_contributions" (
    "id" UUID NOT NULL,
    "ironing_job_id" UUID NOT NULL,
    "employee_id" UUID NOT NULL,
    "help_started_at" TIMESTAMPTZ(6) NOT NULL,
    "help_finished_at" TIMESTAMPTZ(6),
    "contribution_minutes" INTEGER,
    "notes" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ironing_contributions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pickup_jobs" (
    "id" UUID NOT NULL,
    "order_id" UUID NOT NULL,
    "driver_id" UUID,
    "pickup_address_id" UUID NOT NULL,
    "scheduled_pickup_at" TIMESTAMPTZ(6),
    "assigned_at" TIMESTAMPTZ(6),
    "accepted_at" TIMESTAMPTZ(6),
    "arrived_at" TIMESTAMPTZ(6),
    "completed_at" TIMESTAMPTZ(6),
    "status" "pickup_status" NOT NULL DEFAULT 'WAITING_ASSIGNMENT',
    "notes" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "pickup_jobs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "delivery_jobs" (
    "id" UUID NOT NULL,
    "order_id" UUID NOT NULL,
    "driver_id" UUID,
    "delivery_address_id" UUID NOT NULL,
    "scheduled_delivery_at" TIMESTAMPTZ(6),
    "assigned_at" TIMESTAMPTZ(6),
    "accepted_at" TIMESTAMPTZ(6),
    "departed_at" TIMESTAMPTZ(6),
    "completed_at" TIMESTAMPTZ(6),
    "status" "delivery_status" NOT NULL DEFAULT 'WAITING_ASSIGNMENT',
    "proof_photo_url" VARCHAR(500),
    "customer_signature_url" VARCHAR(500),
    "notes" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "delivery_jobs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "driver_activities" (
    "id" UUID NOT NULL,
    "driver_id" UUID NOT NULL,
    "order_id" UUID NOT NULL,
    "activity_type" "driver_activity_type" NOT NULL,
    "latitude" DECIMAL(10,7),
    "longitude" DECIMAL(10,7),
    "description" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "driver_activities_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "notifications" (
    "id" UUID NOT NULL,
    "title" VARCHAR(200) NOT NULL,
    "body" TEXT NOT NULL,
    "type" "notification_type" NOT NULL,
    "priority" "priority_level" NOT NULL DEFAULT 'NORMAL',
    "sender_employee_id" UUID,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "notifications_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "notification_reads" (
    "id" UUID NOT NULL,
    "notification_id" UUID NOT NULL,
    "employee_id" UUID NOT NULL,
    "read_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "notification_reads_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "notification_templates" (
    "id" UUID NOT NULL,
    "code" VARCHAR(50) NOT NULL,
    "title" VARCHAR(200) NOT NULL,
    "body" TEXT NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "notification_templates_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "customer_service_tickets" (
    "id" UUID NOT NULL,
    "customer_id" UUID NOT NULL,
    "employee_id" UUID,
    "subject" VARCHAR(200) NOT NULL,
    "status" "ticket_status" NOT NULL DEFAULT 'OPEN',
    "priority" "priority_level" NOT NULL DEFAULT 'NORMAL',
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,
    "closed_at" TIMESTAMPTZ(6),
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "customer_service_tickets_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "customer_service_messages" (
    "id" UUID NOT NULL,
    "ticket_id" UUID NOT NULL,
    "sender_type" "sender_type" NOT NULL,
    "employee_id" UUID,
    "customer_id" UUID,
    "message" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "customer_service_messages_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "customer_service_attachments" (
    "id" UUID NOT NULL,
    "message_id" UUID NOT NULL,
    "file_name" VARCHAR(255) NOT NULL,
    "file_url" VARCHAR(500) NOT NULL,
    "mime_type" VARCHAR(100) NOT NULL,
    "file_size" BIGINT NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "customer_service_attachments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "company_settings" (
    "id" UUID NOT NULL,
    "company_name" VARCHAR(200) NOT NULL,
    "phone" VARCHAR(20),
    "email" VARCHAR(150),
    "address" TEXT,
    "logo_url" VARCHAR(500),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "company_settings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "receipt_settings" (
    "id" UUID NOT NULL,
    "show_logo" BOOLEAN NOT NULL DEFAULT true,
    "show_qr_code" BOOLEAN NOT NULL DEFAULT false,
    "footer_text" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "receipt_settings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "queue_settings" (
    "id" UUID NOT NULL,
    "prefix" VARCHAR(10) NOT NULL DEFAULT 'Q',
    "daily_reset" BOOLEAN NOT NULL DEFAULT true,
    "starting_number" INTEGER NOT NULL DEFAULT 1,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "queue_settings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "system_settings" (
    "id" UUID NOT NULL,
    "setting_key" VARCHAR(100) NOT NULL,
    "setting_value" TEXT NOT NULL,
    "description" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "system_settings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "audit_logs" (
    "id" UUID NOT NULL,
    "employee_id" UUID,
    "module" VARCHAR(50) NOT NULL,
    "action" VARCHAR(100) NOT NULL,
    "reference_id" UUID,
    "description" TEXT,
    "ip_address" VARCHAR(45),
    "user_agent" VARCHAR(500),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "audit_logs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "media_files" (
    "id" UUID NOT NULL,
    "file_name" VARCHAR(255) NOT NULL,
    "file_url" VARCHAR(500) NOT NULL,
    "mime_type" VARCHAR(100) NOT NULL,
    "file_size" BIGINT NOT NULL,
    "uploaded_by_employee_id" UUID NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "media_files_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "employees_employee_code_key" ON "employees"("employee_code");

-- CreateIndex
CREATE UNIQUE INDEX "employees_phone_key" ON "employees"("phone");

-- CreateIndex
CREATE UNIQUE INDEX "employees_email_key" ON "employees"("email");

-- CreateIndex
CREATE INDEX "idx_employees_status" ON "employees"("status");

-- CreateIndex
CREATE INDEX "idx_employees_deleted_at" ON "employees"("deleted_at");

-- CreateIndex
CREATE INDEX "idx_employees_full_name" ON "employees"("full_name");

-- CreateIndex
CREATE UNIQUE INDEX "roles_code_key" ON "roles"("code");

-- CreateIndex
CREATE INDEX "idx_roles_is_active" ON "roles"("is_active");

-- CreateIndex
CREATE INDEX "idx_roles_deleted_at" ON "roles"("deleted_at");

-- CreateIndex
CREATE UNIQUE INDEX "permissions_code_key" ON "permissions"("code");

-- CreateIndex
CREATE INDEX "idx_permissions_module" ON "permissions"("module");

-- CreateIndex
CREATE INDEX "idx_permissions_is_active" ON "permissions"("is_active");

-- CreateIndex
CREATE INDEX "idx_permissions_deleted_at" ON "permissions"("deleted_at");

-- CreateIndex
CREATE INDEX "idx_employee_roles_employee_id" ON "employee_roles"("employee_id");

-- CreateIndex
CREATE INDEX "idx_employee_roles_role_id" ON "employee_roles"("role_id");

-- CreateIndex
CREATE INDEX "idx_employee_roles_assigned_by" ON "employee_roles"("assigned_by_employee_id");

-- CreateIndex
CREATE INDEX "idx_employee_roles_deleted_at" ON "employee_roles"("deleted_at");

-- CreateIndex
CREATE UNIQUE INDEX "idx_employee_roles_unique" ON "employee_roles"("employee_id", "role_id");

-- CreateIndex
CREATE INDEX "idx_role_permissions_role_id" ON "role_permissions"("role_id");

-- CreateIndex
CREATE INDEX "idx_role_permissions_permission_id" ON "role_permissions"("permission_id");

-- CreateIndex
CREATE INDEX "idx_role_permissions_deleted_at" ON "role_permissions"("deleted_at");

-- CreateIndex
CREATE UNIQUE INDEX "idx_role_permissions_unique" ON "role_permissions"("role_id", "permission_id");

-- CreateIndex
CREATE UNIQUE INDEX "employee_sessions_refresh_token_hash_key" ON "employee_sessions"("refresh_token_hash");

-- CreateIndex
CREATE INDEX "idx_employee_sessions_employee_id" ON "employee_sessions"("employee_id");

-- CreateIndex
CREATE INDEX "idx_employee_sessions_expires_at" ON "employee_sessions"("expires_at");

-- CreateIndex
CREATE INDEX "idx_employee_sessions_deleted_at" ON "employee_sessions"("deleted_at");

-- CreateIndex
CREATE INDEX "idx_otp_codes_phone" ON "otp_codes"("phone");

-- CreateIndex
CREATE INDEX "idx_otp_codes_status" ON "otp_codes"("status");

-- CreateIndex
CREATE INDEX "idx_otp_codes_expires_at" ON "otp_codes"("expires_at");

-- CreateIndex
CREATE INDEX "idx_otp_codes_employee_id" ON "otp_codes"("employee_id");

-- CreateIndex
CREATE INDEX "idx_otp_codes_deleted_at" ON "otp_codes"("deleted_at");

-- CreateIndex
CREATE UNIQUE INDEX "customers_customer_code_key" ON "customers"("customer_code");

-- CreateIndex
CREATE UNIQUE INDEX "customers_phone_key" ON "customers"("phone");

-- CreateIndex
CREATE UNIQUE INDEX "customers_default_address_id_key" ON "customers"("default_address_id");

-- CreateIndex
CREATE INDEX "idx_customers_full_name" ON "customers"("full_name");

-- CreateIndex
CREATE INDEX "idx_customers_is_active" ON "customers"("is_active");

-- CreateIndex
CREATE INDEX "idx_customers_deleted_at" ON "customers"("deleted_at");

-- CreateIndex
CREATE INDEX "idx_customer_addresses_customer_id" ON "customer_addresses"("customer_id");

-- CreateIndex
CREATE INDEX "idx_customer_addresses_is_default" ON "customer_addresses"("is_default");

-- CreateIndex
CREATE INDEX "idx_customer_addresses_deleted_at" ON "customer_addresses"("deleted_at");

-- CreateIndex
CREATE UNIQUE INDEX "customer_wallets_customer_id_key" ON "customer_wallets"("customer_id");

-- CreateIndex
CREATE INDEX "idx_customer_wallets_deleted_at" ON "customer_wallets"("deleted_at");

-- CreateIndex
CREATE UNIQUE INDEX "wallet_transactions_reference_number_key" ON "wallet_transactions"("reference_number");

-- CreateIndex
CREATE INDEX "idx_wallet_transactions_customer_id" ON "wallet_transactions"("customer_id");

-- CreateIndex
CREATE INDEX "idx_wallet_transactions_wallet_id" ON "wallet_transactions"("wallet_id");

-- CreateIndex
CREATE INDEX "idx_wallet_transactions_type" ON "wallet_transactions"("type");

-- CreateIndex
CREATE INDEX "idx_wallet_transactions_created_at" ON "wallet_transactions"("created_at");

-- CreateIndex
CREATE INDEX "idx_wallet_transactions_created_by" ON "wallet_transactions"("created_by_employee_id");

-- CreateIndex
CREATE INDEX "idx_wallet_transactions_deleted_at" ON "wallet_transactions"("deleted_at");

-- CreateIndex
CREATE INDEX "idx_reward_points_customer_id" ON "reward_points"("customer_id");

-- CreateIndex
CREATE INDEX "idx_reward_points_type" ON "reward_points"("type");

-- CreateIndex
CREATE INDEX "idx_reward_points_expired_at" ON "reward_points"("expired_at");

-- CreateIndex
CREATE INDEX "idx_reward_points_deleted_at" ON "reward_points"("deleted_at");

-- CreateIndex
CREATE INDEX "idx_customer_notes_customer_id" ON "customer_notes"("customer_id");

-- CreateIndex
CREATE INDEX "idx_customer_notes_employee_id" ON "customer_notes"("employee_id");

-- CreateIndex
CREATE INDEX "idx_customer_notes_created_at" ON "customer_notes"("created_at");

-- CreateIndex
CREATE INDEX "idx_customer_notes_deleted_at" ON "customer_notes"("deleted_at");

-- CreateIndex
CREATE INDEX "idx_customer_devices_platform" ON "customer_devices"("platform");

-- CreateIndex
CREATE INDEX "idx_customer_devices_deleted_at" ON "customer_devices"("deleted_at");

-- CreateIndex
CREATE UNIQUE INDEX "idx_customer_devices_customer_token" ON "customer_devices"("customer_id", "device_token");

-- CreateIndex
CREATE UNIQUE INDEX "service_categories_code_key" ON "service_categories"("code");

-- CreateIndex
CREATE INDEX "idx_service_categories_display_order" ON "service_categories"("display_order");

-- CreateIndex
CREATE INDEX "idx_service_categories_is_active" ON "service_categories"("is_active");

-- CreateIndex
CREATE INDEX "idx_service_categories_deleted_at" ON "service_categories"("deleted_at");

-- CreateIndex
CREATE UNIQUE INDEX "services_service_code_key" ON "services"("service_code");

-- CreateIndex
CREATE INDEX "idx_services_category_id" ON "services"("category_id");

-- CreateIndex
CREATE INDEX "idx_services_is_active" ON "services"("is_active");

-- CreateIndex
CREATE INDEX "idx_services_unit_type" ON "services"("unit_type");

-- CreateIndex
CREATE INDEX "idx_services_deleted_at" ON "services"("deleted_at");

-- CreateIndex
CREATE INDEX "idx_service_prices_service_id" ON "service_prices"("service_id");

-- CreateIndex
CREATE INDEX "idx_service_prices_effective_date" ON "service_prices"("effective_date");

-- CreateIndex
CREATE INDEX "idx_service_prices_expired_date" ON "service_prices"("expired_date");

-- CreateIndex
CREATE INDEX "idx_service_prices_is_active" ON "service_prices"("is_active");

-- CreateIndex
CREATE INDEX "idx_service_prices_deleted_at" ON "service_prices"("deleted_at");

-- CreateIndex
CREATE UNIQUE INDEX "idx_service_prices_service_effective" ON "service_prices"("service_id", "effective_date");

-- CreateIndex
CREATE UNIQUE INDEX "orders_invoice_number_key" ON "orders"("invoice_number");

-- CreateIndex
CREATE INDEX "idx_orders_customer_id" ON "orders"("customer_id");

-- CreateIndex
CREATE INDEX "idx_orders_queue_number" ON "orders"("queue_number");

-- CreateIndex
CREATE INDEX "idx_orders_order_status" ON "orders"("order_status");

-- CreateIndex
CREATE INDEX "idx_orders_payment_status" ON "orders"("payment_status");

-- CreateIndex
CREATE INDEX "idx_orders_status_active" ON "orders"("order_status", "deleted_at");

-- CreateIndex
CREATE INDEX "idx_orders_payment_active" ON "orders"("payment_status", "deleted_at");

-- CreateIndex
CREATE INDEX "idx_orders_received_date" ON "orders"("received_date");

-- CreateIndex
CREATE INDEX "idx_orders_estimated_finish_date" ON "orders"("estimated_finish_date");

-- CreateIndex
CREATE INDEX "idx_orders_order_date" ON "orders"("order_date");

-- CreateIndex
CREATE INDEX "idx_orders_created_by_employee_id" ON "orders"("created_by_employee_id");

-- CreateIndex
CREATE INDEX "idx_orders_updated_by_employee_id" ON "orders"("updated_by_employee_id");

-- CreateIndex
CREATE INDEX "idx_orders_deleted_at" ON "orders"("deleted_at");

-- CreateIndex
CREATE INDEX "idx_order_items_order_id" ON "order_items"("order_id");

-- CreateIndex
CREATE INDEX "idx_order_items_service_id" ON "order_items"("service_id");

-- CreateIndex
CREATE INDEX "idx_order_items_service_price_id" ON "order_items"("service_price_id");

-- CreateIndex
CREATE INDEX "idx_order_items_deleted_at" ON "order_items"("deleted_at");

-- CreateIndex
CREATE INDEX "idx_order_status_histories_order_id" ON "order_status_histories"("order_id");

-- CreateIndex
CREATE INDEX "idx_order_status_histories_current_status" ON "order_status_histories"("current_status");

-- CreateIndex
CREATE INDEX "idx_order_status_histories_changed_by" ON "order_status_histories"("changed_by_employee_id");

-- CreateIndex
CREATE INDEX "idx_order_status_histories_created_at" ON "order_status_histories"("created_at");

-- CreateIndex
CREATE INDEX "idx_order_photos_order_id" ON "order_photos"("order_id");

-- CreateIndex
CREATE INDEX "idx_order_photos_photo_type" ON "order_photos"("photo_type");

-- CreateIndex
CREATE INDEX "idx_order_photos_uploaded_by" ON "order_photos"("uploaded_by_employee_id");

-- CreateIndex
CREATE INDEX "idx_order_photos_created_at" ON "order_photos"("created_at");

-- CreateIndex
CREATE INDEX "idx_order_timelines_order_id" ON "order_timelines"("order_id");

-- CreateIndex
CREATE INDEX "idx_order_timelines_timeline_type" ON "order_timelines"("timeline_type");

-- CreateIndex
CREATE INDEX "idx_order_timelines_employee_id" ON "order_timelines"("employee_id");

-- CreateIndex
CREATE INDEX "idx_order_timelines_created_at" ON "order_timelines"("created_at");

-- CreateIndex
CREATE UNIQUE INDEX "payment_methods_code_key" ON "payment_methods"("code");

-- CreateIndex
CREATE INDEX "idx_payment_methods_is_active" ON "payment_methods"("is_active");

-- CreateIndex
CREATE INDEX "idx_payment_methods_deleted_at" ON "payment_methods"("deleted_at");

-- CreateIndex
CREATE UNIQUE INDEX "payments_reference_number_key" ON "payments"("reference_number");

-- CreateIndex
CREATE INDEX "idx_payments_order_id" ON "payments"("order_id");

-- CreateIndex
CREATE INDEX "idx_payments_payment_method_id" ON "payments"("payment_method_id");

-- CreateIndex
CREATE INDEX "idx_payments_payment_status" ON "payments"("payment_status");

-- CreateIndex
CREATE INDEX "idx_payments_paid_at" ON "payments"("paid_at");

-- CreateIndex
CREATE INDEX "idx_payments_received_by_employee_id" ON "payments"("received_by_employee_id");

-- CreateIndex
CREATE INDEX "idx_payments_deleted_at" ON "payments"("deleted_at");

-- CreateIndex
CREATE UNIQUE INDEX "expense_categories_code_key" ON "expense_categories"("code");

-- CreateIndex
CREATE INDEX "idx_expense_categories_is_active" ON "expense_categories"("is_active");

-- CreateIndex
CREATE INDEX "idx_expense_categories_deleted_at" ON "expense_categories"("deleted_at");

-- CreateIndex
CREATE INDEX "idx_expenses_expense_category_id" ON "expenses"("expense_category_id");

-- CreateIndex
CREATE INDEX "idx_expenses_employee_id" ON "expenses"("employee_id");

-- CreateIndex
CREATE INDEX "idx_expenses_expense_date" ON "expenses"("expense_date");

-- CreateIndex
CREATE INDEX "idx_expenses_deleted_at" ON "expenses"("deleted_at");

-- CreateIndex
CREATE INDEX "idx_cashflows_type" ON "cashflows"("type");

-- CreateIndex
CREATE INDEX "idx_cashflows_reference" ON "cashflows"("reference_type", "reference_id");

-- CreateIndex
CREATE INDEX "idx_cashflows_transaction_date" ON "cashflows"("transaction_date");

-- CreateIndex
CREATE INDEX "idx_cashflows_created_by_employee_id" ON "cashflows"("created_by_employee_id");

-- CreateIndex
CREATE INDEX "idx_attendances_employee_id" ON "attendances"("employee_id");

-- CreateIndex
CREATE INDEX "idx_attendances_attendance_date" ON "attendances"("attendance_date");

-- CreateIndex
CREATE INDEX "idx_attendances_status" ON "attendances"("status");

-- CreateIndex
CREATE INDEX "idx_attendances_deleted_at" ON "attendances"("deleted_at");

-- CreateIndex
CREATE UNIQUE INDEX "idx_attendances_employee_date" ON "attendances"("employee_id", "attendance_date");

-- CreateIndex
CREATE INDEX "idx_attendance_logs_attendance_id" ON "attendance_logs"("attendance_id");

-- CreateIndex
CREATE INDEX "idx_attendance_logs_employee_id" ON "attendance_logs"("employee_id");

-- CreateIndex
CREATE INDEX "idx_attendance_logs_activity_type" ON "attendance_logs"("activity_type");

-- CreateIndex
CREATE INDEX "idx_attendance_logs_activity_time" ON "attendance_logs"("activity_time");

-- CreateIndex
CREATE INDEX "idx_attendance_settings_is_active" ON "attendance_settings"("is_active");

-- CreateIndex
CREATE INDEX "idx_ironing_jobs_order_id" ON "ironing_jobs"("order_id");

-- CreateIndex
CREATE INDEX "idx_ironing_jobs_employee_id" ON "ironing_jobs"("employee_id");

-- CreateIndex
CREATE INDEX "idx_ironing_jobs_status" ON "ironing_jobs"("status");

-- CreateIndex
CREATE INDEX "idx_ironing_jobs_priority" ON "ironing_jobs"("priority");

-- CreateIndex
CREATE INDEX "idx_ironing_jobs_accepted_at" ON "ironing_jobs"("accepted_at");

-- CreateIndex
CREATE INDEX "idx_ironing_jobs_finished_at" ON "ironing_jobs"("finished_at");

-- CreateIndex
CREATE INDEX "idx_ironing_jobs_deleted_at" ON "ironing_jobs"("deleted_at");

-- CreateIndex
CREATE INDEX "idx_ironing_contributions_ironing_job_id" ON "ironing_contributions"("ironing_job_id");

-- CreateIndex
CREATE INDEX "idx_ironing_contributions_employee_id" ON "ironing_contributions"("employee_id");

-- CreateIndex
CREATE INDEX "idx_ironing_contributions_help_started_at" ON "ironing_contributions"("help_started_at");

-- CreateIndex
CREATE UNIQUE INDEX "pickup_jobs_order_id_key" ON "pickup_jobs"("order_id");

-- CreateIndex
CREATE INDEX "idx_pickup_jobs_driver_id" ON "pickup_jobs"("driver_id");

-- CreateIndex
CREATE INDEX "idx_pickup_jobs_status" ON "pickup_jobs"("status");

-- CreateIndex
CREATE INDEX "idx_pickup_jobs_scheduled_pickup_at" ON "pickup_jobs"("scheduled_pickup_at");

-- CreateIndex
CREATE INDEX "idx_pickup_jobs_created_at" ON "pickup_jobs"("created_at");

-- CreateIndex
CREATE INDEX "idx_pickup_jobs_deleted_at" ON "pickup_jobs"("deleted_at");

-- CreateIndex
CREATE UNIQUE INDEX "delivery_jobs_order_id_key" ON "delivery_jobs"("order_id");

-- CreateIndex
CREATE INDEX "idx_delivery_jobs_driver_id" ON "delivery_jobs"("driver_id");

-- CreateIndex
CREATE INDEX "idx_delivery_jobs_status" ON "delivery_jobs"("status");

-- CreateIndex
CREATE INDEX "idx_delivery_jobs_scheduled_delivery_at" ON "delivery_jobs"("scheduled_delivery_at");

-- CreateIndex
CREATE INDEX "idx_delivery_jobs_created_at" ON "delivery_jobs"("created_at");

-- CreateIndex
CREATE INDEX "idx_delivery_jobs_deleted_at" ON "delivery_jobs"("deleted_at");

-- CreateIndex
CREATE INDEX "idx_driver_activities_driver_id" ON "driver_activities"("driver_id");

-- CreateIndex
CREATE INDEX "idx_driver_activities_order_id" ON "driver_activities"("order_id");

-- CreateIndex
CREATE INDEX "idx_driver_activities_activity_type" ON "driver_activities"("activity_type");

-- CreateIndex
CREATE INDEX "idx_driver_activities_created_at" ON "driver_activities"("created_at");

-- CreateIndex
CREATE INDEX "idx_notifications_type" ON "notifications"("type");

-- CreateIndex
CREATE INDEX "idx_notifications_priority" ON "notifications"("priority");

-- CreateIndex
CREATE INDEX "idx_notifications_sender_employee_id" ON "notifications"("sender_employee_id");

-- CreateIndex
CREATE INDEX "idx_notifications_created_at" ON "notifications"("created_at");

-- CreateIndex
CREATE INDEX "idx_notifications_deleted_at" ON "notifications"("deleted_at");

-- CreateIndex
CREATE INDEX "idx_notification_reads_notification_id" ON "notification_reads"("notification_id");

-- CreateIndex
CREATE INDEX "idx_notification_reads_employee_id" ON "notification_reads"("employee_id");

-- CreateIndex
CREATE INDEX "idx_notification_reads_read_at" ON "notification_reads"("read_at");

-- CreateIndex
CREATE UNIQUE INDEX "idx_notification_reads_unique" ON "notification_reads"("notification_id", "employee_id");

-- CreateIndex
CREATE UNIQUE INDEX "notification_templates_code_key" ON "notification_templates"("code");

-- CreateIndex
CREATE INDEX "idx_notification_templates_is_active" ON "notification_templates"("is_active");

-- CreateIndex
CREATE INDEX "idx_notification_templates_deleted_at" ON "notification_templates"("deleted_at");

-- CreateIndex
CREATE INDEX "idx_customer_service_tickets_customer_id" ON "customer_service_tickets"("customer_id");

-- CreateIndex
CREATE INDEX "idx_customer_service_tickets_employee_id" ON "customer_service_tickets"("employee_id");

-- CreateIndex
CREATE INDEX "idx_customer_service_tickets_status" ON "customer_service_tickets"("status");

-- CreateIndex
CREATE INDEX "idx_customer_service_tickets_priority" ON "customer_service_tickets"("priority");

-- CreateIndex
CREATE INDEX "idx_customer_service_tickets_created_at" ON "customer_service_tickets"("created_at");

-- CreateIndex
CREATE INDEX "idx_customer_service_tickets_deleted_at" ON "customer_service_tickets"("deleted_at");

-- CreateIndex
CREATE INDEX "idx_customer_service_messages_ticket_id" ON "customer_service_messages"("ticket_id");

-- CreateIndex
CREATE INDEX "idx_customer_service_messages_employee_id" ON "customer_service_messages"("employee_id");

-- CreateIndex
CREATE INDEX "idx_customer_service_messages_customer_id" ON "customer_service_messages"("customer_id");

-- CreateIndex
CREATE INDEX "idx_customer_service_messages_sender_type" ON "customer_service_messages"("sender_type");

-- CreateIndex
CREATE INDEX "idx_customer_service_messages_created_at" ON "customer_service_messages"("created_at");

-- CreateIndex
CREATE INDEX "idx_customer_service_attachments_message_id" ON "customer_service_attachments"("message_id");

-- CreateIndex
CREATE INDEX "idx_customer_service_attachments_created_at" ON "customer_service_attachments"("created_at");

-- CreateIndex
CREATE UNIQUE INDEX "system_settings_setting_key_key" ON "system_settings"("setting_key");

-- CreateIndex
CREATE INDEX "idx_audit_logs_employee_id" ON "audit_logs"("employee_id");

-- CreateIndex
CREATE INDEX "idx_audit_logs_module_action" ON "audit_logs"("module", "action");

-- CreateIndex
CREATE INDEX "idx_audit_logs_reference_id" ON "audit_logs"("reference_id");

-- CreateIndex
CREATE INDEX "idx_audit_logs_created_at" ON "audit_logs"("created_at");

-- CreateIndex
CREATE INDEX "idx_media_files_uploaded_by_employee_id" ON "media_files"("uploaded_by_employee_id");

-- CreateIndex
CREATE INDEX "idx_media_files_mime_type" ON "media_files"("mime_type");

-- CreateIndex
CREATE INDEX "idx_media_files_created_at" ON "media_files"("created_at");

-- CreateIndex
CREATE INDEX "idx_media_files_deleted_at" ON "media_files"("deleted_at");

-- AddForeignKey
ALTER TABLE "employee_roles" ADD CONSTRAINT "employee_roles_employee_id_fkey" FOREIGN KEY ("employee_id") REFERENCES "employees"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "employee_roles" ADD CONSTRAINT "employee_roles_role_id_fkey" FOREIGN KEY ("role_id") REFERENCES "roles"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "employee_roles" ADD CONSTRAINT "employee_roles_assigned_by_employee_id_fkey" FOREIGN KEY ("assigned_by_employee_id") REFERENCES "employees"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "role_permissions" ADD CONSTRAINT "role_permissions_role_id_fkey" FOREIGN KEY ("role_id") REFERENCES "roles"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "role_permissions" ADD CONSTRAINT "role_permissions_permission_id_fkey" FOREIGN KEY ("permission_id") REFERENCES "permissions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "employee_sessions" ADD CONSTRAINT "employee_sessions_employee_id_fkey" FOREIGN KEY ("employee_id") REFERENCES "employees"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "otp_codes" ADD CONSTRAINT "otp_codes_employee_id_fkey" FOREIGN KEY ("employee_id") REFERENCES "employees"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "customers" ADD CONSTRAINT "customers_default_address_id_fkey" FOREIGN KEY ("default_address_id") REFERENCES "customer_addresses"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "customer_addresses" ADD CONSTRAINT "customer_addresses_customer_id_fkey" FOREIGN KEY ("customer_id") REFERENCES "customers"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "customer_wallets" ADD CONSTRAINT "customer_wallets_customer_id_fkey" FOREIGN KEY ("customer_id") REFERENCES "customers"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "wallet_transactions" ADD CONSTRAINT "wallet_transactions_customer_id_fkey" FOREIGN KEY ("customer_id") REFERENCES "customers"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "wallet_transactions" ADD CONSTRAINT "wallet_transactions_wallet_id_fkey" FOREIGN KEY ("wallet_id") REFERENCES "customer_wallets"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "wallet_transactions" ADD CONSTRAINT "wallet_transactions_created_by_employee_id_fkey" FOREIGN KEY ("created_by_employee_id") REFERENCES "employees"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reward_points" ADD CONSTRAINT "reward_points_customer_id_fkey" FOREIGN KEY ("customer_id") REFERENCES "customers"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "customer_notes" ADD CONSTRAINT "customer_notes_customer_id_fkey" FOREIGN KEY ("customer_id") REFERENCES "customers"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "customer_notes" ADD CONSTRAINT "customer_notes_employee_id_fkey" FOREIGN KEY ("employee_id") REFERENCES "employees"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "customer_devices" ADD CONSTRAINT "customer_devices_customer_id_fkey" FOREIGN KEY ("customer_id") REFERENCES "customers"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "services" ADD CONSTRAINT "services_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "service_categories"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "service_prices" ADD CONSTRAINT "service_prices_service_id_fkey" FOREIGN KEY ("service_id") REFERENCES "services"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "orders" ADD CONSTRAINT "orders_customer_id_fkey" FOREIGN KEY ("customer_id") REFERENCES "customers"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "orders" ADD CONSTRAINT "orders_pickup_address_id_fkey" FOREIGN KEY ("pickup_address_id") REFERENCES "customer_addresses"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "orders" ADD CONSTRAINT "orders_delivery_address_id_fkey" FOREIGN KEY ("delivery_address_id") REFERENCES "customer_addresses"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "orders" ADD CONSTRAINT "orders_created_by_employee_id_fkey" FOREIGN KEY ("created_by_employee_id") REFERENCES "employees"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "orders" ADD CONSTRAINT "orders_updated_by_employee_id_fkey" FOREIGN KEY ("updated_by_employee_id") REFERENCES "employees"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_items" ADD CONSTRAINT "order_items_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "orders"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_items" ADD CONSTRAINT "order_items_service_id_fkey" FOREIGN KEY ("service_id") REFERENCES "services"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_items" ADD CONSTRAINT "order_items_service_price_id_fkey" FOREIGN KEY ("service_price_id") REFERENCES "service_prices"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_status_histories" ADD CONSTRAINT "order_status_histories_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "orders"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_status_histories" ADD CONSTRAINT "order_status_histories_changed_by_employee_id_fkey" FOREIGN KEY ("changed_by_employee_id") REFERENCES "employees"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_photos" ADD CONSTRAINT "order_photos_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "orders"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_photos" ADD CONSTRAINT "order_photos_uploaded_by_employee_id_fkey" FOREIGN KEY ("uploaded_by_employee_id") REFERENCES "employees"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_timelines" ADD CONSTRAINT "order_timelines_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "orders"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_timelines" ADD CONSTRAINT "order_timelines_employee_id_fkey" FOREIGN KEY ("employee_id") REFERENCES "employees"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payments" ADD CONSTRAINT "payments_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "orders"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payments" ADD CONSTRAINT "payments_payment_method_id_fkey" FOREIGN KEY ("payment_method_id") REFERENCES "payment_methods"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payments" ADD CONSTRAINT "payments_received_by_employee_id_fkey" FOREIGN KEY ("received_by_employee_id") REFERENCES "employees"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "expenses" ADD CONSTRAINT "expenses_expense_category_id_fkey" FOREIGN KEY ("expense_category_id") REFERENCES "expense_categories"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "expenses" ADD CONSTRAINT "expenses_employee_id_fkey" FOREIGN KEY ("employee_id") REFERENCES "employees"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "cashflows" ADD CONSTRAINT "cashflows_created_by_employee_id_fkey" FOREIGN KEY ("created_by_employee_id") REFERENCES "employees"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "attendances" ADD CONSTRAINT "attendances_employee_id_fkey" FOREIGN KEY ("employee_id") REFERENCES "employees"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "attendance_logs" ADD CONSTRAINT "attendance_logs_attendance_id_fkey" FOREIGN KEY ("attendance_id") REFERENCES "attendances"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "attendance_logs" ADD CONSTRAINT "attendance_logs_employee_id_fkey" FOREIGN KEY ("employee_id") REFERENCES "employees"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ironing_jobs" ADD CONSTRAINT "ironing_jobs_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "orders"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ironing_jobs" ADD CONSTRAINT "ironing_jobs_employee_id_fkey" FOREIGN KEY ("employee_id") REFERENCES "employees"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ironing_contributions" ADD CONSTRAINT "ironing_contributions_ironing_job_id_fkey" FOREIGN KEY ("ironing_job_id") REFERENCES "ironing_jobs"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ironing_contributions" ADD CONSTRAINT "ironing_contributions_employee_id_fkey" FOREIGN KEY ("employee_id") REFERENCES "employees"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "pickup_jobs" ADD CONSTRAINT "pickup_jobs_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "orders"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "pickup_jobs" ADD CONSTRAINT "pickup_jobs_driver_id_fkey" FOREIGN KEY ("driver_id") REFERENCES "employees"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "pickup_jobs" ADD CONSTRAINT "pickup_jobs_pickup_address_id_fkey" FOREIGN KEY ("pickup_address_id") REFERENCES "customer_addresses"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "delivery_jobs" ADD CONSTRAINT "delivery_jobs_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "orders"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "delivery_jobs" ADD CONSTRAINT "delivery_jobs_driver_id_fkey" FOREIGN KEY ("driver_id") REFERENCES "employees"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "delivery_jobs" ADD CONSTRAINT "delivery_jobs_delivery_address_id_fkey" FOREIGN KEY ("delivery_address_id") REFERENCES "customer_addresses"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "driver_activities" ADD CONSTRAINT "driver_activities_driver_id_fkey" FOREIGN KEY ("driver_id") REFERENCES "employees"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "driver_activities" ADD CONSTRAINT "driver_activities_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "orders"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "notifications" ADD CONSTRAINT "notifications_sender_employee_id_fkey" FOREIGN KEY ("sender_employee_id") REFERENCES "employees"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "notification_reads" ADD CONSTRAINT "notification_reads_notification_id_fkey" FOREIGN KEY ("notification_id") REFERENCES "notifications"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "notification_reads" ADD CONSTRAINT "notification_reads_employee_id_fkey" FOREIGN KEY ("employee_id") REFERENCES "employees"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "customer_service_tickets" ADD CONSTRAINT "customer_service_tickets_customer_id_fkey" FOREIGN KEY ("customer_id") REFERENCES "customers"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "customer_service_tickets" ADD CONSTRAINT "customer_service_tickets_employee_id_fkey" FOREIGN KEY ("employee_id") REFERENCES "employees"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "customer_service_messages" ADD CONSTRAINT "customer_service_messages_ticket_id_fkey" FOREIGN KEY ("ticket_id") REFERENCES "customer_service_tickets"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "customer_service_messages" ADD CONSTRAINT "customer_service_messages_employee_id_fkey" FOREIGN KEY ("employee_id") REFERENCES "employees"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "customer_service_messages" ADD CONSTRAINT "customer_service_messages_customer_id_fkey" FOREIGN KEY ("customer_id") REFERENCES "customers"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "customer_service_attachments" ADD CONSTRAINT "customer_service_attachments_message_id_fkey" FOREIGN KEY ("message_id") REFERENCES "customer_service_messages"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "audit_logs" ADD CONSTRAINT "audit_logs_employee_id_fkey" FOREIGN KEY ("employee_id") REFERENCES "employees"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "media_files" ADD CONSTRAINT "media_files_uploaded_by_employee_id_fkey" FOREIGN KEY ("uploaded_by_employee_id") REFERENCES "employees"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
