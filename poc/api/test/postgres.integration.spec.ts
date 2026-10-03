import 'dotenv/config';
import assert from 'node:assert/strict';
import { spawn, ChildProcess } from 'node:child_process';
import { randomUUID } from 'node:crypto';
import { createServer } from 'node:net';
import { once } from 'node:events';
import { test } from 'node:test';
import { PrismaService } from '../src/database/prisma.service';

async function reservePort(): Promise<number> {
  const server = createServer();
  await new Promise<void>((resolve, reject) => {
    server.once('error', reject);
    server.listen(0, '127.0.0.1', resolve);
  });
  const address = server.address();
  if (!address || typeof address === 'string') throw new Error('No se asignó puerto local.');
  await new Promise<void>((resolve, reject) => server.close((error) => error ? reject(error) : resolve()));
  return address.port;
}

async function startApi(port: number): Promise<ChildProcess> {
  const child = spawn(process.execPath, ['dist/src/main.js'], {
    cwd: process.cwd(),
    env: { ...process.env, PORT: String(port) },
    stdio: 'ignore',
  });
  const baseUrl = `http://127.0.0.1:${port}`;
  for (let attempt = 0; attempt < 100; attempt++) {
    if (child.exitCode !== null) throw new Error(`La API terminó al iniciar (${child.exitCode}).`);
    try {
      const response = await fetch(`${baseUrl}/accounts/no-existe`);
      if (response.status === 404) return child;
    } catch {
      await new Promise((resolve) => setTimeout(resolve, 100));
    }
  }
  child.kill();
  throw new Error('La API no respondió en 10 segundos.');
}

async function stopApi(child: ChildProcess): Promise<void> {
  if (child.exitCode !== null) return;
  child.kill();
  await Promise.race([
    once(child, 'exit').then(() => undefined),
    new Promise<void>((resolve) => setTimeout(resolve, 5000)),
  ]);
  if (child.exitCode === null) child.kill('SIGKILL');
}

test('PostgreSQL conserva saldo e idempotencia al reiniciar la API', {
  skip: !process.env.DATABASE_URL && 'Configura DATABASE_URL para ejecutar la integración PostgreSQL.',
  timeout: 60_000,
}, async () => {
  const accountId = `it-${randomUUID()}`;
  const income = {
    id: `${accountId}-income`, type: 'income', description: 'Ingreso sintético',
    amountCents: '2000000', occurredAt: '2026-10-01T10:00:00.000Z',
  };
  const expense = {
    id: `${accountId}-expense`, type: 'expense', description: 'Gasto sintético',
    amountCents: '1234567', occurredAt: '2026-10-02T10:00:00.000Z',
  };
  const port = await reservePort();
  const baseUrl = `http://127.0.0.1:${port}`;
  let child: ChildProcess | undefined;
  const prisma = new PrismaService();

  try {
    child = await startApi(port);
    const accountResponse = await fetch(`${baseUrl}/accounts`, {
      method: 'POST', headers: { 'content-type': 'application/json' },
      body: JSON.stringify({ id: accountId, name: 'Cuenta sintética', openingCents: '10000000' }),
    });
    assert.equal(accountResponse.status, 201);

    for (const movement of [income, expense]) {
      for (let retry = 0; retry < 10; retry++) {
        const response = await fetch(`${baseUrl}/accounts/${accountId}/movements`, {
          method: 'POST', headers: { 'content-type': 'application/json' },
          body: JSON.stringify(movement),
        });
        assert.equal(response.status, 201);
      }
    }

    const beforeRestart = await fetch(`${baseUrl}/accounts/${accountId}`);
    const firstSnapshot = await beforeRestart.json() as { balanceCents: string; movements: unknown[] };
    assert.equal(firstSnapshot.balanceCents, '10765433');
    assert.equal(firstSnapshot.movements.length, 2);

    await stopApi(child);
    child = await startApi(port);

    for (let retry = 0; retry < 10; retry++) {
      const response = await fetch(`${baseUrl}/accounts/${accountId}/movements`, {
        method: 'POST', headers: { 'content-type': 'application/json' },
        body: JSON.stringify(income),
      });
      assert.equal(response.status, 201);
    }
    const conflict = await fetch(`${baseUrl}/accounts/${accountId}/movements`, {
      method: 'POST', headers: { 'content-type': 'application/json' },
      body: JSON.stringify({ ...income, amountCents: '2000001' }),
    });
    assert.equal(conflict.status, 409);

    const afterRestart = await fetch(`${baseUrl}/accounts/${accountId}`);
    const secondSnapshot = await afterRestart.json() as { balanceCents: string; movements: unknown[] };
    assert.equal(secondSnapshot.balanceCents, '10765433');
    assert.equal(secondSnapshot.movements.length, 2);
  } finally {
    if (child) await stopApi(child);
    await prisma.onModuleInit();
    try {
      await prisma.account.deleteMany({ where: { id: accountId } });
    } finally {
      await prisma.onModuleDestroy();
    }
  }
});
