import 'reflect-metadata';
import { Logger, RequestMethod, ValidationPipe } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { NestFactory } from '@nestjs/core';
import { NestExpressApplication } from '@nestjs/platform-express';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import compression from 'compression';
import { json, urlencoded } from 'express';
import helmet from 'helmet';
import { join } from 'path';
import { Logger as PinoLogger } from 'nestjs-pino';
import { AppModule } from './app.module';
import { PrismaService } from './database/prisma/prisma.service';

function createBootLogger() {
  const started = Date.now();
  return (message: string) => {
    console.log(`[BOOT] ${message} (+${Date.now() - started}ms)`);
  };
}

async function bootstrap() {
  const boot = createBootLogger();
  const port = Number(process.env.PORT || process.env.APP_PORT || 3000);
  const host = '0.0.0.0';

  boot(
    `env PORT=${process.env.PORT ?? '(unset)'} APP_PORT=${process.env.APP_PORT ?? '(unset)'} -> ${host}:${port}`,
  );

  boot('NestFactory.create start (ConfigModule, Prisma onModuleInit, route mapping)');
  const app = await NestFactory.create<NestExpressApplication>(AppModule, {
    bufferLogs: true,
  });
  boot('NestFactory.create finished');

  const configService = app.get(ConfigService);
  const logger = app.get(PinoLogger);
  app.useLogger(logger);
  boot('logger attached');

  const apiPrefix = configService.get<string>('app.apiPrefix', 'api/v1');
  const corsOrigins = configService.get<string[]>('app.corsOrigins', []);
  const bodyLimit = configService.get<string>('app.bodyLimit', '10mb');
  const appName = configService.get<string>('app.name', 'YeLo Laundry ERP');

  // CORS must be registered before Helmet/body parsers so preflight and error
  // responses (4xx/5xx) still receive Access-Control-Allow-* headers.
  app.enableCors({
    origin: corsOrigins,
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'Accept'],
  });
  boot(`CORS attached (${corsOrigins.length} origin(s))`);

  // cross-origin API clients (Vercel Admin Web) must not get CORP: same-origin.
  app.use(
    helmet({
      crossOriginResourcePolicy: { policy: 'cross-origin' },
    }),
  );
  app.use(compression());
  app.use(json({ limit: bodyLimit }));
  app.use(urlencoded({ extended: true, limit: bodyLimit }));
  boot('middleware attached');

  app.enableShutdownHooks();
  boot('shutdown hooks attached');

  app.setGlobalPrefix(apiPrefix, {
    exclude: [
      { path: '/', method: RequestMethod.GET },
      { path: 'favicon.ico', method: RequestMethod.GET },
      { path: 'health', method: RequestMethod.GET },
    ],
  });
  boot(`global prefix /${apiPrefix}`);

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      transform: true,
      forbidNonWhitelisted: true,
      transformOptions: {
        enableImplicitConversion: true,
      },
    }),
  );
  boot('validation pipe attached');

  const prismaService = app.get(PrismaService);
  prismaService.enableShutdownHooks(app);
  boot('Prisma shutdown hook attached');

  boot(`Listening on ${host}:${port}`);
  await app.listen(port, host);
  boot(`Server is listening on ${host}:${port}`);
  Logger.log(`Server listening on ${host}:${port}`, 'Bootstrap');
  Logger.log(`${appName} is running on http://${host}:${port}`, 'Bootstrap');
  Logger.log(`API prefix: /${apiPrefix}`, 'Bootstrap');
  Logger.log(`API base: http://${host}:${port}/${apiPrefix}`, 'Bootstrap');
  Logger.log(`Health check: http://${host}:${port}/health`, 'Bootstrap');

  app.useStaticAssets(join(process.cwd(), 'uploads'), {
    prefix: `/${apiPrefix}/uploads`,
  });
  boot('static assets attached');

  const swaggerConfig = new DocumentBuilder()
    .setTitle('Yelo Laundry ERP API')
    .setDescription('Backend API Documentation')
    .setVersion('1.0.0')
    .addBearerAuth(
      {
        type: 'http',
        scheme: 'bearer',
        bearerFormat: 'JWT',
        name: 'Authorization',
        description: 'Enter JWT access token',
        in: 'header',
      },
      'access-token',
    )
    .build();

  const document = SwaggerModule.createDocument(app, swaggerConfig);
  SwaggerModule.setup('api', app, document, {
    swaggerOptions: {
      persistAuthorization: true,
    },
  });
  boot('Swagger attached');
}

bootstrap().catch((error: Error) => {
  console.error(`Application failed to start: ${error.message}`, error.stack);
  process.exit(1);
});
