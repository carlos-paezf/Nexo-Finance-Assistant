import 'dotenv/config';
import { PrismaService } from '../src/database/prisma.service';

const id = process.argv[2];
if (!id || !/^[A-Za-z0-9_-]{1,80}$/.test(id)) {
  throw new Error('Se requiere un ID sintético válido para limpieza.');
}

async function main(): Promise<void> {
  const prisma = new PrismaService();
  await prisma.onModuleInit();
  try {
    await prisma.account.deleteMany({ where: { id } });
  } finally {
    await prisma.onModuleDestroy();
  }
}

main().catch((error: unknown) => {
  console.error(error);
  process.exitCode = 1;
});
