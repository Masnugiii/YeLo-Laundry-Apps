import { Controller, Get, Patch, Post, Query, Body } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { IsOptional } from 'class-validator';
import { ROLES } from '../auth/constants/roles.constant';
import { PERMISSIONS } from '../auth/constants/permissions.constant';
import { Permissions } from '../auth/decorators/permissions.decorator';
import { Roles } from '../auth/decorators/roles.decorator';
import { AdminDashboardService } from './admin-dashboard.service';
import { AdminSettingsService } from './admin-settings.service';
import { AuditLogService } from './audit-log.service';

class AuditQueryDto {
  @IsOptional()
  @Type(() => Number)
  page?: number;

  @IsOptional()
  @Type(() => Number)
  limit?: number;

  @IsOptional()
  module?: string;

  @IsOptional()
  action?: string;

  @IsOptional()
  search?: string;
}

@ApiTags('Admin')
@ApiBearerAuth('access-token')
@Roles(ROLES.OWNER, ROLES.MANAGER)
@Controller('admin')
export class AdminController {
  constructor(
    private readonly dashboardService: AdminDashboardService,
    private readonly auditLogService: AuditLogService,
    private readonly settingsService: AdminSettingsService,
  ) {}

  @Get('dashboard')
  @Permissions(PERMISSIONS.DASHBOARD)
  @ApiOperation({ summary: 'Get admin control center dashboard' })
  async getDashboard() {
    const data = await this.dashboardService.getDashboard();
    return {
      success: true,
      message: 'Admin dashboard loaded successfully',
      data,
    };
  }

  @Get('audit-logs')
  @Permissions(PERMISSIONS.REPORTS)
  @ApiOperation({ summary: 'List audit logs' })
  async getAuditLogs(@Query() query: AuditQueryDto) {
    const data = await this.auditLogService.findAll(query);
    return {
      success: true,
      message: 'Audit logs retrieved successfully',
      data,
    };
  }

  @Get('settings/company')
  @Permissions(PERMISSIONS.SETTINGS)
  @ApiOperation({ summary: 'Get company settings' })
  async getSettings() {
    const data = await this.settingsService.getCompanySettings();
    return {
      success: true,
      message: 'Company settings retrieved successfully',
      data,
    };
  }

  @Patch('settings/company')
  @Permissions(PERMISSIONS.SETTINGS)
  @ApiOperation({ summary: 'Update company settings' })
  async updateSettings(@Body() body: Record<string, unknown>) {
    const data = await this.settingsService.updateCompanySettings(body);
    return {
      success: true,
      message: 'Company settings updated successfully',
      data,
    };
  }
}
