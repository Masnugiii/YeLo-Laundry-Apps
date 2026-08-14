ALTER TABLE "loyalty_vouchers"
ADD COLUMN IF NOT EXISTS "description" TEXT,
ADD COLUMN IF NOT EXISTS "max_discount" DECIMAL(15, 2);
