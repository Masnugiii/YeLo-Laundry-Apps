import 'reflect-metadata';
import { Logger, ValidationPipe } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { NestFactory } from '@nestjs/core';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import compression from 'compression';
import { json, urlencoded } from 'express';
import helmet from 'helmet';
import { Logger as PinoLogger } from 'nestjs-pino';
import { AppModule } from './app.module';
import { PrismaService } from './database/prisma/prisma.service';

async function bootstrap() {
  const app = await NestFactory.create(AppModule, {
    bufferLogs: true,
  });

  const configService = app.get(ConfigService);
  const logger = app.get(PinoLogger);
  app.useLogger(logger);

  const port = configService.get<number>('app.port', 3000);
  const apiPrefix = configService.get<string>('app.apiPrefix', 'api/v1');
  const corsOrigins = configService.get<string[]>('app.corsOrigins', []);
  const bodyLimit = configService.get<string>('app.bodyLimit', '10mb');
  const appName = configService.get<string>('app.name', 'Yelo Laundry ERP');

  app.use(helmet());
  app.use(compression());
  app.use(json({ limit: bodyLimit }));
  app.use(urlencoded({ extended: true, limit: bodyLimit }));

  app.enableCors({
    origin: corsOrigins,
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'Accept'],
  });

  app.enableShutdownHooks();

  app.setGlobalPrefix(apiPrefix, {
    exclude: ['health'],
  });

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

  const prismaService = app.get(PrismaService);
  prismaService.enableShutdownHooks(app);

  await app.listen(port);

  Logger.log(`${appName} is running on port ${port}`, 'Bootstrap');
  Logger.log(`API prefix: /${apiPrefix}`, 'Bootstrap');
  Logger.log(`Swagger UI: http://localhost:${port}/api`, 'Bootstrap');
  Logger.log(`Health check: http://localhost:${port}/health`, 'Bootstrap');
}

bootstrap().catch((error: Error) => {
  console.error(`Application failed to start: ${error.message}`, error.stack);
  process.exit(1);
});
