export type MovementKind = 'INCOME' | 'EXPENSE';

export interface AccountRecord {
  id: string;
  name: string;
  openingCents: bigint;
  requestHash: string;
  createdAt: Date;
}

export interface MovementRecord {
  id: string;
  accountId: string;
  type: MovementKind;
  description: string;
  amountCents: bigint;
  occurredAt: Date;
  requestHash: string;
  createdAt: Date;
}

export interface FinanceStore {
  createAccount(data: Omit<AccountRecord, 'createdAt'>): Promise<AccountRecord>;
  findAccount(id: string): Promise<AccountRecord | null>;
  createMovement(data: Omit<MovementRecord, 'createdAt'>): Promise<MovementRecord>;
  findMovement(id: string): Promise<MovementRecord | null>;
  listMovements(accountId: string): Promise<MovementRecord[]>;
}

export const FINANCE_STORE = Symbol('FINANCE_STORE');
