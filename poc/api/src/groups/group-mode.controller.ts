import {
  BadRequestException, Controller, ForbiddenException, Headers, HttpException,
  Param, Patch, Req, ServiceUnavailableException, Body, UseGuards,
} from '@nestjs/common';
import { AuthenticatedRequest, AuthGuard } from '../auth/auth.guard';
import { GroupModePersistence } from './group-mode.persistence';

@Controller('groups')
@UseGuards(AuthGuard)
export class GroupModeController {
  constructor(private readonly mode: GroupModePersistence) {}

  @Patch(':groupId/mode')
  async change(
    @Param('groupId') groupId: string, @Headers('idempotency-key') operationKey: unknown,
    @Body() body: unknown, @Req() request: AuthenticatedRequest,
  ) {
    if (!body || typeof body !== 'object' || Array.isArray(body) ||
        Object.keys(body).some((key) => key !== 'destination' && key !== 'expectedRevision')) {
      throw new BadRequestException('Solicitud inválida.');
    }
    const input = body as Record<string, unknown>;
    try {
      const result = await this.mode.change({
        groupId, operationKey, actorId: request.actor.userId,
        destination: input.destination, expectedRevision: input.expectedRevision,
      });
      if (result.ok) return result;
      if (['ACTOR_INACTIVE', 'FORBIDDEN', 'GROUP_NOT_FOUND'].includes(result.reason)) {
        throw new ForbiddenException('No puedes cambiar el modo de este grupo.');
      }
      throw new HttpException(result, result.reason.startsWith('INVALID_') ? 400 : 409);
    } catch (error) {
      if (error instanceof HttpException) throw error;
      throw new ServiceUnavailableException('Servicio temporalmente no disponible.');
    }
  }
}
