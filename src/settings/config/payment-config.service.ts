import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../database/prisma/prisma.service';
import { UpdatePaymentSettingsDto } from '../dto/update-payment-settings.dto';
import {
  CUSTOMER_PAYMENT_CONFIG_KEY,
  CustomerPaymentConfig,
  CustomerPaymentConfigResponse,
  CustomerPaymentMethodAvailability,
  DEFAULT_CUSTOMER_PAYMENT_CONFIG,
  QrisPaymentSettings,
  BankTransferPaymentSettings,
} from '../types/payment-settings.types';

const CUSTOMER_METHOD_CODES = ['YELO_WALLET', 'QRIS', 'BANK_TRANSFER'] as const;

@Injectable()
export class PaymentConfigService {
  constructor(private readonly prisma: PrismaService) {}

  async getConfig(): Promise<CustomerPaymentConfig> {
    const setting = await this.prisma.systemSetting.findUnique({
      where: { settingKey: CUSTOMER_PAYMENT_CONFIG_KEY },
      select: { settingValue: true },
    });

    if (!setting) {
      return { ...DEFAULT_CUSTOMER_PAYMENT_CONFIG };
    }

    return this.normalizeConfig(
      JSON.parse(setting.settingValue) as Partial<CustomerPaymentConfig>,
    );
  }

  async updateConfig(
    dto: UpdatePaymentSettingsDto,
  ): Promise<CustomerPaymentConfig> {
    const current = await this.getConfig();
    const next = this.normalizeConfig({
      qris: { ...current.qris, ...dto.qris },
      bankTransfer: { ...current.bankTransfer, ...dto.bankTransfer },
    });

    await this.prisma.systemSetting.upsert({
      where: { settingKey: CUSTOMER_PAYMENT_CONFIG_KEY },
      create: {
        settingKey: CUSTOMER_PAYMENT_CONFIG_KEY,
        settingValue: JSON.stringify(next),
        description: 'Customer app QRIS and bank transfer payment configuration',
      },
      update: {
        settingValue: JSON.stringify(next),
      },
    });

    return next;
  }

  async getCustomerPaymentConfig(): Promise<CustomerPaymentConfigResponse> {
    const [config, methods] = await Promise.all([
      this.getConfig(),
      this.prisma.paymentMethod.findMany({
        where: {
          deletedAt: null,
          code: { in: [...CUSTOMER_METHOD_CODES] },
        },
        select: { code: true, name: true, isActive: true },
        orderBy: { name: 'asc' },
      }),
    ]);

    const methodMap = new Map(methods.map((method) => [method.code, method]));

    const availability: CustomerPaymentMethodAvailability[] =
      CUSTOMER_METHOD_CODES.map((code) => {
        const method = methodMap.get(code);
        const configActive = this.isConfigActive(code, config);
        return {
          code,
          name: method?.name ?? code,
          isActive: Boolean(method?.isActive && configActive),
        };
      });

    return {
      methods: availability,
      qris: config.qris,
      bankTransfer: config.bankTransfer,
    };
  }

  private isConfigActive(
    code: (typeof CUSTOMER_METHOD_CODES)[number],
    config: CustomerPaymentConfig,
  ): boolean {
    switch (code) {
      case 'QRIS':
        return (
          config.qris.isActive &&
          Boolean(config.qris.qrImageUrl?.trim() || config.qris.qrPayload?.trim())
        );
      case 'BANK_TRANSFER':
        return (
          config.bankTransfer.isActive &&
          Boolean(
            config.bankTransfer.bankName.trim() &&
              config.bankTransfer.accountNumber.trim() &&
              config.bankTransfer.accountHolder.trim(),
          )
        );
      case 'YELO_WALLET':
        return true;
      default:
        return false;
    }
  }

  private normalizeConfig(
    input: Partial<CustomerPaymentConfig>,
  ): CustomerPaymentConfig {
    return {
      qris: this.normalizeQris(input.qris),
      bankTransfer: this.normalizeBankTransfer(input.bankTransfer),
    };
  }

  private normalizeQris(
    input?: Partial<QrisPaymentSettings>,
  ): QrisPaymentSettings {
    return {
      isActive: input?.isActive ?? DEFAULT_CUSTOMER_PAYMENT_CONFIG.qris.isActive,
      qrImageUrl: input?.qrImageUrl?.trim() || null,
      qrPayload: input?.qrPayload?.trim() || null,
      instructions:
        input?.instructions?.trim() ||
        DEFAULT_CUSTOMER_PAYMENT_CONFIG.qris.instructions,
    };
  }

  private normalizeBankTransfer(
    input?: Partial<BankTransferPaymentSettings>,
  ): BankTransferPaymentSettings {
    return {
      isActive:
        input?.isActive ?? DEFAULT_CUSTOMER_PAYMENT_CONFIG.bankTransfer.isActive,
      bankName: input?.bankName?.trim() ?? '',
      accountNumber: input?.accountNumber?.trim() ?? '',
      accountHolder: input?.accountHolder?.trim() ?? '',
      instructions:
        input?.instructions?.trim() ||
        DEFAULT_CUSTOMER_PAYMENT_CONFIG.bankTransfer.instructions,
    };
  }
}
