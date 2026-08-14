-- CreateEnum
CREATE TYPE "OrderReceiptDeliveryStatus" AS ENUM ('PENDING', 'SENT', 'FAILED', 'NOT_CONFIGURED');

-- CreateTable
CREATE TABLE "order_receipt_deliveries" (
    "id" UUID NOT NULL,
    "order_id" UUID NOT NULL,
    "message_text" TEXT NOT NULL,
    "payment_status_snapshot" "order_payment_status" NOT NULL,
    "payment_method_snapshot" VARCHAR(50),
    "customer_phone" VARCHAR(30),
    "delivery_channel" VARCHAR(20) NOT NULL DEFAULT 'WHATSAPP',
    "delivery_status" "OrderReceiptDeliveryStatus" NOT NULL DEFAULT 'PENDING',
    "failure_reason" TEXT,
    "sent_at" TIMESTAMPTZ(6),
    "created_by_employee_id" UUID NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "order_receipt_deliveries_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "idx_order_receipt_deliveries_order_id" ON "order_receipt_deliveries"("order_id");

-- CreateIndex
CREATE INDEX "idx_order_receipt_deliveries_status" ON "order_receipt_deliveries"("delivery_status");

-- AddForeignKey
ALTER TABLE "order_receipt_deliveries" ADD CONSTRAINT "order_receipt_deliveries_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "orders"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_receipt_deliveries" ADD CONSTRAINT "order_receipt_deliveries_created_by_employee_id_fkey" FOREIGN KEY ("created_by_employee_id") REFERENCES "employees"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
