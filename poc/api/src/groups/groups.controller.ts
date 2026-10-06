import {
  BadRequestException, Body, Controller, Get, Post,
  Req, ServiceUnavailableException, UseGuards,
} from '@nestjs/common';
import { randomUUID } from 'node:crypto';
import { AuthGuard, AuthenticatedRequest } from '../auth/auth.guard';
import { PrismaService } from '../database/prisma.service';

type GroupType = 'PAREJA' | 'FAMILIA';

@Controller('groups')
@UseGuards(AuthGuard)
export class GroupsController {
  constructor(private readonly prisma: PrismaService) {}

  @Post()
  async create(@Body() body: unknown, @Req() request: AuthenticatedRequest) {
    if (!body || typeof body !== 'object' || Array.isArray(body) ||
        Object.keys(body).some((key) => key !== 'name' && key !== 'type')) {
      throw new BadRequestException('Solicitud inválida.');
    }
    const input = body as Record<string, unknown>;
    if (typeof input.name !== 'string' || typeof input.type !== 'string' ||
        (input.type !== 'PAREJA' && input.type !== 'FAMILIA')) {
      throw new BadRequestException('Nombre o tipo de grupo inválido.');
    }
    const name = input.name.trim();
    if (Array.from(name).length < 1 || Array.from(name).length > 80) {
      throw new BadRequestException('El nombre debe tener entre 1 y 80 caracteres.');
    }
    try {
      const group = await this.prisma.group.create({
        data: {
          id: randomUUID(),
          name,
          type: input.type as GroupType,
          memberships: {
            create: { userId: request.actor.userId, active: true, canChangeMode: true },
          },
        },
        select: { id: true, name: true, type: true, revision: true },
      });
      return { ...group, revision: group.revision.toString(), canChangeMode: true };
    } catch {
      throw new ServiceUnavailableException('No se pudo crear el grupo.');
    }
  }

  @Get()
  async list(@Req() request: AuthenticatedRequest) {
    try {
      const groups = await this.prisma.group.findMany({
        where: { memberships: { some: { userId: request.actor.userId, active: true } } },
        orderBy: [{ name: 'asc' }, { id: 'asc' }],
        select: {
          id: true,
          name: true,
          type: true,
          revision: true,
          memberships: {
            where: { userId: request.actor.userId, active: true },
            select: { canChangeMode: true },
            take: 1,
          },
        },
      });
      return groups.map(({ memberships, ...group }) => ({
        ...group,
        revision: group.revision.toString(),
        canChangeMode: memberships[0]?.canChangeMode === true,
      }));
    } catch {
      throw new ServiceUnavailableException('No se pudieron consultar los grupos.');
    }
  }
}
