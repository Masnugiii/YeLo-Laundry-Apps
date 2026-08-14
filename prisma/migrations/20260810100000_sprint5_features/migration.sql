-- AlterEnum
ALTER TYPE "reward_point_source" ADD VALUE IF NOT EXISTS 'mission';

-- CreateEnum
CREATE TYPE "mission_type" AS ENUM ('quiz', 'link_account', 'refer_friend');

-- CreateEnum
CREATE TYPE "wallet_top_up_request_status" AS ENUM ('pending', 'completed', 'failed', 'cancelled');

-- CreateTable
CREATE TABLE "laundry_perfumes" (
    "id" UUID NOT NULL,
    "code" VARCHAR(50) NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "extra_price" DECIMAL(15,2) NOT NULL DEFAULT 0,
    "display_order" INTEGER NOT NULL DEFAULT 0,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "laundry_perfumes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "loyalty_missions" (
    "id" UUID NOT NULL,
    "code" VARCHAR(50) NOT NULL,
    "type" "mission_type" NOT NULL,
    "title" VARCHAR(150) NOT NULL,
    "description" TEXT,
    "reward_points" INTEGER NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "sort_order" INTEGER NOT NULL DEFAULT 0,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "loyalty_missions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "customer_mission_claims" (
    "id" UUID NOT NULL,
    "customer_id" UUID NOT NULL,
    "mission_id" UUID NOT NULL,
    "claimed_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "customer_mission_claims_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "wallet_top_up_requests" (
    "id" UUID NOT NULL,
    "customer_id" UUID NOT NULL,
    "amount" DECIMAL(15,2) NOT NULL,
    "payment_method" VARCHAR(30) NOT NULL,
    "status" "wallet_top_up_request_status" NOT NULL DEFAULT 'pending',
    "reference_number" VARCHAR(50) NOT NULL,
    "wallet_txn_id" UUID,
    "completed_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "wallet_top_up_requests_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "laundry_perfumes_code_key" ON "laundry_perfumes"("code");

-- CreateIndex
CREATE INDEX "idx_laundry_perfumes_is_active" ON "laundry_perfumes"("is_active");

-- CreateIndex
CREATE INDEX "idx_laundry_perfumes_deleted_at" ON "laundry_perfumes"("deleted_at");

-- CreateIndex
CREATE UNIQUE INDEX "loyalty_missions_code_key" ON "loyalty_missions"("code");

-- CreateIndex
CREATE INDEX "idx_loyalty_missions_is_active" ON "loyalty_missions"("is_active");

-- CreateIndex
CREATE INDEX "idx_loyalty_missions_deleted_at" ON "loyalty_missions"("deleted_at");

-- CreateIndex
CREATE INDEX "idx_customer_mission_claims_customer_id" ON "customer_mission_claims"("customer_id");

-- CreateIndex
CREATE UNIQUE INDEX "idx_customer_mission_claims_unique" ON "customer_mission_claims"("customer_id", "mission_id");

-- CreateIndex
CREATE UNIQUE INDEX "wallet_top_up_requests_reference_number_key" ON "wallet_top_up_requests"("reference_number");

-- CreateIndex
CREATE UNIQUE INDEX "wallet_top_up_requests_wallet_txn_id_key" ON "wallet_top_up_requests"("wallet_txn_id");

-- CreateIndex
CREATE INDEX "idx_wallet_top_up_requests_customer_id" ON "wallet_top_up_requests"("customer_id");

-- CreateIndex
CREATE INDEX "idx_wallet_top_up_requests_status" ON "wallet_top_up_requests"("status");

-- AddForeignKey
ALTER TABLE "customer_mission_claims" ADD CONSTRAINT "customer_mission_claims_customer_id_fkey" FOREIGN KEY ("customer_id") REFERENCES "customers"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "customer_mission_claims" ADD CONSTRAINT "customer_mission_claims_mission_id_fkey" FOREIGN KEY ("mission_id") REFERENCES "loyalty_missions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "wallet_top_up_requests" ADD CONSTRAINT "wallet_top_up_requests_customer_id_fkey" FOREIGN KEY ("customer_id") REFERENCES "customers"("id") ON DELETE CASCADE ON UPDATE CASCADE;
