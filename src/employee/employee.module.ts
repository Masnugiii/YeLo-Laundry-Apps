import { Module } from '@nestjs/common';
import { EmployeeController } from './employee.controller';
import { EmployeeRoleController } from './employee-role.controller';
import { EmployeeRoleRepository } from './employee-role.repository';
import { EmployeeRoleService } from './employee-role.service';
import { EmployeeRepository } from './employee.repository';
import { EmployeeService } from './employee.service';
import { ProfileController } from './profile.controller';
import { ProfileService } from './profile.service';

@Module({
  controllers: [
    EmployeeController,
    EmployeeRoleController,
    ProfileController,
  ],
  providers: [
    EmployeeService,
    EmployeeRepository,
    EmployeeRoleService,
    EmployeeRoleRepository,
    ProfileService,
  ],
  exports: [
    EmployeeService,
    EmployeeRepository,
    EmployeeRoleService,
    EmployeeRoleRepository,
    ProfileService,
  ],
})
export class EmployeeModule {}
