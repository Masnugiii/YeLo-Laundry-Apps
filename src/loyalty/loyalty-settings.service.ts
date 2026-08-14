import { BadRequestException, Injectable } from '@nestjs/common';
import { PrismaService } from '../database/prisma/prisma.service';
import { ConfigAuditService } from '../settings/audit/config-audit.service';
import {
  DEFAULT_LOYALTY_SETTINGS,
  LOYALTY_SETTINGS_KEY,
  LoyaltySettings,
} from './loyalty.types';

@Injectable()
export class LoyaltySettingsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly configAuditService: ConfigAuditService,
  ) {}

  async getSettings(): Promise<LoyaltySettings> {
    const setting = await this.prisma.systemSetting.findUnique({
      where: { settingKey: LOYALTY_SETTINGS_KEY },
    });

    if (!setting?.settingValue) {
      return DEFAULT_LOYALTY_SETTINGS;
    }

    try {
      const parsed = JSON.parse(setting.settingValue) as Partial<LoyaltySettings>;
      return this.normalize(parsed);
    } catch {
      return DEFAULT_LOYALTY_SETTINGS;
    }
  }

  async updateSettings(
    input: Partial<LoyaltySettings>,
    employeeId: string,
    options?: { skipAudit?: boolean },
  ): Promise<LoyaltySettings> {
    const current = await this.getSettings();
    const next = this.normalize({ ...current, ...input });
    this.validate(next);

    await this.prisma.systemSetting.upsert({
      where: { settingKey: LOYALTY_SETTINGS_KEY },
      create: {
        settingKey: LOYALTY_SETTINGS_KEY,
        settingValue: JSON.stringify(next),
        description: 'Customer loyalty platform configuration',
      },
      update: {
        settingValue: JSON.stringify(next),
      },
    });

    if (!options?.skipAudit) {
      await this.configAuditService.logConfigUpdated({
        employeeId,
        section: 'loyalty',
        before: current,
        after: next,
      });
    }

    return next;
  }

  private validate(settings: LoyaltySettings): void {
    if (settings.laundryPoint.pointsPerUnit <= 0) {
      throw new BadRequestException('Laundry points per unit must be greater than zero');
    }
    if (settings.laundryPoint.minimumTransaction <= 0) {
      throw new BadRequestException(
        'Laundry minimum transaction must be greater than zero',
      );
    }
    if (settings.depositPoint.minimumDeposit <= 0) {
      throw new BadRequestException(
        'Deposit minimum amount must be greater than zero',
      );
    }
    if (settings.depositPoint.pointsPerMultiplier <= 0) {
      throw new BadRequestException(
        'Deposit points per multiplier must be greater than zero',
      );
    }
    if (settings.pointExpirationDays <= 0) {
      throw new BadRequestException(
        'Point expiration days must be greater than zero',
      );
    }
    if (settings.cashback.maxAmount < 0) {
      throw new BadRequestException('Cashback max amount cannot be negative');
    }
    if (settings.wallet.minTopup <= 0) {
      throw new BadRequestException('Wallet minimum top-up must be greater than zero');
    }

    for (const level of settings.membershipLevels) {
      if (level.minPoints < 0) {
        throw new BadRequestException('Membership minimum points cannot be negative');
      }
    }
  }

  private normalize(input: Partial<LoyaltySettings>): LoyaltySettings {
    const laundryPoint = {
      enabled: input.laundryPoint?.enabled ?? true,
      minimumTransaction:
        input.laundryPoint?.minimumTransaction ??
        input.rupiahPerPoint ??
        DEFAULT_LOYALTY_SETTINGS.laundryPoint.minimumTransaction,
      pointsPerUnit:
        input.laundryPoint?.pointsPerUnit ??
        input.pointPerRupiah ??
        DEFAULT_LOYALTY_SETTINGS.laundryPoint.pointsPerUnit,
    };

    const depositPoint = {
      enabled: input.depositPoint?.enabled ?? true,
      minimumDeposit:
        input.depositPoint?.minimumDeposit ??
        DEFAULT_LOYALTY_SETTINGS.depositPoint.minimumDeposit,
      pointsPerMultiplier:
        input.depositPoint?.pointsPerMultiplier ??
        DEFAULT_LOYALTY_SETTINGS.depositPoint.pointsPerMultiplier,
    };

    const membershipLevels =
      input.membershipLevels?.length
        ? input.membershipLevels.map((level) => ({
            ...level,
            active: level.active ?? true,
          }))
        : DEFAULT_LOYALTY_SETTINGS.membershipLevels;

    return {
      ...DEFAULT_LOYALTY_SETTINGS,
      ...input,
      pointPerRupiah: laundryPoint.pointsPerUnit,
      rupiahPerPoint: laundryPoint.minimumTransaction,
      laundryPoint,
      depositPoint,
      membershipLevels,
      cashback: {
        ...DEFAULT_LOYALTY_SETTINGS.cashback,
        ...(input.cashback ?? {}),
      },
      wallet: {
        ...DEFAULT_LOYALTY_SETTINGS.wallet,
        ...(input.wallet ?? {}),
      },
    };
  }
}
