-- CreateEnum
CREATE TYPE "storage_assignment_action" AS ENUM ('ASSIGNED', 'MOVED', 'RELEASED');

-- CreateTable
CREATE TABLE "storage_lockers" (
    "id" UUID NOT NULL,
    "code" VARCHAR(10) NOT NULL,
    "name" VARCHAR(50) NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "storage_lockers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "storage_boxes" (
    "id" UUID NOT NULL,
    "locker_id" UUID NOT NULL,
    "box_number" INTEGER NOT NULL,
    "code" VARCHAR(10) NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "current_order_id" UUID,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "storage_boxes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "order_storage_assignments" (
    "id" UUID NOT NULL,
    "order_id" UUID NOT NULL,
    "storage_box_id" UUID NOT NULL,
    "previous_storage_box_id" UUID,
    "action" "storage_assignment_action" NOT NULL,
    "assigned_by_employee_id" UUID,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "order_storage_assignments_pkey" PRIMARY KEY ("id")
);

-- AlterTable
ALTER TABLE "orders" ADD COLUMN "storage_box_id" UUID,
ADD COLUMN "last_storage_box_id" UUID,
ADD COLUMN "storage_assigned_at" TIMESTAMPTZ(6),
ADD COLUMN "storage_assigned_by_employee_id" UUID;

-- CreateIndex
CREATE UNIQUE INDEX "storage_lockers_code_key" ON "storage_lockers"("code");

-- CreateIndex
CREATE UNIQUE INDEX "storage_boxes_code_key" ON "storage_boxes"("code");

-- CreateIndex
CREATE UNIQUE INDEX "storage_boxes_current_order_id_key" ON "storage_boxes"("current_order_id");

-- CreateIndex
CREATE UNIQUE INDEX "idx_storage_boxes_locker_box_number" ON "storage_boxes"("locker_id", "box_number");

-- CreateIndex
CREATE INDEX "idx_storage_boxes_locker_id" ON "storage_boxes"("locker_id");

-- CreateIndex
CREATE INDEX "idx_storage_boxes_current_order_id" ON "storage_boxes"("current_order_id");

-- CreateIndex
CREATE UNIQUE INDEX "orders_storage_box_id_key" ON "orders"("storage_box_id");

-- CreateIndex
CREATE INDEX "idx_orders_storage_box_id" ON "orders"("storage_box_id");

-- CreateIndex
CREATE INDEX "idx_order_storage_assignments_order_id" ON "order_storage_assignments"("order_id");

-- CreateIndex
CREATE INDEX "idx_order_storage_assignments_storage_box_id" ON "order_storage_assignments"("storage_box_id");

-- CreateIndex
CREATE INDEX "idx_order_storage_assignments_created_at" ON "order_storage_assignments"("created_at");

-- AddForeignKey
ALTER TABLE "storage_boxes" ADD CONSTRAINT "storage_boxes_locker_id_fkey" FOREIGN KEY ("locker_id") REFERENCES "storage_lockers"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "storage_boxes" ADD CONSTRAINT "storage_boxes_current_order_id_fkey" FOREIGN KEY ("current_order_id") REFERENCES "orders"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_storage_assignments" ADD CONSTRAINT "order_storage_assignments_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "orders"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_storage_assignments" ADD CONSTRAINT "order_storage_assignments_storage_box_id_fkey" FOREIGN KEY ("storage_box_id") REFERENCES "storage_boxes"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_storage_assignments" ADD CONSTRAINT "order_storage_assignments_assigned_by_employee_id_fkey" FOREIGN KEY ("assigned_by_employee_id") REFERENCES "employees"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "orders" ADD CONSTRAINT "orders_storage_box_id_fkey" FOREIGN KEY ("storage_box_id") REFERENCES "storage_boxes"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "orders" ADD CONSTRAINT "orders_last_storage_box_id_fkey" FOREIGN KEY ("last_storage_box_id") REFERENCES "storage_boxes"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "orders" ADD CONSTRAINT "orders_storage_assigned_by_employee_id_fkey" FOREIGN KEY ("storage_assigned_by_employee_id") REFERENCES "employees"("id") ON DELETE SET NULL ON UPDATE CASCADE;
