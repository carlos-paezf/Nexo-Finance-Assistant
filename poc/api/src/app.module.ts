import { Module } from '@nestjs/common';
import { FinanceModule } from './finance/finance.module';
import { AuthModule } from './auth/auth.module';
import { GroupsModule } from './groups/groups.module';

@Module({ imports: [FinanceModule, AuthModule, GroupsModule] })
export class AppModule {}
