import { Body, Controller, Get, Param, Post } from '@nestjs/common';
import { CreateAccountInput, CreateMovementInput, FinanceService } from './finance.service';

@Controller()
export class FinanceController {
  constructor(private readonly finance: FinanceService) {}

  @Post('accounts')
  createAccount(@Body() body: CreateAccountInput) {
    return this.finance.createAccount(body ?? {} as CreateAccountInput);
  }

  @Post('accounts/:accountId/movements')
  createMovement(@Param('accountId') accountId: string, @Body() body: CreateMovementInput) {
    return this.finance.createMovement(accountId, body ?? {} as CreateMovementInput);
  }

  @Get('accounts/:id')
  getAccount(@Param('id') id: string) {
    return this.finance.getAccount(id);
  }
}
