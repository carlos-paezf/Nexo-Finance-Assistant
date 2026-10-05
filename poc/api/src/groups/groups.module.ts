import { Module } from '@nestjs/common';
import { AuthModule } from '../auth/auth.module';
import { PrismaService } from '../database/prisma.service';
import { FinanceModule } from '../finance/finance.module';
import { GroupModeController } from './group-mode.controller';
import { GroupModePersistence } from './group-mode.persistence';

@Module({
  imports: [FinanceModule, AuthModule], controllers: [GroupModeController],
  providers: [{ provide: GroupModePersistence, useFactory: (prisma: PrismaService) => new GroupModePersistence(prisma), inject: [PrismaService] }],
})
export class GroupsModule {}
