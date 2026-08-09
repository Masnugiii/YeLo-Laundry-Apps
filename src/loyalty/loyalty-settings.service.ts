import { Injectable } from '@nestjs/common';
import { PrismaService } from '../database/prisma/prisma.service';
import {
  DEFAULT_LOYALTY_SETTINGS,
  LOYALTY_SETTINGS_KEY,
  LoyaltySettings,
} from './loyalty.types';

@Injectable()
export class LoyaltySettingsService {
  constructor(private readonly prisma: PrismaService) {}

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
    _options?: { skipAudit?: boolean },
  ): Promise<LoyaltySettings> {
    const current = await this.getSettings();
    const next = this.normalize({ ...current, ...input });

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

    return next;
  }

  private normalize(input: Partial<LoyaltySettings>): LoyaltySettings {
    return {
      ...DEFAULT_LOYALTY_SETTINGS,
      ...input,
      membershipLevels:
        input.membershipLevels?.length
          ? input.membershipLevels
          : DEFAULT_LOYALTY_SETTINGS.membershipLevels,
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
