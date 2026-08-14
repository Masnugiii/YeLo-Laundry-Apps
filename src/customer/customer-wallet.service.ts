import {
  Inject,
  Injectable,
  NotFoundException,
  UnprocessableEntityException,
  forwardRef,
} from '@nestjs/common';
import { WalletTransactionType } from '@prisma/client';
import { ApiSuccessResponse } from '../common/interfaces/api-response.interface';
import { RewardService } from '../loyalty/reward.service';
import { AdjustWalletDto, WalletAdjustDirection } from './dto/adjust-wallet.dto';
import { DeductWalletDto } from './dto/deduct-wallet.dto';
import { TopupWalletDto } from './dto/topup-wallet.dto';
import { WalletTransactionQueryDto } from './dto/wallet-transaction-query.dto';
import {
  CustomerWalletSummary,
  PaginatedWalletTransactions,
  toCustomerWalletSummary,
  toCustomerWalletTransactionItem,
  WalletMutationResult,
} from './customer-wallet.mapper';
import { CustomerWalletRepository } from './customer-wallet.repository';
import { CustomerRepository } from './customer.repository';

@Injectable()
export class CustomerWalletService {
  constructor(
    private readonly customerRepository: CustomerRepository,
    private readonly walletRepository: CustomerWalletRepository,
    @Inject(forwardRef(() => RewardService))
    private readonly rewardService: RewardService,
  ) {}

  async getWallet(
    customerId: string,
  ): Promise<ApiSuccessResponse<CustomerWalletSummary>> {
    await this.ensureCustomerExists(customerId);

    const wallet = await this.walletRepository.ensureWalletForCustomer(customerId);
    const aggregates = await this.walletRepository.getWalletAggregates(
      customerId,
      wallet.id,
    );

    return {
      success: true,
      message: 'Customer wallet retrieved successfully',
      data: toCustomerWalletSummary(wallet, aggregates),
    };
  }

  async getTransactions(
    customerId: string,
    query: WalletTransactionQueryDto,
  ): Promise<ApiSuccessResponse<PaginatedWalletTransactions>> {
    await this.ensureCustomerExists(customerId);

    await this.walletRepository.ensureWalletForCustomer(customerId);

    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const [transactions, total] = await this.walletRepository.findTransactions(
      customerId,
      query,
    );

    return {
      success: true,
      message: 'Wallet transactions retrieved successfully',
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

  async topup(
    customerId: string,
    dto: TopupWalletDto,
    employeeId: string,
  ): Promise<ApiSuccessResponse<WalletMutationResult>> {
    await this.ensureCustomerExists(customerId);

    const referenceNumber =
      await this.walletRepository.generateNextReferenceNumber();

    const result = await this.walletRepository.applyMutation({
      customerId,
      amount: dto.amount,
      type: WalletTransactionType.top_up,
      description: dto.notes?.trim(),
      employeeId,
      referenceNumber,
      isCredit: true,
      referenceType: 'WALLET_TOPUP',
    });

    if (!('insufficientBalance' in result)) {
      await this.rewardService.earnFromDeposit(
        customerId,
        dto.amount,
        'WALLET_TOPUP',
        result.transaction.id,
        employeeId,
      );
    }

    return this.buildMutationResponse(result, 'Wallet top-up successful');
  }

  async deduct(
    customerId: string,
    dto: DeductWalletDto,
    employeeId: string,
  ): Promise<ApiSuccessResponse<WalletMutationResult>> {
    await this.ensureCustomerExists(customerId);

    const referenceNumber =
      await this.walletRepository.generateNextReferenceNumber();

    const result = await this.walletRepository.applyMutation({
      customerId,
      amount: dto.amount,
      type: WalletTransactionType.deduction,
      description: dto.notes?.trim(),
      employeeId,
      referenceNumber,
      isCredit: false,
    });

    return this.buildMutationResponse(result, 'Wallet deduction successful');
  }

  async adjust(
    customerId: string,
    dto: AdjustWalletDto,
    employeeId: string,
  ): Promise<ApiSuccessResponse<WalletMutationResult>> {
    await this.ensureCustomerExists(customerId);

    const referenceNumber =
      await this.walletRepository.generateNextReferenceNumber();
    const isCredit = dto.direction === WalletAdjustDirection.INCREASE;

    const result = await this.walletRepository.applyMutation({
      customerId,
      amount: dto.amount,
      type: WalletTransactionType.adjustment,
      description: dto.notes?.trim(),
      employeeId,
      referenceNumber,
      isCredit,
    });

    return this.buildMutationResponse(result, 'Wallet adjustment successful');
  }

  private buildMutationResponse(
    result:
      | {
          insufficientBalance: true;
          wallet: { id: string };
        }
      | {
          wallet: Parameters<typeof toCustomerWalletSummary>[0];
          transaction: Parameters<typeof toCustomerWalletTransactionItem>[0];
          aggregates: {
            totalTopup: number;
            totalCashback: number;
            totalSpending: number;
          };
        },
    message: string,
  ): ApiSuccessResponse<WalletMutationResult> {
    if ('insufficientBalance' in result) {
      throw new UnprocessableEntityException('Insufficient wallet balance');
    }

    return {
      success: true,
      message,
      data: {
        transaction: toCustomerWalletTransactionItem(result.transaction),
        wallet: toCustomerWalletSummary(result.wallet, result.aggregates),
      },
    };
  }

  private async ensureCustomerExists(customerId: string): Promise<void> {
    const customer = await this.customerRepository.findById(customerId);

    if (!customer) {
      throw new NotFoundException('Customer not found');
    }
  }
}
