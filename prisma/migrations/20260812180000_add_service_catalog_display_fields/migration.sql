-- Add display order and minimum quantity to laundry services catalog.
ALTER TABLE "services"
  ADD COLUMN IF NOT EXISTS "minimum_quantity" DECIMAL(10, 2) DEFAULT 1,
  ADD COLUMN IF NOT EXISTS "display_order" INTEGER NOT NULL DEFAULT 0;

CREATE INDEX IF NOT EXISTS "idx_services_display_order"
  ON "services" ("display_order");
