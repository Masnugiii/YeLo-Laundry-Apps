import { Module } from '@nestjs/common';
import { HealthController } from './health.controller';
import { HealthService } from './health.service';
import { RootController } from './root.controller';

@Module({
  controllers: [RootController, HealthController],
  providers: [HealthService],
})
export class HealthModule {}
