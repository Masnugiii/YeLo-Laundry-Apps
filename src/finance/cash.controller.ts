import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Post,
  Query,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiBody,
  ApiOperation,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import { ROLES } from '../auth/constants/roles.constant';
import { PERMISSIONS } from '../auth/constants/permissions.constant';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { Permissions } from '../auth/decorators/permissions.decorator';
import { Roles } from '../auth/decorators/roles.decorator';
import { AuthenticatedEmployee } from '../auth/interfaces/jwt-payload.interface';
import { ApiSuccessResponse } from '../common/interfaces/api-response.interface';
import { CashService } from './cash.service';
import {
  AdjustIncomeDto,
  CashTransactionDto,
  CloseShiftDto,
  CreateVoucherDto,
  DailyClosingQueryDto,
  OpenShiftDto,
  ValidateVoucherDto,
} from './dto/cash.dto';
import {
  CashShiftRecord,
  DailyClosingRecord,
} from './utils/cash-shift-meta.util';
import { VoucherRecord } from './utils/voucher-meta.util';

const VIEW_ROLES = [ROLES.OWNER, ROLES.MANAGER, ROLES.CASHIER, ROLES.OPERATOR] as const;
const CASHIER_ROLES = [ROLES.OWNER, ROLES.MANAGER, ROLES.CASHIER] as const;
const OWNER_ROLES = [ROLES.OWNER] as const;
const VOUCHER_ROLES = [ROLES.OWNER, ROLES.MANAGER] as const;

@ApiTags('Cash Register')
@ApiBearerAuth('access-token')
@Permissions(PERMISSIONS.FINANCE)
@Controller('finance/cash')
export class CashController {
  constructor(private readonly cashService: CashService) {}

  @Get('shift')
  @Roles(...VIEW_ROLES)
  @ApiOperation({ summary: 'Get active cash shift' })
  getActiveShift(): Promise<ApiSuccessResponse<CashShiftRecord | null>> {
    return this.cashService.getActiveShift();
  }

  @Post('shift/open')
  @Roles(...CASHIER_ROLES)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Open cash register shift' })
  @ApiBody({
    type: OpenShiftDto,
    examples: {
      default: {
        summary: 'Open morning shift',
        value: { openingCash: 500000, notes: 'Morning shift' },
      },
    },
  })
  openShift(
    @Body() dto: OpenShiftDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ): Promise<ApiSuccessResponse<CashShiftRecord>> {
    return this.cashService.openShift(dto, user.employeeId);
  }

  @Post('shift/close')
  @Roles(...CASHIER_ROLES)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Close cash register shift' })
  @ApiBody({
    type: CloseShiftDto,
    examples: {
      default: {
        summary: 'Close shift',
        value: { actualCash: 1250000, notes: 'End of day' },
      },
    },
  })
  closeShift(
    @Body() dto: CloseShiftDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ): Promise<ApiSuccessResponse<CashShiftRecord>> {
    return this.cashService.closeShift(dto, user.employeeId);
  }

  @Post('transaction')
  @Roles(...CASHIER_ROLES)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Record cash in or cash out' })
  @ApiBody({ type: CashTransactionDto })
  recordTransaction(
    @Body() dto: CashTransactionDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ): Promise<ApiSuccessResponse<CashShiftRecord>> {
    return this.cashService.recordCashTransaction(dto, user.employeeId);
  }

  @Get('daily-closing')
  @Roles(...VIEW_ROLES)
  @ApiOperation({ summary: 'Generate or retrieve daily closing report' })
  dailyClosing(
    @Query() query: DailyClosingQueryDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ): Promise<ApiSuccessResponse<DailyClosingRecord>> {
    return this.cashService.generateDailyClosing(query, user.employeeId);
  }

  @Post('income/adjust')
  @Roles(...OWNER_ROLES)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Manual income adjustment (OWNER only)' })
  @ApiBody({ type: AdjustIncomeDto })
  adjustIncome(
    @Body() dto: AdjustIncomeDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ): Promise<ApiSuccessResponse<{ amount: number; description: string }>> {
    return this.cashService.adjustIncome(
      dto,
      user.employeeId,
      user.roles,
    );
  }

  @Post('voucher/validate')
  @Roles(...VIEW_ROLES)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Validate voucher code' })
  @ApiBody({ type: ValidateVoucherDto })
  validateVoucher(
    @Body() dto: ValidateVoucherDto,
  ): Promise<
    ApiSuccessResponse<{
      valid: boolean;
      code: string;
      discountType: string;
      discountValue: number;
      estimatedDiscount: number;
      remainingUsage: number;
      expiresAt: string;
    }>
  > {
    return this.cashService.validateVoucher(dto);
  }

  @Post('voucher')
  @Roles(...VOUCHER_ROLES)
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Create voucher' })
  @ApiBody({ type: CreateVoucherDto })
  createVoucher(
    @Body() dto: CreateVoucherDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ): Promise<ApiSuccessResponse<VoucherRecord>> {
    return this.cashService.createVoucher(dto, user.employeeId, user.roles);
  }
}
