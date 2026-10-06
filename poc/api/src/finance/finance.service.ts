import {
  BadRequestException,
  ConflictException,
  Inject,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { createHash } from 'node:crypto';
import { FINANCE_STORE, FinanceStore, MovementKind } from './finance.types';

const MAX_PG_BIGINT = 9223372036854775807n;
const ID = /^[A-Za-z0-9_-]{1,80}$/;
const CENTS = /^(0|[1-9][0-9]*)$/;

export interface CreateAccountInput {
  id: unknown;
  name: unknown;
  openingCents: unknown;
}

export interface CreateMovementInput {
  id: unknown;
  type: unknown;
  description: unknown;
  amountCents: unknown;
  occurredAt: unknown;
}

@Injectable()
export class FinanceService {
  constructor(@Inject(FINANCE_STORE) private readonly store: FinanceStore) {}

  async createAccount(input: CreateAccountInput) {
    const id = this.parseId(input.id);
    if (typeof input.name !== 'string' || !input.name.trim() || input.name.trim().length > 80) {
      throw new BadRequestException('El nombre debe tener entre 1 y 80 caracteres.');
    }
    const name = input.name.trim();
    const openingCents = this.parseCents(input.openingCents, true);
    const requestHash = this.hash({ id, name, openingCents: openingCents.toString() });
    try {
      return this.accountDto(await this.store.createAccount({ id, name, openingCents, requestHash }));
    } catch (error) {
      if (!this.isUniqueViolation(error)) throw error;
      const existing = await this.store.findAccount(id);
      if (!existing) throw error;
      if (existing.requestHash !== requestHash) {
        throw new ConflictException('El ID de cuenta ya se usó con otro contenido.');
      }
      return this.accountDto(existing);
    }
  }

  async createMovement(accountIdInput: unknown, input: CreateMovementInput) {
    const accountId = this.parseId(accountIdInput);
    const id = this.parseId(input.id);
    if (input.type !== 'income' && input.type !== 'expense') {
      throw new BadRequestException('El tipo debe ser income o expense.');
    }
    const type: MovementKind = input.type === 'income' ? 'INCOME' : 'EXPENSE';
    if (
      typeof input.description !== 'string' ||
      !input.description.trim() ||
      input.description.trim().length > 200
    ) {
      throw new BadRequestException('La descripción debe tener entre 1 y 200 caracteres.');
    }
    const description = input.description.trim();
    const amountCents = this.parseCents(input.amountCents, false);
    if (typeof input.occurredAt !== 'string' || !Number.isFinite(Date.parse(input.occurredAt))) {
      throw new BadRequestException('La fecha del movimiento no es válida.');
    }
    const occurredAt = new Date(input.occurredAt);
    const requestHash = this.hash({
      accountId,
      type,
      description,
      amountCents: amountCents.toString(),
      occurredAt: occurredAt.toISOString(),
    });
    try {
      return this.movementDto(await this.store.createMovement({
        id,
        accountId,
        type,
        description,
        amountCents,
        occurredAt,
        requestHash,
      }));
    } catch (error) {
      if (this.isForeignKeyViolation(error)) {
        throw new NotFoundException('No existe la cuenta.');
      }
      if (!this.isUniqueViolation(error)) throw error;
      const existing = await this.store.findMovement(id);
      if (!existing) throw error;
      if (existing.requestHash !== requestHash) {
        throw new ConflictException('El ID de operación ya se usó con otro contenido.');
      }
      return this.movementDto(existing);
    }
  }

  async getAccount(idInput: unknown) {
    const id = this.parseId(idInput);
    const account = await this.store.findAccount(id);
    if (!account) throw new NotFoundException('No existe la cuenta.');
    const movements = await this.store.listMovements(id);
    const balance = movements.reduce(
      (sum, movement) =>
        sum + (movement.type === 'INCOME' ? movement.amountCents : -movement.amountCents),
      account.openingCents,
    );
    return {
      ...this.accountDto(account),
      balanceCents: balance.toString(),
      movements: movements.map((movement) => this.movementDto(movement)),
    };
  }

  private parseId(value: unknown): string {
    if (typeof value !== 'string' || !ID.test(value)) {
      throw new BadRequestException('El ID debe usar letras, números, guion o guion bajo (máximo 80).');
    }
    return value;
  }

  private parseCents(value: unknown, allowZero: boolean): bigint {
    if (typeof value !== 'string' || !CENTS.test(value)) {
      throw new BadRequestException('El importe debe ser una cadena de centavos enteros.');
    }
    const cents = BigInt(value);
    if ((!allowZero && cents === 0n) || cents > MAX_PG_BIGINT) {
      throw new BadRequestException('El importe está fuera del rango permitido.');
    }
    return cents;
  }

  private hash(value: object): string {
    return createHash('sha256').update(JSON.stringify(value)).digest('hex');
  }

  private isUniqueViolation(error: unknown): boolean {
    return this.prismaCode(error) === 'P2002';
  }

  private isForeignKeyViolation(error: unknown): boolean {
    return this.prismaCode(error) === 'P2003';
  }

  private prismaCode(error: unknown): unknown {
    return error && typeof error === 'object' && 'code' in error
      ? (error as { code: unknown }).code
      : undefined;
  }

  private accountDto(account: {
    id: string; name: string; openingCents: bigint; createdAt: Date;
  }) {
    return {
      id: account.id,
      name: account.name,
      openingCents: account.openingCents.toString(),
      createdAt: account.createdAt.toISOString(),
    };
  }

  private movementDto(movement: {
    id: string; accountId: string; type: MovementKind; description: string;
    amountCents: bigint; occurredAt: Date;
  }) {
    return {
      id: movement.id,
      accountId: movement.accountId,
      type: movement.type === 'INCOME' ? 'income' : 'expense',
      description: movement.description,
      amountCents: movement.amountCents.toString(),
      occurredAt: movement.occurredAt.toISOString(),
    };
  }
}
