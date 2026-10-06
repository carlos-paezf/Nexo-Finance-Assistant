import 'dotenv/config';
import 'reflect-metadata';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { NestExpressApplication } from '@nestjs/platform-express';

async function bootstrap() {
  const app = await NestFactory.create<NestExpressApplication>(AppModule, { bodyParser: false });
  app.use((request: { path: string }, response: { setHeader(name: string, value: string): void }, next: () => void) => {
    if (request.path.startsWith('/auth')) response.setHeader('Cache-Control', 'no-store');
    next();
  });
  app.useBodyParser('json', { limit: '8kb' });
  app.use((error: { type?: string }, _request: unknown,
    response: { status(code: number): { json(body: unknown): void } }, next: (error: unknown) => void) => {
    if (error.type === 'entity.parse.failed' || error.type === 'entity.too.large') {
      const statusCode = error.type === 'entity.too.large' ? 413 : 400;
      response.status(statusCode).json({ statusCode, message: 'Solicitud inválida.' });
    } else next(error);
  });
  app.enableCors();
  app.enableShutdownHooks();
  await app.listen(Number(process.env.PORT ?? 3000), '127.0.0.1');
}

void bootstrap();
