import {
  Body,
  Controller,
  Get,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
  Query,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { ROLES } from '../auth/constants/roles.constant';
import { PERMISSIONS } from '../auth/constants/permissions.constant';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { Permissions } from '../auth/decorators/permissions.decorator';
import { Roles } from '../auth/decorators/roles.decorator';
import { AuthenticatedEmployee } from '../auth/interfaces/jwt-payload.interface';
import { toCustomerWalletTransactionItem } from '../customer/customer-wallet.mapper';
import { CustomerWalletRepository } from '../customer/customer-wallet.repository';
import { CustomerWalletService } from '../customer/customer-wallet.service';
import {
  WalletTransactionQueryDto,
  WalletTransactionTypeFilter,
} from '../customer/dto/wallet-transaction-query.dto';
import {
  LoyaltyReportQueryDto,
  ManualBonusDto,
  ReverseTransactionDto,
  RewardHistoryQueryDto,
  RewardQueryDto,
  UpdateLoyaltySettingsDto,
  WalletAdjustmentDto,
  WalletHistoryQueryDto,
  WalletQueryDto,
  WalletRefundDto,
  WalletTopupDto,
} from './loyalty.dto';
import { LoyaltyReportService } from './loyalty-report.service';
import { LoyaltySettingsService } from './loyalty-settings.service';
import { MembershipService } from './membership.service';
import { RewardService } from './reward.service';
import { VoucherService } from './voucher.service';
import { CreateLoyaltyVoucherDto, VoucherQueryDto } from './loyalty.dto';
import { WalletLoyaltyService } from './wallet-loyalty.service';
import { CustomerLoyaltyService } from './customer-loyalty.service';

const VIEW_ROLES = [ROLES.OWNER, ROLES.MANAGER, ROLES.CASHIER] as const;
const MUTATION_ROLES = [ROLES.OWNER, ROLES.CASHIER] as const;

@ApiTags('Wallet')
@ApiBearerAuth('access-token')
@Permissions(PERMISSIONS.WALLET)
@Roles(...VIEW_ROLES)
@Controller('wallet')
export class WalletController {
  constructor(
    private readonly walletLoyaltyService: WalletLoyaltyService,
    private readonly customerWalletService: CustomerWalletService,
    private readonly walletRepository: CustomerWalletRepository,
  ) {}

  @Get()
  @ApiOperation({ summary: 'Get wallet dashboard or customer wallet summary' })
  getWallet(@Query() query: WalletQueryDto) {
    if (query.customerId) {
      return this.customerWalletService.getWallet(query.customerId);
    }
    return this.walletLoyaltyService.getDashboard().then((data) => ({
      success: true,
      message: 'Wallet dashboard retrieved successfully',
      data,
    }));
  }

  @Get('history')
  @ApiOperation({ summary: 'Get wallet transaction history' })
  async getHistory(@Query() query: WalletHistoryQueryDto) {
    if (!query.customerId) {
      const page = query.page ?? 1;
      const limit = query.limit ?? 25;
      const [transactions, total] = await this.walletRepository.findAllTransactions({
        page,
        limit,
        type: query.type as WalletTransactionTypeFilter | undefined,
        dateFrom: query.dateFrom,
        dateTo: query.dateTo,
      });
      return {
        success: true,
        message: 'Wallet history retrieved successfully',
        data: {
          items: transactions.map(toCustomerWalletTransactionItem),
          meta: {
            page,
            limit,
            total,
            totalPages: Math.ceil(total / limit) || 1,
          },
        },
      };
    }

    const walletQuery = new WalletTransactionQueryDto();
    walletQuery.page = query.page;
    walletQuery.limit = query.limit;
    walletQuery.dateFrom = query.dateFrom;
    walletQuery.dateTo = query.dateTo;
    if (query.type) {
      walletQuery.type = query.type as WalletTransactionTypeFilter;
    }
    return this.customerWalletService.getTransactions(query.customerId, walletQuery);
  }

  @Post('topup')
  @Roles(...MUTATION_ROLES)
  @ApiOperation({ summary: 'Top up customer wallet' })
  async topup(
    @Body() dto: WalletTopupDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ) {
    const result = await this.walletLoyaltyService.topupWithCashflow(
      dto.customerId,
      dto.amount,
      dto.notes,
      user.employeeId,
    );
    return {
      success: true,
      message: 'Wallet top-up successful',
      data: result,
    };
  }

  @Post('adjustment')
  @Roles(ROLES.OWNER)
  @ApiOperation({ summary: 'Manual wallet adjustment (OWNER only)' })
  async adjustment(
    @Body() dto: WalletAdjustmentDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ) {
    const result = await this.walletLoyaltyService.adjust(
      dto.customerId,
      dto.amount,
      dto.direction,
      dto.notes,
      user.employeeId,
    );
    return {
      success: true,
      message: 'Wallet adjustment successful',
      data: result,
    };
  }

  @Post('refund')
  @Roles(...MUTATION_ROLES)
  @ApiOperation({ summary: 'Refund to customer wallet' })
  async refund(
    @Body() dto: WalletRefundDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ) {
    const result = await this.walletLoyaltyService.refund(
      dto.customerId,
      dto.amount,
      dto.notes,
      user.employeeId,
      dto.referenceId,
    );
    return {
      success: true,
      message: 'Wallet refund successful',
      data: result,
    };
  }

  @Post('reverse')
  @Roles(ROLES.OWNER)
  @ApiOperation({ summary: 'Reverse wallet transaction (OWNER only)' })
  async reverse(
    @Body() dto: ReverseTransactionDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ) {
    const result = await this.walletLoyaltyService.reverseTransaction(
      dto.transactionId,
      user.employeeId,
    );
    return {
      success: true,
      message: 'Transaction reversed successfully',
      data: result,
    };
  }
}

@ApiTags('Reward')
@ApiBearerAuth('access-token')
@Permissions(PERMISSIONS.LOYALTY)
@Roles(...VIEW_ROLES)
@Controller('reward')
export class RewardController {
  constructor(private readonly rewardService: RewardService) {}

  @Get()
  getReward(@Query() query: RewardQueryDto) {
    if (!query.customerId) {
      return {
        success: true,
        message: 'Reward summary requires customerId',
        data: null,
      };
    }
    return this.rewardService.getSummary(query.customerId).then((data) => ({
      success: true,
      message: 'Reward summary retrieved successfully',
      data,
    }));
  }

  @Get('history')
  getHistory(@Query() query: RewardHistoryQueryDto) {
    return this.rewardService.getHistory({
      ...query,
      source: query.source as import('@prisma/client').RewardPointSource | undefined,
    }).then((data) => ({
      success: true,
      message: 'Reward history retrieved successfully',
      data,
    }));
  }

  @Post('bonus')
  @Roles(ROLES.OWNER, ROLES.MANAGER)
  addManualBonus(
    @Body() dto: ManualBonusDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ) {
    return this.rewardService
      .addManualBonus(
        dto.customerId,
        dto.point,
        dto.description ?? 'Manual bonus',
        user.employeeId,
      )
      .then((data) => ({
        success: true,
        message: 'Manual bonus added successfully',
        data,
      }));
  }
}

@ApiTags('Membership')
@ApiBearerAuth('access-token')
@Permissions(PERMISSIONS.LOYALTY)
@Roles(...VIEW_ROLES)
@Controller('membership')
export class MembershipController {
  constructor(private readonly membershipService: MembershipService) {}

  @Get()
  getMembership(@Query('customerId', ParseUUIDPipe) customerId: string) {
    return this.membershipService.getMembership(customerId).then((data) => ({
      success: true,
      message: 'Membership retrieved successfully',
      data,
    }));
  }
}

@ApiTags('Voucher')
@ApiBearerAuth('access-token')
@Permissions(PERMISSIONS.LOYALTY)
@Roles(...VIEW_ROLES)
@Controller('voucher')
export class VoucherController {
  constructor(private readonly voucherService: VoucherService) {}

  @Get()
  findAll(@Query() query: VoucherQueryDto) {
    return this.voucherService.findAll(query).then((data) => ({
      success: true,
      message: 'Vouchers retrieved successfully',
      data,
    }));
  }

  @Get(':id')
  findOne(@Param('id', ParseUUIDPipe) id: string) {
    return this.voucherService.findOne(id).then((data) => ({
      success: true,
      message: 'Voucher retrieved successfully',
      data,
    }));
  }

  @Post()
  @Roles(ROLES.OWNER, ROLES.MANAGER)
  create(@Body() dto: CreateLoyaltyVoucherDto) {
    return this.voucherService.create(dto).then((data) => ({
      success: true,
      message: 'Voucher created successfully',
      data,
    }));
  }
}

@ApiTags('Loyalty')
@ApiBearerAuth('access-token')
@Permissions(PERMISSIONS.LOYALTY)
@Roles(ROLES.OWNER, ROLES.MANAGER)
@Controller('loyalty')
export class LoyaltySettingsController {
  constructor(
    private readonly settingsService: LoyaltySettingsService,
    private readonly reportService: LoyaltyReportService,
  ) {}

  @Get('settings')
  getSettings() {
    return this.settingsService.getSettings().then((data) => ({
      success: true,
      message: 'Loyalty settings retrieved successfully',
      data,
    }));
  }

  @Patch('settings')
  @Roles(ROLES.OWNER)
  updateSettings(
    @Body() dto: UpdateLoyaltySettingsDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ) {
    return this.settingsService
      .updateSettings(dto as Partial<import('./loyalty.types').LoyaltySettings>, user.employeeId)
      .then((data) => ({
        success: true,
        message: 'Loyalty settings updated successfully',
        data,
      }));
  }

  @Get('report')
  getReport(@Query() query: LoyaltyReportQueryDto) {
    return this.reportService.getReport(query.reportType).then((data) => ({
      success: true,
      message: 'Loyalty report retrieved successfully',
      data,
    }));
  }
}

@ApiTags('Customer Loyalty')
@ApiBearerAuth('access-token')
@Permissions(PERMISSIONS.LOYALTY, PERMISSIONS.CUSTOMERS)
@Roles(...VIEW_ROLES)
@Controller('customers/:customerId/loyalty')
export class CustomerLoyaltyController {
  constructor(private readonly customerLoyaltyService: CustomerLoyaltyService) {}

  @Get()
  getCustomerLoyalty(@Param('customerId', ParseUUIDPipe) customerId: string) {
    return this.customerLoyaltyService.getCustomerLoyalty(customerId).then((data) => ({
      success: true,
      message: 'Customer loyalty retrieved successfully',
      data,
    }));
  }
}
