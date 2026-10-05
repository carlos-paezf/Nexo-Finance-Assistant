import { Module } from '@nestjs/common';
import { FinanceModule } from '../finance/finance.module';
import { AuthController } from './auth.controller';
import { AuthGuard } from './auth.guard';
import { AuthService } from './auth.service';

@Module({
  imports: [FinanceModule], controllers: [AuthController],
  providers: [AuthService, AuthGuard], exports: [AuthService, AuthGuard],
})
export class AuthModule {}
