import { Module } from '@nestjs/common';
import { PermissionController } from './permission.controller';
import { PermissionRepository } from './permission.repository';
import { PermissionService } from './permission.service';
import { RoleController } from './role.controller';
import { RolePermissionController } from './role-permission.controller';

@Module({
  controllers: [PermissionController, RoleController, RolePermissionController],
  providers: [PermissionService, PermissionRepository],
  exports: [PermissionService, PermissionRepository],
})
export class PermissionModule {}
