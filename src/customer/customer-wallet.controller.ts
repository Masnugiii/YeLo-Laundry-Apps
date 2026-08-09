import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiBody,
  ApiOperation,
  ApiParam,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import { ROLES } from '../auth/constants/roles.constant';
import { PERMISSIONS } from '../auth/constants/permissions.constant';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { Permissions } from '../auth/decorators/permissions.decorator';
import { Roles } from '../auth/decorators/roles.decorator';
import { AuthenticatedEmployee } from '../auth/interfaces/jwt-payload.interface';
import { AllowCustomerActor } from './decorators/allow-customer-actor.decorator';
import { CustomerSelfGuard } from './guards/customer-self.guard';
import { ApiSuccessResponse } from '../common/interfaces/api-response.interface';
import { AdjustWalletDto } from './dto/adjust-wallet.dto';
import { DeductWalletDto } from './dto/deduct-wallet.dto';
import { TopupWalletDto } from './dto/topup-wallet.dto';
import { WalletTransactionQueryDto } from './dto/wallet-transaction-query.dto';
import {
  CustomerWalletSummary,
  PaginatedWalletTransactions,
  WalletMutationResult,
} from './customer-wallet.mapper';
import { CustomerWalletService } from './customer-wallet.service';

const WALLET_SUMMARY_EXAMPLE = {
  walletId: 'bb0e8400-e29b-41d4-a716-446655440007',
  customerId: '990e8400-e29b-41d4-a716-446655440005',
  balance: 750000,
  currency: 'IDR',
  isActive: true,
  totalTopup: 1000000,
  totalCashback: 50000,
  totalSpending: 300000,
  updatedAt: '2026-08-08T06:00:00.000Z',
};

const TRANSACTION_EXAMPLE = {
  id: '140e8400-e29b-41d4-a716-446655440015',
  customerId: '990e8400-e29b-41d4-a716-446655440005',
  walletId: 'bb0e8400-e29b-41d4-a716-446655440007',
  referenceNumber: 'WLT-20260808-000001',
  type: 'TOPUP',
  amount: 100000,
  notes: 'Top Up by Cash',
  createdByEmployeeId: '660e8400-e29b-41d4-a716-446655440001',
  createdByEmployee: {
    id: '660e8400-e29b-41d4-a716-446655440001',
    fullName: 'Admin Owner',
    employeeCode: 'EMP0001',
  },
  createdAt: '2026-08-08T06:00:00.000Z',
};

const VIEW_ROLES = [
  ROLES.OWNER,
  ROLES.MANAGER,
  ROLES.CASHIER,
  ROLES.OPERATOR,
] as const;

const MUTATION_ROLES = [ROLES.OWNER, ROLES.CASHIER] as const;

@ApiTags('Customer Wallet')
@ApiBearerAuth('access-token')
@Permissions(PERMISSIONS.WALLET)
@Controller('customers/:customerId/wallet')
export class CustomerWalletController {
  constructor(private readonly walletService: CustomerWalletService) {}

  @Get()
  @AllowCustomerActor()
  @UseGuards(CustomerSelfGuard)
  @Roles(...VIEW_ROLES)
  @ApiOperation({
    summary: 'Get customer wallet summary',
    description:
      'Returns wallet balance, totals (top-up, cashback, spending), and status.',
  })
  @ApiParam({ name: 'customerId', description: 'Customer UUID' })
  @ApiResponse({
    status: 200,
    description: 'Customer wallet retrieved successfully',
    schema: {
      example: {
        success: true,
        message: 'Customer wallet retrieved successfully',
        data: WALLET_SUMMARY_EXAMPLE,
      },
    },
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  @ApiResponse({ status: 404, description: 'Customer or wallet not found' })
  getWallet(
    @Param('customerId', ParseUUIDPipe) customerId: string,
  ): Promise<ApiSuccessResponse<CustomerWalletSummary>> {
    return this.walletService.getWallet(customerId);
  }

  @Get('transactions')
  @AllowCustomerActor()
  @UseGuards(CustomerSelfGuard)
  @Roles(...VIEW_ROLES)
  @ApiOperation({
    summary: 'List wallet transaction history',
    description:
      'Paginated transaction history with optional filters for type and date range.',
  })
  @ApiParam({ name: 'customerId', description: 'Customer UUID' })
  @ApiResponse({
    status: 200,
    description: 'Wallet transactions retrieved successfully',
    schema: {
      example: {
        success: true,
        message: 'Wallet transactions retrieved successfully',
        data: {
          items: [TRANSACTION_EXAMPLE],
          meta: { page: 1, limit: 20, total: 1, totalPages: 1 },
        },
      },
    },
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  @ApiResponse({ status: 404, description: 'Customer or wallet not found' })
  getTransactions(
    @Param('customerId', ParseUUIDPipe) customerId: string,
    @Query() query: WalletTransactionQueryDto,
  ): Promise<ApiSuccessResponse<PaginatedWalletTransactions>> {
    return this.walletService.getTransactions(customerId, query);
  }

  @Post('topup')
  @Roles(...MUTATION_ROLES)
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Top up customer wallet',
    description:
      'Credits the wallet balance and creates a TOPUP transaction record atomically.',
  })
  @ApiParam({ name: 'customerId', description: 'Customer UUID' })
  @ApiBody({
    type: TopupWalletDto,
    examples: {
      default: {
        summary: 'Cash top-up',
        value: {
          amount: 100000,
          notes: 'Top Up by Cash',
        },
      },
    },
  })
  @ApiResponse({
    status: 201,
    description: 'Wallet top-up successful',
    schema: {
      example: {
        success: true,
        message: 'Wallet top-up successful',
        data: {
          transaction: TRANSACTION_EXAMPLE,
          wallet: WALLET_SUMMARY_EXAMPLE,
        },
      },
    },
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  @ApiResponse({ status: 404, description: 'Customer or wallet not found' })
  @ApiResponse({ status: 422, description: 'Validation error' })
  topup(
    @Param('customerId', ParseUUIDPipe) customerId: string,
    @Body() dto: TopupWalletDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ): Promise<ApiSuccessResponse<WalletMutationResult>> {
    return this.walletService.topup(customerId, dto, user.employeeId);
  }

  @Post('deduct')
  @Roles(...MUTATION_ROLES)
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Deduct customer wallet balance',
    description:
      'Debits the wallet for a payment and creates a PAYMENT transaction record atomically.',
  })
  @ApiParam({ name: 'customerId', description: 'Customer UUID' })
  @ApiBody({
    type: DeductWalletDto,
    examples: {
      default: {
        summary: 'Laundry payment',
        value: {
          amount: 25000,
          notes: 'Laundry Payment',
        },
      },
    },
  })
  @ApiResponse({
    status: 201,
    description: 'Wallet deduction successful',
    schema: {
      example: {
        success: true,
        message: 'Wallet deduction successful',
        data: {
          transaction: { ...TRANSACTION_EXAMPLE, type: 'PAYMENT', amount: 25000 },
          wallet: WALLET_SUMMARY_EXAMPLE,
        },
      },
    },
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  @ApiResponse({ status: 404, description: 'Customer or wallet not found' })
  @ApiResponse({ status: 422, description: 'Insufficient balance or validation error' })
  deduct(
    @Param('customerId', ParseUUIDPipe) customerId: string,
    @Body() dto: DeductWalletDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ): Promise<ApiSuccessResponse<WalletMutationResult>> {
    return this.walletService.deduct(customerId, dto, user.employeeId);
  }

  @Post('adjust')
  @Roles(ROLES.OWNER)
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Adjust customer wallet balance (Owner only)',
    description:
      'Manually increase or decrease wallet balance with an ADJUSTMENT transaction record.',
  })
  @ApiParam({ name: 'customerId', description: 'Customer UUID' })
  @ApiBody({
    type: AdjustWalletDto,
    examples: {
      increase: {
        summary: 'Increase balance',
        value: {
          amount: 50000,
          direction: 'increase',
          notes: 'Manual balance correction',
        },
      },
      decrease: {
        summary: 'Decrease balance',
        value: {
          amount: 25000,
          direction: 'decrease',
          notes: 'Balance correction after audit',
        },
      },
    },
  })
  @ApiResponse({
    status: 201,
    description: 'Wallet adjustment successful',
    schema: {
      example: {
        success: true,
        message: 'Wallet adjustment successful',
        data: {
          transaction: { ...TRANSACTION_EXAMPLE, type: 'ADJUSTMENT' },
          wallet: WALLET_SUMMARY_EXAMPLE,
        },
      },
    },
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden — Owner only' })
  @ApiResponse({ status: 404, description: 'Customer or wallet not found' })
  @ApiResponse({ status: 422, description: 'Insufficient balance or validation error' })
  adjust(
    @Param('customerId', ParseUUIDPipe) customerId: string,
    @Body() dto: AdjustWalletDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ): Promise<ApiSuccessResponse<WalletMutationResult>> {
    return this.walletService.adjust(customerId, dto, user.employeeId);
  }
}
