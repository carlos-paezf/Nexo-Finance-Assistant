import { CanActivate, ExecutionContext, Injectable } from '@nestjs/common';
import { AuthService, SessionActor } from './auth.service';

export type AuthenticatedRequest = { headers: { authorization?: string }; actor: SessionActor };

@Injectable()
export class AuthGuard implements CanActivate {
  constructor(private readonly auth: AuthService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest<AuthenticatedRequest>();
    request.actor = await this.auth.authenticate(request.headers.authorization);
    return true;
  }
}
