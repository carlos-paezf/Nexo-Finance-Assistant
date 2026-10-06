import {
  BadRequestException, ConflictException, HttpException, Injectable,
  ServiceUnavailableException, UnauthorizedException,
} from '@nestjs/common';
import { createHash, randomBytes, scrypt, timingSafeEqual } from 'node:crypto';
import { PrismaService } from '../database/prisma.service';
import { Prisma } from '../generated/prisma/client';

const SCRYPT = { N: 131072, r: 8, p: 1, maxmem: 192 * 1024 * 1024 };
const SESSION_MS = 8 * 60 * 60 * 1000;
const HASH_PREFIX = 'scrypt$v=1$N=131072$r=8$p=1';
const HASH_FORMAT = /^scrypt\$v=1\$N=131072\$r=8\$p=1\$([0-9a-f]{32})\$([0-9a-f]{128})$/;

function derive(password: string, salt: Buffer): Promise<Buffer> {
  return new Promise((resolve, reject) => scrypt(password, salt, 64, SCRYPT,
    (error, key) => error ? reject(error) : resolve(key)));
}

export function tokenHash(token: string): string {
  return createHash('sha256').update(token).digest('hex');
}

function credentials(body: unknown): { email: string; password: string } {
  if (!body || typeof body !== 'object' || Array.isArray(body) ||
      Object.keys(body).some((key) => key !== 'email' && key !== 'password')) {
    throw new BadRequestException('Credenciales inválidas.');
  }
  const { email, password } = body as Record<string, unknown>;
  if (typeof email !== 'string' || typeof password !== 'string') {
    throw new BadRequestException('Credenciales inválidas.');
  }
  const normalized = email.trim().toLowerCase();
  // El PoC acepta direcciones ASCII; la contraseña conserva cada carácter recibido.
  if (normalized.length > 254 || !/^[a-z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-z0-9](?:[a-z0-9.-]*[a-z0-9])?\.[a-z]{2,}$/.test(normalized)) {
    throw new BadRequestException('Correo inválido.');
  }
  const length = Array.from(password).length;
  if (length < 12 || length > 128 || Buffer.byteLength(password, 'utf8') > 256) {
    throw new BadRequestException('La contraseña debe tener 12–128 caracteres y como máximo 256 bytes UTF-8.');
  }
  return { email: normalized, password };
}

export type SessionActor = Readonly<{ userId: string; sessionId: string }>;

@Injectable()
export class AuthService {
  private readonly dummySalt = randomBytes(16);
  private readonly dummyHash = randomBytes(64);
  private hashing = false;
  private attempts = 0;
  private windowStarted = Date.now();

  constructor(private readonly prisma: PrismaService) {}

  private async withHash<T>(work: () => Promise<T>): Promise<T> {
    // ponytail: límite global por proceso, 1 hash (~128 MiB) y sin cola; sustituir
    // por límites distribuidos antes de usar varios procesos o salir de loopback.
    if (Date.now() - this.windowStarted >= 60_000) {
      this.windowStarted = Date.now();
      this.attempts = 0;
    }
    if (++this.attempts > 60 || this.hashing) {
      throw new HttpException('Demasiados intentos. Reintenta más tarde.', 429);
    }
    this.hashing = true;
    try {
      return await work();
    } catch (error) {
      if (error instanceof HttpException) throw error;
      if (error instanceof Prisma.PrismaClientKnownRequestError && error.code === 'P2002') {
        throw new ConflictException('No se pudo registrar el correo.');
      }
      throw new ServiceUnavailableException('Servicio temporalmente no disponible.');
    } finally {
      this.hashing = false;
    }
  }

  async register(body: unknown) {
    return this.withHash(async () => {
      const { email, password } = credentials(body);
      const salt = randomBytes(16);
      const hash = await derive(password, salt);
      // Usuario y sesión se crean juntos: un fallo no deja un registro incompleto.
      return this.prisma.$transaction(async (tx) => {
        const user = await tx.user.create({
          data: { email, passwordHash: `${HASH_PREFIX}$${salt.toString('hex')}$${hash.toString('hex')}` },
          select: { id: true, email: true },
        });
        return this.newSession(tx, user);
      });
    });
  }

  async login(body: unknown) {
    return this.withHash(async () => {
      const { email, password } = credentials(body);
      const user = await this.prisma.user.findUnique({ where: { email } });
      const parsed = user ? HASH_FORMAT.exec(user.passwordHash) : null;
      const actual = await derive(password, parsed ? Buffer.from(parsed[1], 'hex') : this.dummySalt);
      const expected = parsed ? Buffer.from(parsed[2], 'hex') : this.dummyHash;
      const matches = timingSafeEqual(actual, expected);
      if (!user || !parsed || !matches) throw new UnauthorizedException('Credenciales inválidas.');
      return this.newSession(this.prisma, { id: user.id, email: user.email });
    });
  }

  private async newSession(db: Pick<Prisma.TransactionClient, 'authSession'>, user: { id: string; email: string }) {
    const token = randomBytes(32).toString('base64url');
    const expiresAt = new Date(Date.now() + SESSION_MS);
    await db.authSession.create({ data: { userId: user.id, tokenHash: tokenHash(token), expiresAt } });
    return { user, token, expiresAt: expiresAt.toISOString() };
  }

  async authenticate(authorization: unknown): Promise<SessionActor> {
    if (typeof authorization !== 'string' || !/^Bearer [A-Za-z0-9_-]{43}$/.test(authorization)) {
      throw new UnauthorizedException('Sesión inválida.');
    }
    try {
      const session = await this.prisma.authSession.findUnique({
        where: { tokenHash: tokenHash(authorization.slice(7)) },
        select: { id: true, userId: true, expiresAt: true, revokedAt: true },
      });
      if (!session || session.revokedAt || session.expiresAt.getTime() <= Date.now()) {
        throw new UnauthorizedException('Sesión inválida.');
      }
      return { userId: session.userId, sessionId: session.id };
    } catch (error) {
      if (error instanceof HttpException) throw error;
      throw new ServiceUnavailableException('Servicio temporalmente no disponible.');
    }
  }

  async logout(actor: SessionActor): Promise<void> {
    try {
      await this.prisma.authSession.updateMany({
        where: { id: actor.sessionId, userId: actor.userId, revokedAt: null }, data: { revokedAt: new Date() },
      });
    } catch {
      throw new ServiceUnavailableException('Servicio temporalmente no disponible.');
    }
  }
}
