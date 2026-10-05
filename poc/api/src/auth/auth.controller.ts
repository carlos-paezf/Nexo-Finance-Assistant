import { BadRequestException, Body, Controller, Header, HttpCode, Post, Req, UseGuards } from '@nestjs/common';
import { AuthService } from './auth.service';
import { AuthenticatedRequest, AuthGuard } from './auth.guard';

@Controller('auth')
export class AuthController {
  constructor(private readonly auth: AuthService) {}

  @Post('register')
  @Header('Cache-Control', 'no-store')
  register(@Body() body: unknown) { return this.auth.register(body); }

  @Post('login')
  @HttpCode(200)
  @Header('Cache-Control', 'no-store')
  login(@Body() body: unknown) { return this.auth.login(body); }

  @Post('logout')
  @UseGuards(AuthGuard)
  @HttpCode(204)
  @Header('Cache-Control', 'no-store')
  logout(@Req() request: AuthenticatedRequest, @Body() body: unknown) {
    if (body !== undefined && body !== null &&
        (typeof body !== 'object' || Array.isArray(body) || Object.keys(body).length > 0)) {
      throw new BadRequestException('Solicitud inválida.');
    }
    return this.auth.logout(request.actor);
  }
}
