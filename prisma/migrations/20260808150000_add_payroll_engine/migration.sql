-- CreateEnum
CREATE TYPE "payroll_record_status" AS ENUM ('DRAFT', 'CALCULATED', 'APPROVED', 'PAID');
CREATE TYPE "payroll_bonus_type" AS ENUM ('ATTENDANCE', 'PERFORMANCE', 'HOLIDAY', 'MANUAL');
CREATE TYPE "payroll_deduction_type" AS ENUM ('ADVANCE', 'PENALTY', 'LOAN', 'OTHER');
CREATE TYPE "payroll_payment_method" AS ENUM ('CASH', 'TRANSFER', 'WALLET');

-- AlterEnum
ALTER TYPE "reference_type" ADD VALUE IF NOT EXISTS 'PAYROLL';

-- CreateTable
CREATE TABLE "payroll_records" (
    "id" UUID NOT NULL,
    "payroll_number" VARCHAR(50) NOT NULL,
    "employee_id" UUID NOT NULL,
    "period_start" DATE NOT NULL,
    "period_end" DATE NOT NULL,
    "role" VARCHAR(50) NOT NULL,
    "status" "payroll_record_status" NOT NULL DEFAULT 'DRAFT',
    "laundry_kg" DECIMAL(15,2) NOT NULL DEFAULT 0,
    "laundry_piece" DECIMAL(15,2) NOT NULL DEFAULT 0,
    "ironing_kg" DECIMAL(15,2) NOT NULL DEFAULT 0,
    "ironing_piece" DECIMAL(15,2) NOT NULL DEFAULT 0,
    "orders_finished" INTEGER NOT NULL DEFAULT 0,
    "production_salary" DECIMAL(15,2) NOT NULL DEFAULT 0,
    "present_days" INTEGER NOT NULL DEFAULT 0,
    "absent_days" INTEGER NOT NULL DEFAULT 0,
    "late_days" INTEGER NOT NULL DEFAULT 0,
    "leave_days" INTEGER NOT NULL DEFAULT 0,
    "base_salary" DECIMAL(15,2) NOT NULL DEFAULT 0,
    "gross_salary" DECIMAL(15,2) NOT NULL DEFAULT 0,
    "total_bonus" DECIMAL(15,2) NOT NULL DEFAULT 0,
    "total_deduction" DECIMAL(15,2) NOT NULL DEFAULT 0,
    "net_salary" DECIMAL(15,2) NOT NULL DEFAULT 0,
    "calculated_at" TIMESTAMPTZ(6),
    "calculated_by_employee_id" UUID,
    "approved_at" TIMESTAMPTZ(6),
    "approved_by_employee_id" UUID,
    "paid_at" TIMESTAMPTZ(6),
    "paid_by_employee_id" UUID,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "payroll_records_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "payroll_bonuses" (
    "id" UUID NOT NULL,
    "payroll_record_id" UUID NOT NULL,
    "type" "payroll_bonus_type" NOT NULL,
    "amount" DECIMAL(15,2) NOT NULL,
    "notes" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "payroll_bonuses_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "payroll_deductions" (
    "id" UUID NOT NULL,
    "payroll_record_id" UUID NOT NULL,
    "type" "payroll_deduction_type" NOT NULL,
    "amount" DECIMAL(15,2) NOT NULL,
    "notes" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "payroll_deductions_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "payroll_approval_events" (
    "id" UUID NOT NULL,
    "payroll_record_id" UUID NOT NULL,
    "status" "payroll_record_status" NOT NULL,
    "notes" TEXT,
    "actor_employee_id" UUID NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "payroll_approval_events_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "payroll_payments" (
    "id" UUID NOT NULL,
    "payroll_record_id" UUID NOT NULL,
    "method" "payroll_payment_method" NOT NULL,
    "amount" DECIMAL(15,2) NOT NULL,
    "reference_number" VARCHAR(50),
    "notes" TEXT,
    "paid_at" TIMESTAMPTZ(6) NOT NULL,
    "paid_by_employee_id" UUID NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "payroll_payments_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "payroll_records_payroll_number_key" ON "payroll_records"("payroll_number");
CREATE INDEX "idx_payroll_records_employee_id" ON "payroll_records"("employee_id");
CREATE INDEX "idx_payroll_records_period" ON "payroll_records"("period_start", "period_end");
CREATE INDEX "idx_payroll_records_status" ON "payroll_records"("status");
CREATE INDEX "idx_payroll_records_deleted_at" ON "payroll_records"("deleted_at");
CREATE INDEX "idx_payroll_bonuses_payroll_record_id" ON "payroll_bonuses"("payroll_record_id");
CREATE INDEX "idx_payroll_deductions_payroll_record_id" ON "payroll_deductions"("payroll_record_id");
CREATE INDEX "idx_payroll_approval_events_payroll_record_id" ON "payroll_approval_events"("payroll_record_id");
CREATE INDEX "idx_payroll_payments_payroll_record_id" ON "payroll_payments"("payroll_record_id");

ALTER TABLE "payroll_records" ADD CONSTRAINT "payroll_records_employee_id_fkey" FOREIGN KEY ("employee_id") REFERENCES "employees"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "payroll_bonuses" ADD CONSTRAINT "payroll_bonuses_payroll_record_id_fkey" FOREIGN KEY ("payroll_record_id") REFERENCES "payroll_records"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "payroll_deductions" ADD CONSTRAINT "payroll_deductions_payroll_record_id_fkey" FOREIGN KEY ("payroll_record_id") REFERENCES "payroll_records"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "payroll_approval_events" ADD CONSTRAINT "payroll_approval_events_payroll_record_id_fkey" FOREIGN KEY ("payroll_record_id") REFERENCES "payroll_records"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "payroll_approval_events" ADD CONSTRAINT "payroll_approval_events_actor_employee_id_fkey" FOREIGN KEY ("actor_employee_id") REFERENCES "employees"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "payroll_payments" ADD CONSTRAINT "payroll_payments_payroll_record_id_fkey" FOREIGN KEY ("payroll_record_id") REFERENCES "payroll_records"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "payroll_payments" ADD CONSTRAINT "payroll_payments_paid_by_employee_id_fkey" FOREIGN KEY ("paid_by_employee_id") REFERENCES "employees"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
