-- Phase 5: CKS entitlement remaining KG + usage audit trail

CREATE TYPE "reward_entitlement_status" AS ENUM (
  'AVAILABLE',
  'PARTIALLY_USED',
  'USED',
  'EXPIRED',
  'CANCELLED'
);

ALTER TABLE "reward_redemption_items"
  ADD COLUMN "remaining_kg" DECIMAL(10,3),
  ADD COLUMN "entitlement_status" "reward_entitlement_status",
  ADD COLUMN "entitlement_expires_at" TIMESTAMPTZ(6);

CREATE INDEX "idx_reward_redemption_items_entitlement_status"
  ON "reward_redemption_items"("entitlement_status");

CREATE INDEX "idx_reward_redemption_items_entitlement_expires_at"
  ON "reward_redemption_items"("entitlement_expires_at");

-- Backfill existing LAUNDRY_KG entitlement lines from redemption issuance.
UPDATE "reward_redemption_items" AS item
SET
  "remaining_kg" = item."entitlement_kg",
  "entitlement_status" = CASE
    WHEN redemption."status" = 'CANCELLED' THEN 'CANCELLED'::"reward_entitlement_status"
    WHEN item."created_at" + INTERVAL '3 days' <= NOW() THEN 'EXPIRED'::"reward_entitlement_status"
    ELSE 'AVAILABLE'::"reward_entitlement_status"
  END,
  "entitlement_expires_at" = item."created_at" + INTERVAL '3 days'
FROM "reward_redemptions" AS redemption
WHERE item."redemption_id" = redemption."id"
  AND item."entitlement_kg" IS NOT NULL
  AND item."remaining_kg" IS NULL;

CREATE TABLE "reward_entitlement_usages" (
  "id" UUID NOT NULL DEFAULT gen_random_uuid(),
  "redemption_item_id" UUID NOT NULL,
  "order_id" UUID NOT NULL,
  "kg_consumed" DECIMAL(10,3) NOT NULL,
  "free_kg_applied" DECIMAL(10,3) NOT NULL,
  "billable_kg" DECIMAL(10,3) NOT NULL,
  "order_kg" DECIMAL(10,3) NOT NULL,
  "remaining_kg_after" DECIMAL(10,3) NOT NULL,
  "applied_by_employee_id" UUID,
  "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "reward_entitlement_usages_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "idx_reward_entitlement_usages_item_order_unique"
  ON "reward_entitlement_usages"("redemption_item_id", "order_id");

CREATE INDEX "idx_reward_entitlement_usages_redemption_item_id"
  ON "reward_entitlement_usages"("redemption_item_id");

CREATE INDEX "idx_reward_entitlement_usages_order_id"
  ON "reward_entitlement_usages"("order_id");

CREATE INDEX "idx_reward_entitlement_usages_applied_by"
  ON "reward_entitlement_usages"("applied_by_employee_id");

ALTER TABLE "reward_entitlement_usages"
  ADD CONSTRAINT "reward_entitlement_usages_redemption_item_id_fkey"
  FOREIGN KEY ("redemption_item_id") REFERENCES "reward_redemption_items"("id")
  ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "reward_entitlement_usages"
  ADD CONSTRAINT "reward_entitlement_usages_order_id_fkey"
  FOREIGN KEY ("order_id") REFERENCES "orders"("id")
  ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "reward_entitlement_usages"
  ADD CONSTRAINT "reward_entitlement_usages_applied_by_employee_id_fkey"
  FOREIGN KEY ("applied_by_employee_id") REFERENCES "employees"("id")
  ON DELETE SET NULL ON UPDATE CASCADE;
