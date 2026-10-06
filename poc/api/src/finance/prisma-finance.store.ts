import { Injectable } from '@nestjs/common';
import { PrismaService } from '../database/prisma.service';
import { FinanceStore } from './finance.types';

@Injectable()
export class PrismaFinanceStore implements FinanceStore {
  constructor(private readonly prisma: PrismaService) {}

  createAccount(data: Parameters<FinanceStore['createAccount']>[0]) {
    return this.prisma.account.create({ data });
  }

  findAccount(id: string) {
    return this.prisma.account.findUnique({ where: { id } });
  }

  createMovement(data: Parameters<FinanceStore['createMovement']>[0]) {
    return this.prisma.movement.create({ data });
  }

  findMovement(id: string) {
    return this.prisma.movement.findUnique({ where: { id } });
  }

  listMovements(accountId: string) {
    return this.prisma.movement.findMany({
      where: { accountId },
      orderBy: [{ occurredAt: 'desc' }, { id: 'desc' }],
    });
  }
}
