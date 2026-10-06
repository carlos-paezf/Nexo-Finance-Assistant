CREATE TYPE "GroupMode" AS ENUM ('PAREJA', 'FAMILIA');

CREATE TABLE "Group" (
  "id" UUID NOT NULL,
  "type" "GroupMode" NOT NULL,
  "revision" BIGINT NOT NULL DEFAULT 0,
  CONSTRAINT "Group_pkey" PRIMARY KEY ("id"),
  CONSTRAINT "Group_revision_check" CHECK ("revision" BETWEEN 0 AND 9007199254740991)
);

CREATE TABLE "GroupMembership" (
  "groupId" UUID NOT NULL,
  "userId" UUID NOT NULL,
  "active" BOOLEAN NOT NULL DEFAULT TRUE,
  "canChangeMode" BOOLEAN NOT NULL DEFAULT FALSE,
  CONSTRAINT "GroupMembership_pkey" PRIMARY KEY ("groupId", "userId"),
  CONSTRAINT "GroupMembership_groupId_fkey" FOREIGN KEY ("groupId") REFERENCES "Group"("id") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE "GroupModeOperation" (
  "groupId" UUID NOT NULL,
  "actorId" UUID NOT NULL,
  "operationKey" VARCHAR(80) NOT NULL,
  "requestHash" CHAR(64) NOT NULL,
  "result" JSONB NOT NULL,
  CONSTRAINT "GroupModeOperation_pkey" PRIMARY KEY ("groupId", "actorId", "operationKey"),
  CONSTRAINT "GroupModeOperation_groupId_fkey" FOREIGN KEY ("groupId") REFERENCES "Group"("id") ON DELETE CASCADE ON UPDATE CASCADE
);
