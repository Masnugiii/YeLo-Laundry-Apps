import { Module } from '@nestjs/common';
import { PermissionController } from './permission.controller';
import { PermissionRepository } from './permission.repository';
import { PermissionService } from './permission.service';
import { RolePermissionController } from './role-permission.controller';

@Module({
  controllers: [PermissionController, RolePermissionController],
  providers: [PermissionService, PermissionRepository],
  exports: [PermissionService, PermissionRepository],
})
export class PermissionModule {}
