CREATE TYPE "MovementType" AS ENUM ('INCOME', 'EXPENSE');

CREATE TABLE "Account" (
  "id" VARCHAR(80) NOT NULL,
  "name" VARCHAR(80) NOT NULL,
  "openingCents" BIGINT NOT NULL,
  "requestHash" CHAR(64) NOT NULL,
  "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "Account_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "Movement" (
  "id" VARCHAR(80) NOT NULL,
  "accountId" VARCHAR(80) NOT NULL,
  "type" "MovementType" NOT NULL,
  "description" VARCHAR(200) NOT NULL,
  "amountCents" BIGINT NOT NULL,
  "occurredAt" TIMESTAMPTZ(3) NOT NULL,
  "requestHash" CHAR(64) NOT NULL,
  "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "Movement_pkey" PRIMARY KEY ("id"),
  CONSTRAINT "Movement_accountId_fkey" FOREIGN KEY ("accountId") REFERENCES "Account"("id") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX "Movement_accountId_occurredAt_idx" ON "Movement"("accountId", "occurredAt");
