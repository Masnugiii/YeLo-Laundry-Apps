-- Multi-order storage: one box can hold many orders; remove 1:1 constraints.

-- DropStorageBoxCurrentOrder
ALTER TABLE "storage_boxes" DROP CONSTRAINT IF EXISTS "storage_boxes_current_order_id_fkey";

-- DropIndex
DROP INDEX IF EXISTS "storage_boxes_current_order_id_key";
DROP INDEX IF EXISTS "idx_storage_boxes_current_order_id";
DROP INDEX IF EXISTS "orders_storage_box_id_key";

-- AlterTable
ALTER TABLE "storage_boxes" DROP COLUMN IF EXISTS "current_order_id";
