-- CreateTable
CREATE TABLE "numbering_sequences" (
    "id" UUID NOT NULL,
    "type" VARCHAR(10) NOT NULL,
    "prefix" VARCHAR(20) NOT NULL,
    "current_counter" INTEGER NOT NULL DEFAULT 0,
    "padding" INTEGER NOT NULL DEFAULT 6,
    "daily_reset" BOOLEAN NOT NULL DEFAULT true,
    "last_reset_date" DATE,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "numbering_sequences_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "numbering_sequences_type_key" ON "numbering_sequences"("type");
