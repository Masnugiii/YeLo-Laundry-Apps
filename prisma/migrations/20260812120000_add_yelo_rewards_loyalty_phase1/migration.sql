-- YeLo Rewards loyalty Phase 1: schema foundation
-- Safe / non-destructive:
-- - does NOT delete reward_points history
-- - does NOT reset customer balances
-- - does NOT activate a new loyalty program
-- - does NOT seed catalog (Phase 7)

-- ---------------------------------------------------------------------------
-- Enum extensions
-- ---------------------------------------------------------------------------

ALTER TYPE "reward_point_type" ADD VALUE IF NOT EXISTS 'clawback';
ALTER TYPE "reward_point_type" ADD VALUE IF NOT EXISTS 'program_reset';

ALTER TYPE "reward_point_source" ADD VALUE IF NOT EXISTS 'deposit';

CREATE TYPE "reward_catalog_type" AS ENUM ('LAUNDRY_KG', 'PHYSICAL_GOODS');
CREATE TYPE "reward_redemption_status" AS ENUM ('PENDING', 'COMPLETED', 'CANCELLED');

-- ---------------------------------------------------------------------------
-- LoyaltyProgram (cutover boundary; no auto-activation)
-- ---------------------------------------------------------------------------

CREATE TABLE "loyalty_programs" (
    "id" UUID NOT NULL,
    "code" VARCHAR(50) NOT NULL,
    "name" VARCHAR(150) NOT NULL,
    "started_at" TIMESTAMPTZ(6) NOT NULL,
    "ended_at" TIMESTAMPTZ(6),
    "is_active" BOOLEAN NOT NULL DEFAULT false,
    "notes" TEXT,
    "created_by_employee_id" UUID,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "loyalty_programs_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "loyalty_programs_code_key" ON "loyalty_programs"("code");
CREATE INDEX "idx_loyalty_programs_is_active" ON "loyalty_programs"("is_active");
CREATE INDEX "idx_loyalty_programs_started_at" ON "loyalty_programs"("started_at");

ALTER TABLE "loyalty_programs"
  ADD CONSTRAINT "loyalty_programs_created_by_employee_id_fkey"
  FOREIGN KEY ("created_by_employee_id") REFERENCES "employees"("id")
  ON DELETE SET NULL ON UPDATE CASCADE;

-- ---------------------------------------------------------------------------
-- RewardPoint ledger enhancements (retain all existing rows)
-- ---------------------------------------------------------------------------

ALTER TABLE "reward_points"
  ADD COLUMN IF NOT EXISTS "program_id" UUID,
  ADD COLUMN IF NOT EXISTS "remaining_point" INTEGER;

CREATE INDEX IF NOT EXISTS "idx_reward_points_program_id"
  ON "reward_points"("program_id");

CREATE INDEX IF NOT EXISTS "idx_reward_points_remaining_point"
  ON "reward_points"("remaining_point");

CREATE INDEX IF NOT EXISTS "idx_reward_points_reference_lookup"
  ON "reward_points"("customer_id", "type", "source", "reference_type", "reference_id");

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'reward_points_program_id_fkey'
  ) THEN
    ALTER TABLE "reward_points"
      ADD CONSTRAINT "reward_points_program_id_fkey"
      FOREIGN KEY ("program_id") REFERENCES "loyalty_programs"("id")
      ON DELETE SET NULL ON UPDATE CASCADE;
  END IF;
END $$;

-- Backfill remaining usable points for existing earn lots only.
-- Does NOT zero balances and does NOT invent FIFO consumption history.
UPDATE "reward_points"
SET "remaining_point" = "point"
WHERE "type" = 'earn'
  AND "remaining_point" IS NULL;

-- Prevent double-earn for the same customer + source + reference.
-- Partial unique index (Prisma schema cannot express WHERE clause).
CREATE UNIQUE INDEX IF NOT EXISTS "uq_reward_points_active_earn_reference"
  ON "reward_points" ("customer_id", "source", "reference_type", "reference_id")
  WHERE "deleted_at" IS NULL
    AND "type" = 'earn'
    AND "reference_id" IS NOT NULL;

-- ---------------------------------------------------------------------------
-- FIFO allocation links (earn lot <-> consume ledger row)
-- ---------------------------------------------------------------------------

CREATE TABLE "reward_point_allocations" (
    "id" UUID NOT NULL,
    "earn_point_id" UUID NOT NULL,
    "consume_point_id" UUID NOT NULL,
    "points" INTEGER NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "reward_point_allocations_pkey" PRIMARY KEY ("id")
);

CREATE INDEX "idx_reward_point_allocations_earn_point_id"
  ON "reward_point_allocations"("earn_point_id");

CREATE INDEX "idx_reward_point_allocations_consume_point_id"
  ON "reward_point_allocations"("consume_point_id");

ALTER TABLE "reward_point_allocations"
  ADD CONSTRAINT "reward_point_allocations_earn_point_id_fkey"
  FOREIGN KEY ("earn_point_id") REFERENCES "reward_points"("id")
  ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "reward_point_allocations"
  ADD CONSTRAINT "reward_point_allocations_consume_point_id_fkey"
  FOREIGN KEY ("consume_point_id") REFERENCES "reward_points"("id")
  ON DELETE RESTRICT ON UPDATE CASCADE;

-- ---------------------------------------------------------------------------
-- Reward catalog
-- ---------------------------------------------------------------------------

CREATE TABLE "reward_catalog_items" (
    "id" UUID NOT NULL,
    "code" VARCHAR(50) NOT NULL,
    "name" VARCHAR(150) NOT NULL,
    "description" TEXT,
    "type" "reward_catalog_type" NOT NULL,
    "cost_points" INTEGER NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "kg" INTEGER,
    "service_type" VARCHAR(50),
    "service_duration_days" INTEGER,
    "stock" INTEGER,
    "metadata" JSONB,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "reward_catalog_items_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "reward_catalog_items_code_key" ON "reward_catalog_items"("code");
CREATE INDEX "idx_reward_catalog_items_type" ON "reward_catalog_items"("type");
CREATE INDEX "idx_reward_catalog_items_is_active" ON "reward_catalog_items"("is_active");
CREATE INDEX "idx_reward_catalog_items_deleted_at" ON "reward_catalog_items"("deleted_at");

-- ---------------------------------------------------------------------------
-- Redemptions
-- ---------------------------------------------------------------------------

CREATE TABLE "reward_redemptions" (
    "id" UUID NOT NULL,
    "customer_id" UUID NOT NULL,
    "program_id" UUID,
    "status" "reward_redemption_status" NOT NULL DEFAULT 'PENDING',
    "total_points_spent" INTEGER NOT NULL,
    "notes" TEXT,
    "fulfilled_by_employee_id" UUID,
    "fulfilled_at" TIMESTAMPTZ(6),
    "ledger_point_id" UUID,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "reward_redemptions_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "reward_redemptions_ledger_point_id_key"
  ON "reward_redemptions"("ledger_point_id");

CREATE INDEX "idx_reward_redemptions_customer_id" ON "reward_redemptions"("customer_id");
CREATE INDEX "idx_reward_redemptions_program_id" ON "reward_redemptions"("program_id");
CREATE INDEX "idx_reward_redemptions_status" ON "reward_redemptions"("status");
CREATE INDEX "idx_reward_redemptions_created_at" ON "reward_redemptions"("created_at");
CREATE INDEX "idx_reward_redemptions_deleted_at" ON "reward_redemptions"("deleted_at");

ALTER TABLE "reward_redemptions"
  ADD CONSTRAINT "reward_redemptions_customer_id_fkey"
  FOREIGN KEY ("customer_id") REFERENCES "customers"("id")
  ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "reward_redemptions"
  ADD CONSTRAINT "reward_redemptions_program_id_fkey"
  FOREIGN KEY ("program_id") REFERENCES "loyalty_programs"("id")
  ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE "reward_redemptions"
  ADD CONSTRAINT "reward_redemptions_fulfilled_by_employee_id_fkey"
  FOREIGN KEY ("fulfilled_by_employee_id") REFERENCES "employees"("id")
  ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE "reward_redemptions"
  ADD CONSTRAINT "reward_redemptions_ledger_point_id_fkey"
  FOREIGN KEY ("ledger_point_id") REFERENCES "reward_points"("id")
  ON DELETE SET NULL ON UPDATE CASCADE;

CREATE TABLE "reward_redemption_items" (
    "id" UUID NOT NULL,
    "redemption_id" UUID NOT NULL,
    "catalog_item_id" UUID NOT NULL,
    "quantity" INTEGER NOT NULL DEFAULT 1,
    "points_spent" INTEGER NOT NULL,
    "entitlement_kg" INTEGER,
    "metadata" JSONB,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "reward_redemption_items_pkey" PRIMARY KEY ("id")
);

CREATE INDEX "idx_reward_redemption_items_redemption_id"
  ON "reward_redemption_items"("redemption_id");

CREATE INDEX "idx_reward_redemption_items_catalog_item_id"
  ON "reward_redemption_items"("catalog_item_id");

ALTER TABLE "reward_redemption_items"
  ADD CONSTRAINT "reward_redemption_items_redemption_id_fkey"
  FOREIGN KEY ("redemption_id") REFERENCES "reward_redemptions"("id")
  ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "reward_redemption_items"
  ADD CONSTRAINT "reward_redemption_items_catalog_item_id_fkey"
  FOREIGN KEY ("catalog_item_id") REFERENCES "reward_catalog_items"("id")
  ON DELETE RESTRICT ON UPDATE CASCADE;
