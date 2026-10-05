import 'dotenv/config';
import { PrismaService } from '../src/database/prisma.service';

const prisma = new PrismaService();

async function main(): Promise<void> {
  await prisma.onModuleInit();
  try {
    await prisma.movement.deleteMany({ where: { id: 'ui-t005-income' } });
    await prisma.account.deleteMany({ where: { id: 'ui-t005-conflict-holder' } });
    await prisma.account.create({
      data: {
        id: 'ui-t005-conflict-holder',
        name: 'Cuenta reservada sintética',
        openingCents: 0n,
        requestHash: '0'.repeat(64),
      },
    });
    await prisma.movement.create({
      data: {
        id: 'ui-t005-income',
        accountId: 'ui-t005-conflict-holder',
        type: 'INCOME',
        description: 'Operación sintética reservada',
        amountCents: 1n,
        occurredAt: new Date('2026-10-05T10:00:00.000Z'),
        requestHash: '1'.repeat(64),
      },
    });
  } finally {
    await prisma.onModuleDestroy();
  }
}

main().catch((error: unknown) => {
  console.error(error);
  process.exitCode = 1;
});
