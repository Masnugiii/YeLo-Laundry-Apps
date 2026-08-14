-- Phase 3: redeem idempotency key (non-destructive)

ALTER TABLE "reward_redemptions"
  ADD COLUMN IF NOT EXISTS "idempotency_key" VARCHAR(100);

CREATE INDEX IF NOT EXISTS "idx_reward_redemptions_customer_idempotency_key"
  ON "reward_redemptions" ("customer_id", "idempotency_key");

-- Unique per customer when key is present. Multiple NULL keys remain allowed.
CREATE UNIQUE INDEX IF NOT EXISTS "uq_reward_redemptions_customer_idempotency_key"
  ON "reward_redemptions" ("customer_id", "idempotency_key")
  WHERE "idempotency_key" IS NOT NULL
    AND "deleted_at" IS NULL;
