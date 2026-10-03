import assert from 'node:assert/strict';
import { test } from 'node:test';
import { ConflictException } from '@nestjs/common';
import { FinanceService } from '../src/finance/finance.service';
import { AccountRecord, FinanceStore, MovementRecord } from '../src/finance/finance.types';

class MemoryStore implements FinanceStore {
  readonly accounts = new Map<string, AccountRecord>();
  readonly movements = new Map<string, MovementRecord>();

  async createAccount(data: Omit<AccountRecord, 'createdAt'>): Promise<AccountRecord> {
    if (this.accounts.has(data.id)) throw { code: 'P2002' };
    const account = { ...data, createdAt: new Date('2026-10-03T12:00:00.000Z') };
    this.accounts.set(account.id, account);
    return account;
  }

  async findAccount(id: string) { return this.accounts.get(id) ?? null; }

  async createMovement(data: Omit<MovementRecord, 'createdAt'>): Promise<MovementRecord> {
    if (this.movements.has(data.id)) throw { code: 'P2002' };
    if (!this.accounts.has(data.accountId)) throw { code: 'P2003' };
    const movement = { ...data, createdAt: new Date('2026-10-03T12:00:00.000Z') };
    this.movements.set(movement.id, movement);
    return movement;
  }

  async findMovement(id: string) { return this.movements.get(id) ?? null; }

  async listMovements(accountId: string) {
    return [...this.movements.values()]
      .filter((movement) => movement.accountId === accountId)
      .sort((a, b) => b.occurredAt.getTime() - a.occurredAt.getTime());
  }
}

test('CA-I1-02: saldo exacto en centavos y respuesta serializable', async () => {
  const store = new MemoryStore();
  const service = new FinanceService(store);
  await service.createAccount({ id: 'acct-1', name: 'Cuenta', openingCents: '10000000' });
  await service.createMovement('acct-1', {
    id: 'income-1', type: 'income', description: 'Ingreso', amountCents: '2000000',
    occurredAt: '2026-10-01T10:00:00.000Z',
  });
  await service.createMovement('acct-1', {
    id: 'expense-1', type: 'expense', description: 'Compra', amountCents: '1234567',
    occurredAt: '2026-10-02T10:00:00.000Z',
  });
  const result = await service.getAccount('acct-1');
  assert.equal(result.balanceCents, '10765433');
  assert.equal(result.movements.length, 2);
});

test('cuenta y movimiento reintentados diez veces producen un efecto', async () => {
  const store = new MemoryStore();
  const service = new FinanceService(store);
  const account = { id: 'acct-retry', name: 'Cuenta', openingCents: '0' };
  for (let i = 0; i < 10; i++) await service.createAccount(account);
  const movement = {
    id: 'stable-op', type: 'expense', description: 'Café', amountCents: '101',
    occurredAt: '2026-10-03T12:00:00.000Z',
  };
  for (let i = 0; i < 10; i++) await service.createMovement('acct-retry', movement);
  assert.equal(store.accounts.size, 1);
  assert.equal(store.movements.size, 1);
  assert.equal((await service.getAccount('acct-retry')).balanceCents, '-101');
});

test('mismo ID con distinto contenido se rechaza con 409', async () => {
  const service = new FinanceService(new MemoryStore());
  await service.createAccount({ id: 'acct-conflict', name: 'Cuenta', openingCents: '0' });
  const request = {
    id: 'stable-op', type: 'income', description: 'Pago', amountCents: '500',
    occurredAt: '2026-10-03T12:00:00.000Z',
  };
  await service.createMovement('acct-conflict', request);
  await assert.rejects(
    service.createMovement('acct-conflict', { ...request, amountCents: '501' }),
    (error: unknown) => error instanceof ConflictException && error.getStatus() === 409,
  );
});

test('importe decimal o superior a BIGINT no pasa la validación', async () => {
  const service = new FinanceService(new MemoryStore());
  await service.createAccount({ id: 'acct-validation', name: 'Cuenta', openingCents: '0' });
  const request = {
    id: 'bad-op', type: 'income', description: 'Pago', amountCents: '100.01',
    occurredAt: '2026-10-03T12:00:00.000Z',
  };
  await assert.rejects(service.createMovement('acct-validation', request));
  await assert.rejects(service.createMovement('acct-validation', {
    ...request, id: 'huge-op', amountCents: '99999999999999999999',
  }));
});
