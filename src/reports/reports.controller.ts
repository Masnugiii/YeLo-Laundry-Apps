import { Controller, Get, Query } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { ROLES } from '../auth/constants/roles.constant';
import { PERMISSIONS } from '../auth/constants/permissions.constant';
import { Permissions } from '../auth/decorators/permissions.decorator';
import { Roles } from '../auth/decorators/roles.decorator';
import { ReportQueryDto } from './dto/report-query.dto';
import { ReportsService } from './reports.service';

const BI_ROLES = [ROLES.OWNER, ROLES.MANAGER] as const;
const OWNER_ONLY_ROLES = [ROLES.OWNER] as const;

@ApiTags('Reports')
@ApiBearerAuth('access-token')
@Permissions(PERMISSIONS.REPORTS)
@Roles(...BI_ROLES)
@Controller('reports')
export class ReportsController {
  constructor(private readonly reportsService: ReportsService) {}

  @Get('dashboard')
  @ApiOperation({ summary: 'Executive BI dashboard' })
  async getDashboard(@Query() query: ReportQueryDto) {
    const data = await this.reportsService.getExecutiveDashboard(query);
    return {
      success: true,
      message: 'Executive dashboard retrieved successfully',
      data,
    };
  }

  @Get('sales')
  @ApiOperation({ summary: 'Sales report' })
  async getSales(@Query() query: ReportQueryDto) {
    const data = await this.reportsService.getSalesReport(query);
    return {
      success: true,
      message: 'Sales report retrieved successfully',
      data,
    };
  }

  @Get('customers')
  @ApiOperation({ summary: 'Customer analytics' })
  async getCustomers(@Query() query: ReportQueryDto) {
    const data = await this.reportsService.getCustomerAnalytics(query);
    return {
      success: true,
      message: 'Customer analytics retrieved successfully',
      data,
    };
  }

  @Get('production')
  @ApiOperation({ summary: 'Production analytics' })
  async getProduction(@Query() query: ReportQueryDto) {
    const data = await this.reportsService.getProductionAnalytics(query);
    return {
      success: true,
      message: 'Production analytics retrieved successfully',
      data,
    };
  }

  @Get('employees')
  @ApiOperation({ summary: 'Employee performance report' })
  async getEmployees(@Query() query: ReportQueryDto) {
    const data = await this.reportsService.getEmployeePerformance(query);
    return {
      success: true,
      message: 'Employee performance report retrieved successfully',
      data,
    };
  }

  @Get('finance')
  @ApiOperation({ summary: 'Finance analytics' })
  async getFinance(@Query() query: ReportQueryDto) {
    const data = await this.reportsService.getFinanceAnalytics(query);
    return {
      success: true,
      message: 'Finance analytics retrieved successfully',
      data,
    };
  }

  @Get('payroll')
  @ApiOperation({ summary: 'Payroll analytics' })
  async getPayroll(@Query() query: ReportQueryDto) {
    const data = await this.reportsService.getPayrollAnalytics(query);
    return {
      success: true,
      message: 'Payroll analytics retrieved successfully',
      data,
    };
  }

  @Get('wallet')
  @ApiOperation({ summary: 'Wallet analytics' })
  async getWallet(@Query() query: ReportQueryDto) {
    const data = await this.reportsService.getWalletAnalytics(query);
    return {
      success: true,
      message: 'Wallet analytics retrieved successfully',
      data,
    };
  }

  @Get('membership')
  @ApiOperation({ summary: 'Membership analytics' })
  async getMembership(@Query() query: ReportQueryDto) {
    const data = await this.reportsService.getMembershipAnalytics(query);
    return {
      success: true,
      message: 'Membership analytics retrieved successfully',
      data,
    };
  }

  @Get('forecast')
  @Roles(...OWNER_ONLY_ROLES)
  @ApiOperation({ summary: 'Revenue and operations forecast (Owner only)' })
  async getForecast(@Query() query: ReportQueryDto) {
    const data = await this.reportsService.getForecast(query);
    return {
      success: true,
      message: 'Forecast retrieved successfully',
      data,
    };
  }

  @Get('scheduler')
  @Roles(...OWNER_ONLY_ROLES)
  @ApiOperation({ summary: 'Report scheduler architecture (Owner only)' })
  getScheduler() {
    const data = this.reportsService.getSchedulerArchitecture();
    return {
      success: true,
      message: 'Report scheduler architecture retrieved successfully',
      data,
    };
  }
}
