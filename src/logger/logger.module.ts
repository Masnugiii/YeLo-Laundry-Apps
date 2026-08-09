import { Global, Module } from '@nestjs/common';
import { LoggerModule as PinoLoggerModule } from 'nestjs-pino';
import { LoggerConfigService } from './logger.config';

@Global()
@Module({
  imports: [
    PinoLoggerModule.forRootAsync({
      inject: [LoggerConfigService],
      useFactory: (loggerConfig: LoggerConfigService) =>
        loggerConfig.createPinoConfig(),
    }),
  ],
  providers: [LoggerConfigService],
  exports: [LoggerConfigService],
})
export class LoggerModule {}
