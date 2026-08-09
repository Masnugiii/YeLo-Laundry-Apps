import { Body, Controller, Get, Param, ParseUUIDPipe, Patch, Post, Query } from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOperation,
  ApiTags,
} from '@nestjs/swagger';
import { ROLES } from '../auth/constants/roles.constant';
import { PERMISSIONS } from '../auth/constants/permissions.constant';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { Permissions } from '../auth/decorators/permissions.decorator';
import { Roles } from '../auth/decorators/roles.decorator';
import { AuthenticatedEmployee } from '../auth/interfaces/jwt-payload.interface';
import {
  ApprovePayrollDto,
  CalculatePayrollDto,
  PayPayrollDto,
  PayrollQueryDto,
  PayrollReportQueryDto,
  UpdatePayrollSettingsDto,
} from './payroll.dto';
import { PayrollService } from './payroll.service';
import { PayrollSettings } from './payroll.types';

const VIEW_ROLES = [ROLES.OWNER, ROLES.MANAGER] as const;
const WRITE_ROLES = [ROLES.OWNER, ROLES.MANAGER] as const;

@ApiTags('Payroll')
@ApiBearerAuth('access-token')
@Permissions(PERMISSIONS.FINANCE, PERMISSIONS.SETTINGS)
@Roles(...VIEW_ROLES)
@Controller('payroll')
export class PayrollController {
  constructor(private readonly payrollService: PayrollService) {}

  @Get('dashboard')
  @ApiOperation({ summary: 'Get payroll dashboard metrics' })
  getDashboard() {
    return this.payrollService.getDashboard().then((data) => ({
      success: true,
      message: 'Payroll dashboard retrieved successfully',
      data,
    }));
  }

  @Get('settings')
  @ApiOperation({ summary: 'Get payroll salary rules' })
  getSettings() {
    return this.payrollService.getSettings().then((data) => ({
      success: true,
      message: 'Payroll settings retrieved successfully',
      data,
    }));
  }

  @Patch('settings')
  @Roles(...WRITE_ROLES)
  @ApiOperation({ summary: 'Update payroll salary rules' })
  updateSettings(
    @Body() dto: UpdatePayrollSettingsDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ) {
    return this.payrollService
      .updateSettings(dto as Partial<PayrollSettings>, user.employeeId)
      .then((data) => ({
        success: true,
        message: 'Payroll settings updated successfully',
        data,
      }));
  }

  @Get()
  @ApiOperation({ summary: 'List payroll records' })
  findAll(@Query() query: PayrollQueryDto) {
    return this.payrollService.findAll(query).then((data) => ({
      success: true,
      message: 'Payroll records retrieved successfully',
      data,
    }));
  }

  @Get('report')
  @ApiOperation({ summary: 'Get payroll report' })
  getReport(@Query() query: PayrollReportQueryDto) {
    return this.payrollService.getReport(query).then((data) => ({
      success: true,
      message: 'Payroll report retrieved successfully',
      data,
    }));
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get payroll record detail' })
  findOne(@Param('id', ParseUUIDPipe) id: string) {
    return this.payrollService.findOne(id).then((data) => ({
      success: true,
      message: 'Payroll record retrieved successfully',
      data,
    }));
  }

  @Post('calculate')
  @Roles(...WRITE_ROLES)
  @ApiOperation({ summary: 'Calculate payroll for a period' })
  calculate(
    @Body() dto: CalculatePayrollDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ) {
    return this.payrollService
      .calculate(dto, user.employeeId)
      .then((data) => ({
        success: true,
        message: 'Payroll calculated successfully',
        data,
      }));
  }

  @Post('approve')
  @Roles(ROLES.OWNER)
  @ApiOperation({ summary: 'Approve payroll records (OWNER only)' })
  approve(
    @Body() dto: ApprovePayrollDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ) {
    return this.payrollService
      .approve(dto, user.employeeId, user.roles)
      .then((data) => ({
        success: true,
        message: 'Payroll approved successfully',
        data,
      }));
  }

  @Post('pay')
  @Roles(...WRITE_ROLES)
  @ApiOperation({ summary: 'Mark payroll as paid' })
  pay(@Body() dto: PayPayrollDto, @CurrentUser() user: AuthenticatedEmployee) {
    return this.payrollService.pay(dto, user.employeeId).then((data) => ({
      success: true,
      message: 'Payroll payment recorded successfully',
      data,
    }));
  }

  @Post('generate')
  @Roles(...WRITE_ROLES)
  @ApiOperation({ summary: 'Deprecated alias for calculate' })
  generate(
    @Body() dto: CalculatePayrollDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ) {
    return this.calculate(dto, user);
  }
}
