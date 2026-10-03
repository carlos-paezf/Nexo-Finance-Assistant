import 'dotenv/config';
import assert from 'node:assert/strict';
import { randomUUID } from 'node:crypto';
import { test } from 'node:test';
import { PrismaService } from '../src/database/prisma.service';
import { FinanceService } from '../src/finance/finance.service';
import { PrismaFinanceStore } from '../src/finance/prisma-finance.store';

test('PostgreSQL conserva idempotencia y saldo tras recrear el cliente Prisma', {
  skip: !process.env.DATABASE_URL && 'Configura DATABASE_URL y ejecuta npm run db:deploy.',
}, async () => {
  const id = `it-${randomUUID()}`;
  const request = {
    id: `${id}-income`, type: 'income', description: 'Ingreso', amountCents: '2000000',
    occurredAt: '2026-10-01T10:00:00.000Z',
  };
  const prisma1 = new PrismaService();
  await prisma1.onModuleInit();
  const service1 = new FinanceService(new PrismaFinanceStore(prisma1));
  try {
    await service1.createAccount({ id, name: 'Cuenta sintética', openingCents: '10000000' });
    for (let i = 0; i < 10; i++) await service1.createMovement(id, request);
  } finally {
    await prisma1.onModuleDestroy();
  }

  const prisma2 = new PrismaService();
  await prisma2.onModuleInit();
  try {
    const service2 = new FinanceService(new PrismaFinanceStore(prisma2));
    for (let i = 0; i < 10; i++) await service2.createMovement(id, request);
    const account = await service2.getAccount(id);
    assert.equal(account.balanceCents, '12000000');
    assert.equal(account.movements.length, 1);
    await prisma2.account.delete({ where: { id } });
  } finally {
    await prisma2.onModuleDestroy();
  }
});
