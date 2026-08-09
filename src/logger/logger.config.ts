import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Params } from 'nestjs-pino';

@Injectable()
export class LoggerConfigService {
  constructor(private readonly configService: ConfigService) {}

  createPinoConfig(): Params {
    const isProduction = this.configService.get<string>('app.env') === 'production';

    return {
      pinoHttp: {
        level: isProduction ? 'info' : 'debug',
        transport: isProduction
          ? undefined
          : {
              target: 'pino-pretty',
              options: {
                singleLine: true,
                colorize: true,
                translateTime: 'SYS:standard',
              },
            },
        autoLogging: true,
        customProps: () => ({
          context: 'HTTP',
        }),
        serializers: {
          req: (req) => ({
            method: req.method,
            url: req.url,
          }),
          res: (res) => ({
            statusCode: res.statusCode,
          }),
        },
      },
    };
  }
}
