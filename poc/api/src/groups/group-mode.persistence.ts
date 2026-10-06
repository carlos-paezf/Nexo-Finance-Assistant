import { createHash } from 'node:crypto';
import { PrismaService } from '../database/prisma.service';
import { Prisma } from '../generated/prisma/client';
import { evaluateGroupModeChange, GroupMode, GroupModeResult } from './group-mode';

export type PersistedGroupModeResult = GroupModeResult | Readonly<{
  ok: false;
  reason: 'INVALID_ID' | 'INVALID_OPERATION_KEY' | 'GROUP_NOT_FOUND' | 'IDEMPOTENCY_CONFLICT';
}>;

export type GroupModeRequest = Readonly<{
  groupId: unknown;
  actorId: unknown;
  operationKey: unknown;
  destination: unknown;
  expectedRevision: unknown;
}>;

const uuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
const maxRevision = BigInt(Number.MAX_SAFE_INTEGER);

function revisionOf(value: unknown): bigint | undefined {
  if (typeof value === 'number') {
    if (!Number.isSafeInteger(value) || value < 0) return undefined;
    return BigInt(value);
  }
  if (typeof value === 'string') {
    if (!/^(0|[1-9][0-9]{0,15})$/.test(value)) return undefined;
    value = BigInt(value);
  }
  return typeof value === 'bigint' && value >= 0n && value <= maxRevision ? value : undefined;
}

class RevisionConflict extends Error {}

// El actor procede del backend autenticado; ningún permiso proviene de la solicitud.
export class GroupModePersistence {
  constructor(private readonly prisma: PrismaService) {}

  async change(request: GroupModeRequest): Promise<PersistedGroupModeResult> {
    if (typeof request.groupId !== 'string' || !uuid.test(request.groupId) ||
        typeof request.actorId !== 'string' || !uuid.test(request.actorId)) {
      return { ok: false, reason: 'INVALID_ID' };
    }
    if (typeof request.operationKey !== 'string' || !/^[A-Za-z0-9][A-Za-z0-9._:-]{0,79}$/.test(request.operationKey)) {
      return { ok: false, reason: 'INVALID_OPERATION_KEY' };
    }
    if (request.destination !== 'PAREJA' && request.destination !== 'FAMILIA') {
      return { ok: false, reason: 'INVALID_DESTINATION' };
    }
    const expectedRevision = revisionOf(request.expectedRevision);
    if (expectedRevision === undefined) return { ok: false, reason: 'INVALID_REVISION' };

    const groupId = request.groupId.toLowerCase();
    const actorId = request.actorId.toLowerCase();
    const operationKey = request.operationKey;
    const destination = request.destination;
    const requestHash = createHash('sha256')
      .update(JSON.stringify([groupId, actorId, destination, expectedRevision.toString()]))
      .digest('hex');

    const transact = (replayOnly: boolean): Promise<PersistedGroupModeResult> => this.prisma.$transaction(async (tx) => {
      // El bloqueo del grupo también impide nuevas membresías por su FK mientras se evalúa.
      const groups = await tx.$queryRaw<{ id: string; type: GroupMode; revision: bigint }[]>`
        SELECT "id", "type", "revision" FROM "Group" WHERE "id" = ${groupId}::uuid FOR UPDATE`;
      const group = groups[0];
      if (!group) return { ok: false, reason: 'GROUP_NOT_FOUND' };
      const members = await tx.$queryRaw<{ userId: string; active: boolean; canChangeMode: boolean }[]>`
        SELECT "userId", "active", "canChangeMode" FROM "GroupMembership"
        WHERE "groupId" = ${groupId}::uuid FOR SHARE`;
      const actor = members.find((member) => member.userId === actorId);
      if (!actor?.active) return { ok: false, reason: 'ACTOR_INACTIVE' };
      if (!actor.canChangeMode) return { ok: false, reason: 'FORBIDDEN' };

      const receipt = await tx.groupModeOperation.findUnique({
        where: { groupId_actorId_operationKey: { groupId, actorId, operationKey } },
      });
      if (receipt) {
        if (receipt.requestHash !== requestHash) return { ok: false, reason: 'IDEMPOTENCY_CONFLICT' };
        return receipt.result as PersistedGroupModeResult;
      }
      if (replayOnly) return { ok: false, reason: 'STALE_REVISION' };
      if (revisionOf(group.revision) === undefined) return { ok: false, reason: 'INVALID_REVISION' };

      const result = evaluateGroupModeChange(
        { ...group, revision: Number(group.revision), members }, destination, Number(expectedRevision),
        { actorId, groupId, actorActive: actor.active, canChangeMode: actor.canChangeMode },
      );
      if (!result.ok) return result;
      if (result.kind === 'patch') {
        const update = await tx.group.updateMany({
          where: { id: groupId, revision: expectedRevision, type: group.type },
          data: { type: result.patch.type, revision: BigInt(result.patch.revision) },
        });
        if (update.count !== 1) throw new RevisionConflict();
      }
      await tx.groupModeOperation.create({
        data: { groupId, actorId, operationKey, requestHash, result },
      });
      return result;
    }, { isolationLevel: Prisma.TransactionIsolationLevel.ReadCommitted });

    try {
      return await transact(false);
    } catch (error) {
      if (error instanceof RevisionConflict ||
          (error instanceof Prisma.PrismaClientKnownRequestError && error.code === 'P2002')) {
        // Una transacción fallida no puede consultar el recibo: se reautoriza en otra nueva.
        return transact(true);
      }
      throw error;
    }
  }
}
