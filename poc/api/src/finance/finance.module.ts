import { Module } from '@nestjs/common';
import { PrismaService } from '../database/prisma.service';
import { FinanceController } from './finance.controller';
import { FINANCE_STORE } from './finance.types';
import { FinanceService } from './finance.service';
import { PrismaFinanceStore } from './prisma-finance.store';

@Module({
  controllers: [FinanceController],
  providers: [
    PrismaService,
    PrismaFinanceStore,
    { provide: FINANCE_STORE, useExisting: PrismaFinanceStore },
    FinanceService,
  ],
})
export class FinanceModule {}
