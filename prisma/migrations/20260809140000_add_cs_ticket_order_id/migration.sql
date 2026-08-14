-- Link customer service tickets to a specific laundry order.
ALTER TABLE "customer_service_tickets" ADD COLUMN "order_id" UUID;

ALTER TABLE "customer_service_tickets"
  ADD CONSTRAINT "customer_service_tickets_order_id_fkey"
  FOREIGN KEY ("order_id") REFERENCES "orders"("id")
  ON DELETE SET NULL ON UPDATE CASCADE;

CREATE INDEX "idx_customer_service_tickets_order_id"
  ON "customer_service_tickets"("order_id");
