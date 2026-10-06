import 'dotenv/config';
import assert from 'node:assert/strict';
import { spawn, ChildProcess } from 'node:child_process';
import { once } from 'node:events';
import { randomBytes, randomUUID } from 'node:crypto';
import { createServer } from 'node:net';
import { test } from 'node:test';
import { PrismaService } from '../src/database/prisma.service';
import { tokenHash } from '../src/auth/auth.service';

type Authentication = { user: { id: string; email: string }; token: string; expiresAt: string };

async function reservePort(): Promise<number> {
  const server = createServer();
  await new Promise<void>((resolve, reject) => {
    server.once('error', reject);
    server.listen(0, '127.0.0.1', resolve);
  });
  const address = server.address();
  assert.ok(address && typeof address !== 'string');
  await new Promise<void>((resolve, reject) => server.close((error) => error ? reject(error) : resolve()));
  return address.port;
}

async function startApi(port: number): Promise<ChildProcess> {
  const child = spawn(process.execPath, ['dist/src/main.js'], {
    cwd: process.cwd(), env: { ...process.env, PORT: String(port) }, stdio: 'ignore',
  });
  for (let attempt = 0; attempt < 100; attempt++) {
    if (child.exitCode !== null) throw new Error('La API terminó durante el inicio.');
    try {
      if ((await fetch(`http://127.0.0.1:${port}/accounts/no-existe`)).status === 404) return child;
    } catch { /* Todavía inicia. */ }
    await new Promise((resolve) => setTimeout(resolve, 100));
  }
  await stopApi(child);
  throw new Error('La API no inició en 10 segundos.');
}

async function stopApi(child: ChildProcess): Promise<void> {
  if (child.exitCode !== null) return;
  const exited = once(child, 'exit');
  child.kill();
  await Promise.race([exited, new Promise((resolve) => setTimeout(resolve, 5000))]);
  if (child.exitCode === null) {
    child.kill('SIGKILL');
    await exited;
  }
}

test('HTTP + PostgreSQL: credenciales, sesiones y cambio de modo persisten sin identidad cliente', {
  timeout: 120_000,
}, async (t) => {
  assert.ok(process.env.DATABASE_URL, 'La integración requiere DATABASE_URL; no se omite PostgreSQL.');
  const prisma = new PrismaService();
  const port = await reservePort();
  const baseUrl = `http://127.0.0.1:${port}`;
  const fixtureTag = randomUUID();
  const email = `auth-${fixtureTag}@example.test`;
  const externalEmail = `external-${fixtureTag}@example.test`;
  const password = '  Clave sintética 123!  ';
  const groupId = randomUUID();
  const externalGroupId = randomUUID();
  let createdGroupId = '';
  const legacyMemberId = randomUUID();
  let child: ChildProcess | undefined;
  let auth: Authentication;
  let external: Authentication;
  let login: Authentication;
  const key = randomUUID();
  const request = { destination: 'FAMILIA', expectedRevision: 0 };
  const patch = { ok: true, kind: 'patch', patch: { id: groupId, type: 'FAMILIA', revision: 1 } };

  async function call(path: string, method = 'POST', body?: unknown, token?: string, operationKey?: string) {
    return fetch(`${baseUrl}${path}`, {
      method, headers: {
        'content-type': 'application/json', ...(token ? { authorization: `Bearer ${token}` } : {}),
        ...(operationKey ? { 'idempotency-key': operationKey } : {}),
      }, body: body === undefined ? undefined : JSON.stringify(body),
    });
  }
  const change = (token?: string, body: unknown = request, operationKey: string = key) =>
    call(`/groups/${groupId}/mode`, 'PATCH', body, token, operationKey);

  await prisma.onModuleInit();
  try {
    // El UUID anterior no puede convertirse en identidad enviándolo en el registro.
    await prisma.group.create({ data: { id: groupId, type: 'PAREJA', memberships: {
      create: { userId: legacyMemberId, active: true, canChangeMode: true },
    } } });
    child = await startApi(port);

    await t.test('registro normaliza correo, preserva contraseña y devuelve únicamente datos públicos', async () => {
      const forged = await call('/auth/register', 'POST', { email, password, id: legacyMemberId });
      assert.equal(forged.status, 400);
      for (const [raw, expectedStatus] of [
        ['{"password":"secreto-sintético",', 400],
        [JSON.stringify({ email, password: 'x'.repeat(9000) }), 413],
      ] as const) {
        const invalid = await fetch(`${baseUrl}/auth/register`, {
          method: 'POST', headers: { 'content-type': 'application/json' }, body: raw,
        });
        assert.equal(invalid.status, expectedStatus);
        assert.equal(invalid.headers.get('cache-control'), 'no-store');
        assert.equal((await invalid.text()).includes('secreto-sintético'), false);
      }
      for (const invalidPassword of ['corta', 'x'.repeat(129), '😀'.repeat(65)]) {
        assert.equal((await call('/auth/register', 'POST', { email, password: invalidPassword })).status, 400);
      }
      const response = await call('/auth/register', 'POST', { email: `  ${email.toUpperCase()}  `, password });
      assert.equal(response.status, 201);
      assert.equal(response.headers.get('cache-control'), 'no-store');
      auth = await response.json() as Authentication;
      assert.equal(auth.user.email, email);
      assert.match(auth.user.id, /^[0-9a-f-]{36}$/);
      assert.notEqual(auth.user.id, legacyMemberId);
      assert.match(auth.token, /^[A-Za-z0-9_-]{43}$/);
      assert.deepEqual(Object.keys(auth).sort(), ['expiresAt', 'token', 'user']);
      assert.deepEqual(Object.keys(auth.user).sort(), ['email', 'id']);
      const user = await prisma.user.findUniqueOrThrow({ where: { id: auth.user.id } });
      assert.match(user.passwordHash, /^scrypt\$v=1\$N=131072\$r=8\$p=1\$[0-9a-f]{32}\$[0-9a-f]{128}$/);
      assert.ok(!user.passwordHash.includes(password));
      const session = await prisma.authSession.findUniqueOrThrow({ where: { tokenHash: tokenHash(auth.token) } });
      assert.equal(session.userId, user.id);
      assert.notEqual(session.tokenHash, auth.token);
      assert.equal(session.expiresAt.toISOString(), auth.expiresAt);
      const duplicate = await call('/auth/register', 'POST', { email: email.toUpperCase(), password });
      assert.equal(duplicate.status, 409);
      assert.equal(duplicate.headers.get('cache-control'), 'no-store');
      assert.equal(await prisma.user.count({ where: { email } }), 1);
      assert.equal(await prisma.authSession.count({ where: { userId: user.id } }), 1);
    });

    await t.test('login incorrecto e inexistente son genéricos y procesan scrypt; no recorta contraseñas', async () => {
      const invalid = await call('/auth/login', 'POST', { email, password: password.trim() });
      const missing = await call('/auth/login', 'POST', { email: `missing-${fixtureTag}@example.test`, password });
      assert.equal(invalid.status, 401);
      assert.equal(missing.status, 401);
      assert.deepEqual(await invalid.json(), await missing.json());
      assert.equal(invalid.headers.get('cache-control'), 'no-store');
      const valid = await call('/auth/login', 'POST', { email: email.toUpperCase(), password });
      assert.equal(valid.status, 200);
      login = await valid.json() as Authentication;
      assert.equal(login.user.id, auth.user.id);
      assert.notEqual(login.token, auth.token);
      const externalResponse = await call('/auth/register', 'POST', { email: externalEmail, password });
      assert.equal(externalResponse.status, 201);
      external = await externalResponse.json() as Authentication;
      await prisma.group.create({ data: { id: externalGroupId, type: 'PAREJA', memberships: {
        create: { userId: external.user.id, active: true, canChangeMode: true },
      } } });
    });

    await t.test('crear y listar grupos deriva identidad, permisos y visibilidad de la sesión', async () => {
      assert.equal((await call('/groups', 'POST', { name: 'Sin sesión', type: 'PAREJA' })).status, 401);
      assert.equal((await call('/groups', 'GET')).status, 401);
      for (const body of [
        { name: 'Inválido', type: 'PAREJA', id: randomUUID() },
        { name: 'Inválido', type: 'PAREJA', members: [] },
        { name: 'Inválido', type: 'PAREJA', canChangeMode: false },
        { name: 'Inválido', type: 'PAREJA', userId: external.user.id },
        { name: '', type: 'FAMILIA' },
        { name: 'V'.repeat(81), type: 'FAMILIA' },
        { name: 'Tipo inválido', type: 'AMIGOS' },
      ]) assert.equal((await call('/groups', 'POST', body, auth.token)).status, 400);

      const response = await call('/groups', 'POST', { name: '  Grupo de prueba  ', type: 'PAREJA' }, auth.token);
      assert.equal(response.status, 201);
      const created = await response.json() as { id: string; name: string; type: string; revision: string; canChangeMode: boolean };
      createdGroupId = created.id;
      assert.match(createdGroupId, /^[0-9a-f-]{36}$/);
      assert.deepEqual(created, { id: createdGroupId, name: 'Grupo de prueba', type: 'PAREJA', revision: '0', canChangeMode: true });
      const membership = await prisma.groupMembership.findUniqueOrThrow({
        where: { groupId_userId: { groupId: createdGroupId, userId: auth.user.id } },
      });
      assert.equal(membership.active, true);
      assert.equal(membership.canChangeMode, true);

      const own = await call('/groups', 'GET', undefined, auth.token);
      assert.equal(own.status, 200);
      assert.deepEqual(await own.json(), [created]);
      const other = await call('/groups', 'GET', undefined, external.token);
      assert.equal(other.status, 200);
      const otherGroups = await other.json() as Array<{ id: string }>;
      assert.deepEqual(otherGroups.map((group) => group.id), [externalGroupId]);
      assert.equal(otherGroups.some((group) => group.id === createdGroupId), false);
    });

    await t.test('Bearer ausente, inválido, caducado, revocado y en URL se rechazan', async () => {
      assert.equal((await change()).status, 401);
      assert.equal((await change(randomBytes(32).toString('base64url'))).status, 401);
      assert.equal((await call(`/groups/${groupId}/mode?token=${auth.token}`, 'PATCH', request)).status, 401);
      const where = { tokenHash: tokenHash(login.token) };
      await prisma.authSession.update({ where, data: { expiresAt: new Date(Date.now() - 1000) } });
      assert.equal((await change(login.token)).status, 401);
      await prisma.authSession.update({ where, data: { expiresAt: new Date(Date.now() + 60_000), revokedAt: new Date() } });
      assert.equal((await change(login.token)).status, 401);
      assert.equal(await prisma.groupModeOperation.count({ where: { groupId } }), 0);
    });

    await t.test('ajeno, sin permiso, inactivo y falsificación no mutan ni reciben recibo', async () => {
      assert.equal((await change(auth.token)).status, 403);
      await prisma.groupMembership.create({ data: { groupId, userId: auth.user.id, active: true, canChangeMode: false } });
      const where = { groupId_userId: { groupId, userId: auth.user.id } };
      assert.equal((await change(auth.token)).status, 403);
      for (const forged of [
        { actorId: legacyMemberId }, { userId: legacyMemberId }, { canChangeMode: true },
        { actorActive: true }, { authorization: { actorId: legacyMemberId, canChangeMode: true } },
      ]) assert.equal((await change(auth.token, { ...request, ...forged })).status, 400);
      await prisma.groupMembership.update({ where, data: { canChangeMode: true, active: false } });
      assert.equal((await change(auth.token)).status, 403);
      await prisma.groupMembership.update({ where, data: { active: true } });
      assert.equal((await change(external.token)).status, 403);
      assert.equal((await call(`/groups/${randomUUID()}/mode`, 'PATCH', request, auth.token, key)).status, 403);
      assert.equal((await prisma.group.findUniqueOrThrow({ where: { id: groupId } })).revision, 0n);
      assert.equal(await prisma.groupModeOperation.count({ where: { groupId } }), 0);
    });

    await t.test('valida entrada, cambia una vez, repite recibo y detecta conflicto', async () => {
      for (const body of [{ ...request, destination: 'AMIGOS' }, { ...request, expectedRevision: -1 }]) {
        assert.equal((await change(auth.token, body)).status, 400);
      }
      assert.equal((await call(`/groups/${groupId}/mode`, 'PATCH', request, auth.token)).status, 400);
      assert.equal((await change(auth.token, request, 'clave inválida')).status, 400);
      const results = await Promise.all([change(auth.token), change(auth.token)]);
      for (const response of results) {
        assert.equal(response.status, 200);
        assert.deepEqual(await response.json(), patch);
      }
      assert.equal((await change(auth.token, { ...request, destination: 'PAREJA' })).status, 409);
      assert.equal((await change(auth.token, request, randomUUID())).status, 409);
      assert.equal(await prisma.groupModeOperation.count({ where: { groupId } }), 1);
    });

    await t.test('sesión y recibo sobreviven al reinicio; replay reautoriza membresía', async () => {
      await stopApi(child!);
      child = await startApi(port);
      const replay = await change(auth.token);
      assert.equal(replay.status, 200);
      assert.deepEqual(await replay.json(), patch);
      const where = { groupId_userId: { groupId, userId: auth.user.id } };
      await prisma.groupMembership.update({ where, data: { canChangeMode: false } });
      assert.equal((await change(auth.token)).status, 403);
      await prisma.groupMembership.update({ where, data: { canChangeMode: true, active: false } });
      assert.equal((await change(auth.token)).status, 403);
      await prisma.groupMembership.update({ where, data: { active: true } });
      assert.equal((await change(auth.token)).status, 200);
    });

    await t.test('logout revoca persistentemente y bloquea replay incluso tras reinicio', async () => {
      assert.equal((await call('/auth/logout', 'POST', { userId: external.user.id }, auth.token)).status, 400);
      const response = await call('/auth/logout', 'POST', undefined, auth.token);
      assert.equal(response.status, 204);
      assert.equal(response.headers.get('cache-control'), 'no-store');
      assert.equal((await change(auth.token)).status, 401);
      assert.equal((await call('/auth/logout', 'POST', undefined, auth.token)).status, 401);
      assert.ok((await prisma.authSession.findUniqueOrThrow({ where: { tokenHash: tokenHash(auth.token) } })).revokedAt);
      await stopApi(child!);
      child = await startApi(port);
      assert.equal((await change(auth.token)).status, 401);
      assert.equal(await prisma.groupModeOperation.count({ where: { groupId } }), 1);
    });

    await t.test('hashes simultáneos y volumen de intentos tienen límite sin cola', async () => {
      const responses = await Promise.all(Array.from({ length: 6 }, () =>
        call('/auth/login', 'POST', { email, password: password.trim() })));
      assert.ok(responses.some((response) => response.status === 401));
      assert.ok(responses.some((response) => response.status === 429));
      assert.ok(responses.every((response) => [401, 429].includes(response.status)));
      let limited = false;
      for (let attempt = 0; attempt < 61; attempt++) {
        const response = await call('/auth/login', 'POST', { email, password: password.trim() });
        if (response.status === 429) { limited = true; break; }
        assert.equal(response.status, 401);
      }
      assert.ok(limited);
    });
  } finally {
    if (child) await stopApi(child);
    try {
      await prisma.group.deleteMany({ where: { id: { in: [groupId, externalGroupId, ...(createdGroupId ? [createdGroupId] : [])] } } });
      await prisma.user.deleteMany({ where: { email: { in: [email, externalEmail] } } });
    } finally {
      await prisma.onModuleDestroy();
    }
  }
});
