-- Phase 2: idempotent clawback uniqueness (non-destructive)

CREATE UNIQUE INDEX IF NOT EXISTS "uq_reward_points_active_clawback_reference"
  ON "reward_points" ("customer_id", "source", "reference_type", "reference_id")
  WHERE "deleted_at" IS NULL
    AND "type" = 'clawback'
    AND "reference_id" IS NOT NULL;
