import {
  BadRequestException,
  ConflictException,
  Inject,
  Injectable,
  NotFoundException,
  forwardRef,
} from '@nestjs/common';
import { WalletTopUpRequestStatus, WalletTransactionType } from '@prisma/client';
import { PrismaService } from '../database/prisma/prisma.service';
import { RewardService } from '../loyalty/reward.service';
import { CustomerWalletRepository } from './customer-wallet.repository';
import { PaymentConfigService } from '../settings/config/payment-config.service';

export interface InitiateTopUpInput {
  customerId: string;
  amount: number;
  paymentMethod: 'QRIS' | 'BANK_TRANSFER';
}

@Injectable()
export class CustomerWalletTopUpService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly walletRepository: CustomerWalletRepository,
    private readonly paymentConfigService: PaymentConfigService,
    @Inject(forwardRef(() => RewardService))
    private readonly rewardService: RewardService,
  ) {}

  async initiate(input: InitiateTopUpInput) {
    if (input.amount <= 0) {
      throw new BadRequestException('Amount must be greater than zero');
    }

    const referenceNumber = await this.generateReferenceNumber();
    const paymentConfig = await this.paymentConfigService.getConfig();

    const request = await this.prisma.walletTopUpRequest.create({
      data: {
        customerId: input.customerId,
        amount: input.amount,
        paymentMethod: input.paymentMethod,
        referenceNumber,
        status: WalletTopUpRequestStatus.pending,
      },
    });

    return {
      request,
      paymentInstructions:
        input.paymentMethod === 'QRIS'
          ? paymentConfig.qris
          : paymentConfig.bankTransfer,
    };
  }

  async confirm(customerId: string, requestId: string) {
    const request = await this.prisma.walletTopUpRequest.findFirst({
      where: { id: requestId, customerId },
    });

    if (!request) {
      throw new NotFoundException('Top-up request not found');
    }

    if (request.status === WalletTopUpRequestStatus.completed) {
      throw new ConflictException('Top-up already completed');
    }

    if (request.status !== WalletTopUpRequestStatus.pending) {
      throw new BadRequestException('Top-up request is not pending');
    }

    const result = await this.prisma.$transaction(async (tx) => {
      const locked = await tx.walletTopUpRequest.findUnique({
        where: { id: requestId },
      });

      if (!locked || locked.status !== WalletTopUpRequestStatus.pending) {
        throw new ConflictException('Top-up already processed');
      }

      const walletResult = await this.walletRepository.applyMutation({
        customerId,
        amount: Number(locked.amount),
        type: WalletTransactionType.top_up,
        description: `Customer top-up via ${locked.paymentMethod}`,
        employeeId: null,
        referenceNumber: locked.referenceNumber,
        referenceType: 'WALLET_TOP_UP',
        referenceId: locked.id,
        isCredit: true,
        tx,
      });

      if ('insufficientBalance' in walletResult) {
        throw new BadRequestException('Unable to credit wallet');
      }

      const updated = await tx.walletTopUpRequest.update({
        where: { id: requestId },
        data: {
          status: WalletTopUpRequestStatus.completed,
          walletTxnId: walletResult.transaction.id,
          completedAt: new Date(),
        },
      });

      await this.rewardService.earnFromDeposit(
        customerId,
        Number(locked.amount),
        'WALLET_TOP_UP',
        locked.id,
        null,
        tx,
      );

      return { request: updated, wallet: walletResult };
    });

    return result;
  }

  async getStatus(customerId: string, requestId: string) {
    const request = await this.prisma.walletTopUpRequest.findFirst({
      where: { id: requestId, customerId },
    });

    if (!request) {
      throw new NotFoundException('Top-up request not found');
    }

    return request;
  }

  private async generateReferenceNumber(): Promise<string> {
    const now = new Date();
    const datePart = `${now.getFullYear()}${String(now.getMonth() + 1).padStart(2, '0')}${String(now.getDate()).padStart(2, '0')}`;
    const suffix = Math.floor(Math.random() * 90000 + 10000);
    return `WTU-${datePart}-${suffix}`;
  }
}
