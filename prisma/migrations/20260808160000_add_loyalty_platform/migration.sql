-- Sprint 29: Customer Loyalty Platform

ALTER TYPE "wallet_transaction_type" ADD VALUE IF NOT EXISTS 'promotion';
ALTER TYPE "wallet_transaction_type" ADD VALUE IF NOT EXISTS 'manual_credit';
ALTER TYPE "wallet_transaction_type" ADD VALUE IF NOT EXISTS 'manual_debit';

CREATE TYPE "reward_point_source" AS ENUM (
  'laundry_payment',
  'promotion',
  'birthday',
  'referral',
  'manual_bonus',
  'redeem',
  'voucher',
  'wallet_credit'
);

CREATE TYPE "loyalty_voucher_discount_type" AS ENUM ('PERCENTAGE', 'FIXED');
CREATE TYPE "loyalty_voucher_status" AS ENUM ('ACTIVE', 'INACTIVE', 'EXPIRED');
CREATE TYPE "cashback_type" AS ENUM ('PERCENTAGE', 'FIXED');

ALTER TABLE "wallet_transactions"
  ADD COLUMN IF NOT EXISTS "balance_after" DECIMAL(15, 2),
  ADD COLUMN IF NOT EXISTS "reference_type" VARCHAR(50),
  ADD COLUMN IF NOT EXISTS "reference_id" UUID,
  ADD COLUMN IF NOT EXISTS "reversed_transaction_id" UUID;

CREATE UNIQUE INDEX IF NOT EXISTS "wallet_transactions_reversed_transaction_id_key"
  ON "wallet_transactions" ("reversed_transaction_id");

CREATE INDEX IF NOT EXISTS "idx_wallet_transactions_reference_id"
  ON "wallet_transactions" ("reference_id");

ALTER TABLE "reward_points"
  ADD COLUMN IF NOT EXISTS "source" "reward_point_source",
  ADD COLUMN IF NOT EXISTS "reference_type" VARCHAR(50),
  ADD COLUMN IF NOT EXISTS "reference_id" UUID,
  ADD COLUMN IF NOT EXISTS "balance_after" INTEGER,
  ADD COLUMN IF NOT EXISTS "created_by_employee_id" UUID;

CREATE INDEX IF NOT EXISTS "idx_reward_points_source"
  ON "reward_points" ("source");

CREATE INDEX IF NOT EXISTS "idx_reward_points_reference_id"
  ON "reward_points" ("reference_id");

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'reward_points_created_by_employee_id_fkey'
  ) THEN
    ALTER TABLE "reward_points"
      ADD CONSTRAINT "reward_points_created_by_employee_id_fkey"
      FOREIGN KEY ("created_by_employee_id") REFERENCES "employees"("id")
      ON DELETE SET NULL ON UPDATE CASCADE;
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'wallet_transactions_reversed_transaction_id_fkey'
  ) THEN
    ALTER TABLE "wallet_transactions"
      ADD CONSTRAINT "wallet_transactions_reversed_transaction_id_fkey"
      FOREIGN KEY ("reversed_transaction_id") REFERENCES "wallet_transactions"("id")
      ON DELETE SET NULL ON UPDATE CASCADE;
  END IF;
END $$;

CREATE TABLE IF NOT EXISTS "loyalty_vouchers" (
  "id" UUID NOT NULL,
  "code" VARCHAR(50) NOT NULL,
  "name" VARCHAR(150) NOT NULL,
  "discount_type" "loyalty_voucher_discount_type" NOT NULL,
  "discount_value" DECIMAL(15, 2) NOT NULL,
  "cashback_type" "cashback_type",
  "cashback_value" DECIMAL(15, 2),
  "cashback_max" DECIMAL(15, 2),
  "cashback_expiration_days" INTEGER,
  "start_date" TIMESTAMPTZ(6) NOT NULL,
  "end_date" TIMESTAMPTZ(6) NOT NULL,
  "usage_limit" INTEGER NOT NULL DEFAULT 0,
  "usage_count" INTEGER NOT NULL DEFAULT 0,
  "minimum_transaction" DECIMAL(15, 2) NOT NULL DEFAULT 0,
  "status" "loyalty_voucher_status" NOT NULL DEFAULT 'ACTIVE',
  "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TIMESTAMPTZ(6) NOT NULL,
  "deleted_at" TIMESTAMPTZ(6),
  CONSTRAINT "loyalty_vouchers_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX IF NOT EXISTS "loyalty_vouchers_code_key" ON "loyalty_vouchers" ("code");
CREATE INDEX IF NOT EXISTS "idx_loyalty_vouchers_status" ON "loyalty_vouchers" ("status");
CREATE INDEX IF NOT EXISTS "idx_loyalty_vouchers_period" ON "loyalty_vouchers" ("start_date", "end_date");
CREATE INDEX IF NOT EXISTS "idx_loyalty_vouchers_deleted_at" ON "loyalty_vouchers" ("deleted_at");

INSERT INTO "permissions" ("id", "code", "name", "module", "description", "is_active", "created_at", "updated_at")
SELECT gen_random_uuid(), 'loyalty', 'Loyalty', 'loyalty', 'Manage customer loyalty, wallet, rewards, and vouchers', true, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM "permissions" WHERE "code" = 'loyalty');

INSERT INTO "role_permissions" ("id", "role_id", "permission_id", "created_at", "updated_at")
SELECT gen_random_uuid(), r.id, p.id, NOW(), NOW()
FROM "roles" r
CROSS JOIN "permissions" p
WHERE r.code IN ('owner', 'cashier', 'cashier_laundry_driver')
  AND p.code = 'loyalty'
  AND NOT EXISTS (
    SELECT 1 FROM "role_permissions" rp
    WHERE rp.role_id = r.id AND rp.permission_id = p.id
  );
