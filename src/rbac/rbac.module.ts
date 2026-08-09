import { Module } from '@nestjs/common';
import { RbacSampleController } from './rbac-sample.controller';

@Module({
  controllers: [RbacSampleController],
})
export class RbacModule {}
