import 'dotenv/config';
import assert from 'node:assert/strict';
import { randomUUID } from 'node:crypto';
import { test } from 'node:test';
import { PrismaService } from '../src/database/prisma.service';
import { GroupMode } from '../src/groups/group-mode';
import { GroupModePersistence, GroupModeRequest } from '../src/groups/group-mode.persistence';

test('PostgreSQL: cambio de modo autorizado, atómico e idempotente', {
  skip: !process.env.DATABASE_URL && 'Configura DATABASE_URL para ejecutar la integración PostgreSQL.',
  timeout: 60_000,
}, async (t) => {
  const prisma = new PrismaService();
  const service = new GroupModePersistence(prisma);
  const fixtureIds: string[] = [];
  await prisma.onModuleInit();

  async function fixture(type: GroupMode = 'PAREJA', activeMembers = 2, revision = 4n) {
    const groupId = randomUUID();
    const actorId = randomUUID();
    await prisma.group.create({
      data: {
        id: groupId, type, revision,
        memberships: {
          create: Array.from({ length: activeMembers }, (_, index) => ({
            userId: index === 0 ? actorId : randomUUID(), active: true, canChangeMode: index === 0,
          })),
        },
      },
    });
    fixtureIds.push(groupId);
    return { groupId, actorId, operationKey: randomUUID(), destination: 'FAMILIA' as GroupMode, expectedRevision: revision };
  }

  async function snapshot(groupId: string) {
    return prisma.group.findUniqueOrThrow({
      where: { id: groupId },
      include: { memberships: { orderBy: { userId: 'asc' } }, operations: { orderBy: { operationKey: 'asc' } } },
    });
  }

  async function rejectWithoutMutation(request: GroupModeRequest, reason: string, groupId = request.groupId as string) {
    const before = await snapshot(groupId);
    assert.deepEqual(await service.change(request), { ok: false, reason });
    assert.deepEqual(await snapshot(groupId), before);
  }

  try {
    await t.test('ambos sentidos conservan identidad y membresías; los inactivos no cuentan', async () => {
      const request = await fixture();
      const inactiveId = randomUUID();
      await prisma.groupMembership.create({ data: { groupId: request.groupId, userId: inactiveId, active: false } });
      const before = await snapshot(request.groupId);
      assert.deepEqual(await service.change(request), {
        ok: true, kind: 'patch', patch: { id: request.groupId, type: 'FAMILIA', revision: 5 },
      });
      const back = { ...request, destination: 'PAREJA', expectedRevision: '5', operationKey: randomUUID() };
      assert.deepEqual(await service.change(back), {
        ok: true, kind: 'patch', patch: { id: request.groupId, type: 'PAREJA', revision: 6 },
      });
      const after = await snapshot(request.groupId);
      assert.equal(after.id, before.id);
      assert.equal(after.type, 'PAREJA');
      assert.equal(after.revision, 6n);
      assert.deepEqual(after.memberships, before.memberships);
      assert.equal(after.operations.length, 2);
    });

    await t.test('tres miembros activos bloquean FAMILIA→PAREJA', async () => {
      const request = await fixture('FAMILIA', 3);
      await rejectWithoutMutation({ ...request, destination: 'PAREJA' }, 'TOO_MANY_ACTIVE_MEMBERS');
    });

    await t.test('actor ajeno, de otro grupo, inactivo o sin permiso se rechaza', async () => {
      const request = await fixture();
      await rejectWithoutMutation({ ...request, actorId: randomUUID() }, 'ACTOR_INACTIVE');
      const otherGroup = await fixture();
      await rejectWithoutMutation({ ...request, actorId: otherGroup.actorId }, 'ACTOR_INACTIVE');
      await prisma.groupMembership.update({
        where: { groupId_userId: { groupId: request.groupId, userId: request.actorId } }, data: { active: false },
      });
      await rejectWithoutMutation(request, 'ACTOR_INACTIVE');
      await prisma.groupMembership.update({
        where: { groupId_userId: { groupId: request.groupId, userId: request.actorId } },
        data: { active: true, canChangeMode: false },
      });
      // Los flags ajenos al contrato no sustituyen la autorización persistida.
      const forged = { ...request, actorActive: true, canChangeMode: true };
      await rejectWithoutMutation(forged, 'FORBIDDEN');
    });

    await t.test('IDs, clave, destino y revisión inválidos u obsoletos no mutan', async () => {
      const request = await fixture();
      for (const actorId of ['', 'actor', {}, undefined]) {
        await rejectWithoutMutation({ ...request, actorId }, 'INVALID_ID');
      }
      for (const groupId of ['', 'group', {}, undefined]) {
        await rejectWithoutMutation({ ...request, groupId }, 'INVALID_ID', request.groupId);
      }
      for (const operationKey of ['', ' ', 'x'.repeat(81), {}, undefined]) {
        await rejectWithoutMutation({ ...request, operationKey }, 'INVALID_OPERATION_KEY');
      }
      for (const destination of ['AMIGOS', '', {}, undefined]) {
        await rejectWithoutMutation({ ...request, destination }, 'INVALID_DESTINATION');
      }
      for (const expectedRevision of [-1, -1n, 1.5, Number.NaN, Number.POSITIVE_INFINITY,
        Number.MAX_SAFE_INTEGER + 1, 9007199254740992n, '9007199254740992', '04', '4.0', '4e0', ' 4', {}, undefined]) {
        await rejectWithoutMutation({ ...request, expectedRevision }, 'INVALID_REVISION');
      }
      await rejectWithoutMutation({ ...request, expectedRevision: 3 }, 'STALE_REVISION');
      await rejectWithoutMutation({ ...request, groupId: randomUUID() }, 'GROUP_NOT_FOUND', request.groupId);
      const atLimit = await fixture('PAREJA', 2, BigInt(Number.MAX_SAFE_INTEGER));
      await rejectWithoutMutation(atLimit, 'INVALID_REVISION');
      assert.deepEqual(await service.change({ ...atLimit, destination: 'PAREJA' }), { ok: true, kind: 'noop' });
    });

    await t.test('no-op crea un recibo y lo conserva tras un cambio posterior', async () => {
      const request = { ...await fixture(), destination: 'PAREJA' };
      const before = await snapshot(request.groupId);
      const result = { ok: true, kind: 'noop' };
      assert.deepEqual(await service.change(request), result);
      for (let attempt = 0; attempt < 10; attempt++) assert.deepEqual(await service.change(request), result);
      const after = await snapshot(request.groupId);
      assert.equal(after.type, before.type);
      assert.equal(after.revision, before.revision);
      assert.deepEqual(after.memberships, before.memberships);
      assert.equal(after.operations.length, 1);
      await service.change({ ...request, destination: 'FAMILIA', operationKey: randomUUID() });
      assert.deepEqual(await service.change(request), result);
      assert.equal((await snapshot(request.groupId)).revision, 5n);
    });

    await t.test('diez repeticiones y reconexión devuelven el recibo original', async () => {
      const request = await fixture();
      const result = await service.change(request);
      for (let attempt = 0; attempt < 10; attempt++) {
        assert.deepEqual(await service.change({ ...request, expectedRevision: 4, groupId: request.groupId.toUpperCase() }), result);
      }
      await prisma.onModuleDestroy();
      await prisma.onModuleInit();
      const reconnected = new GroupModePersistence(prisma);
      assert.deepEqual(await reconnected.change({ ...request, expectedRevision: '4' }), result);
      const after = await snapshot(request.groupId);
      assert.equal(after.revision, 5n);
      assert.equal(after.operations.length, 1);
    });

    await t.test('misma clave y contenido diferente generan conflicto antes de revisión obsoleta', async () => {
      const request = await fixture();
      await service.change(request);
      await rejectWithoutMutation({ ...request, destination: 'PAREJA' }, 'IDEMPOTENCY_CONFLICT');
      await rejectWithoutMutation({ ...request, expectedRevision: 5 }, 'IDEMPOTENCY_CONFLICT');
      const other = await fixture();
      assert.equal((await service.change({ ...other, operationKey: request.operationKey })).ok, true);
      const member = (await snapshot(request.groupId)).memberships.find((entry) => entry.userId !== request.actorId)!;
      await prisma.groupMembership.update({
        where: { groupId_userId: { groupId: request.groupId, userId: member.userId } }, data: { canChangeMode: true },
      });
      assert.deepEqual(await service.change({ ...request, actorId: member.userId, expectedRevision: 5 }), { ok: true, kind: 'noop' });
      assert.equal((await snapshot(request.groupId)).operations.length, 2);
    });

    await t.test('replay revalida permiso y membresía actuales', async () => {
      const request = await fixture();
      const result = await service.change(request);
      const where = { groupId_userId: { groupId: request.groupId, userId: request.actorId } };
      await prisma.groupMembership.update({ where, data: { canChangeMode: false } });
      await rejectWithoutMutation(request, 'FORBIDDEN');
      await prisma.groupMembership.update({ where, data: { canChangeMode: true, active: false } });
      await rejectWithoutMutation(request, 'ACTOR_INACTIVE');
      await prisma.groupMembership.update({ where, data: { active: true } });
      assert.deepEqual(await service.change(request), result);
      await prisma.groupMembership.delete({ where });
      await rejectWithoutMutation(request, 'ACTOR_INACTIVE');
    });

    await t.test('dos solicitudes idénticas concurrentes devuelven un solo cambio y recibo', async () => {
      const request = await fixture();
      const results = await Promise.all([service.change(request), service.change(request)]);
      const expected = { ok: true, kind: 'patch', patch: { id: request.groupId, type: 'FAMILIA', revision: 5 } };
      assert.deepEqual(results, [expected, expected]);
      const after = await snapshot(request.groupId);
      assert.equal(after.revision, 5n);
      assert.equal(after.operations.length, 1);
    });

    await t.test('dos claves concurrentes con la misma revisión: un éxito y un conflicto', async () => {
      const request = await fixture();
      const results = await Promise.all([
        service.change(request), service.change({ ...request, operationKey: randomUUID() }),
      ]);
      assert.equal(results.filter((result) => result.ok).length, 1);
      assert.deepEqual(results.find((result) => !result.ok), { ok: false, reason: 'STALE_REVISION' });
      const after = await snapshot(request.groupId);
      assert.equal(after.revision, 5n);
      assert.equal(after.operations.length, 1);
    });

    await t.test('fallo al insertar recibo revierte tipo/revisión y no declara éxito', async () => {
      const request = await fixture();
      const before = await snapshot(request.groupId);
      const suffix = randomUUID().replaceAll('-', '');
      const triggerName = `group_mode_receipt_fail_${suffix}`;
      const functionName = `group_mode_receipt_fail_fn_${suffix}`;
      try {
        await prisma.$executeRawUnsafe(`CREATE FUNCTION "${functionName}"() RETURNS trigger LANGUAGE plpgsql AS $$
          BEGIN
            IF NEW."groupId" = '${request.groupId}'::uuid THEN RAISE EXCEPTION 'Fallo sintético de recibo'; END IF;
            RETURN NEW;
          END;
        $$`);
        await prisma.$executeRawUnsafe(`CREATE TRIGGER "${triggerName}" BEFORE INSERT ON "GroupModeOperation"
          FOR EACH ROW EXECUTE FUNCTION "${functionName}"()`);
        await assert.rejects(service.change(request));
        assert.deepEqual(await snapshot(request.groupId), before);
      } finally {
        await prisma.$executeRawUnsafe(`DROP TRIGGER IF EXISTS "${triggerName}" ON "GroupModeOperation"`);
        await prisma.$executeRawUnsafe(`DROP FUNCTION IF EXISTS "${functionName}"()`);
      }
      assert.equal((await service.change(request)).ok, true);
      assert.equal((await snapshot(request.groupId)).revision, 5n);
    });
  } finally {
    try {
      await prisma.group.deleteMany({ where: { id: { in: fixtureIds } } });
    } finally {
      await prisma.onModuleDestroy();
    }
  }
});
