import { Controller, Get, Query } from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOperation,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import { ROLES } from '../auth/constants/roles.constant';
import { PERMISSIONS } from '../auth/constants/permissions.constant';
import { Permissions } from '../auth/decorators/permissions.decorator';
import { Roles } from '../auth/decorators/roles.decorator';
import { ApiSuccessResponse } from '../common/interfaces/api-response.interface';
import {
  FinanceReportQueryDto,
  FinanceRevenueQueryDto,
} from './dto/report.dto';
import {
  CashFlowReport,
  FinanceDashboard,
  FinancialSummary,
  PaginatedRevenue,
  PaymentHistorySummary,
  ProfitLossReport,
  ReportService,
} from './report.service';

const VIEW_ROLES = [ROLES.OWNER, ROLES.MANAGER, ROLES.CASHIER, ROLES.OPERATOR] as const;

@ApiTags('Finance Reports')
@ApiBearerAuth('access-token')
@Permissions(PERMISSIONS.FINANCE)
@Controller('finance')
export class ReportController {
  constructor(private readonly reportService: ReportService) {}

  @Get('dashboard')
  @Roles(...VIEW_ROLES)
  @ApiOperation({ summary: 'Get finance dashboard metrics' })
  getDashboard(): Promise<ApiSuccessResponse<FinanceDashboard>> {
    return this.reportService.getDashboard();
  }

  @Get('revenue')
  @Roles(...VIEW_ROLES)
  @ApiOperation({ summary: 'List revenue records from payments' })
  getRevenue(
    @Query() query: FinanceRevenueQueryDto,
  ): Promise<ApiSuccessResponse<PaginatedRevenue>> {
    return this.reportService.getRevenue(query);
  }

  @Get('profit-loss')
  @Roles(...VIEW_ROLES)
  @ApiOperation({ summary: 'Get profit and loss report' })
  getProfitLoss(
    @Query() query: FinanceReportQueryDto,
  ): Promise<ApiSuccessResponse<ProfitLossReport>> {
    return this.reportService.getProfitLoss(query);
  }

  @Get('cash-flow')
  @Roles(...VIEW_ROLES)
  @ApiOperation({ summary: 'Get cash flow report with running balance' })
  getCashFlow(
    @Query() query: FinanceReportQueryDto,
  ): Promise<ApiSuccessResponse<CashFlowReport>> {
    return this.reportService.getCashFlow(query);
  }

  @Get('payment-history')
  @Roles(...VIEW_ROLES)
  @ApiOperation({ summary: 'Get payment method history summary' })
  getPaymentHistory(
    @Query() query: FinanceReportQueryDto,
  ): Promise<ApiSuccessResponse<PaymentHistorySummary>> {
    return this.reportService.getPaymentHistory(query);
  }

  @Get('summary')
  @Roles(...VIEW_ROLES)
  @ApiOperation({
    summary:
      'Get consolidated financial summary (revenue, expense, payment, wallet, P&L)',
  })
  @ApiResponse({ status: 200, description: 'Financial summary retrieved' })
  getFinancialSummary(
    @Query() query: FinanceReportQueryDto,
  ): Promise<ApiSuccessResponse<FinancialSummary>> {
    return this.reportService.getFinancialSummary(query);
  }
}
