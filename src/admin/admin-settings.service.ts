import { Injectable } from '@nestjs/common';
import { PrismaService } from '../database/prisma/prisma.service';

export interface CompanySettings {
  id?: string;
  companyName: string;
  phone: string | null;
  email: string | null;
  address: string | null;
  logoUrl: string | null;
  businessHours: string | null;
  timezone: string | null;
  currency: string | null;
  taxRate: number | null;
}

const SYSTEM_KEYS = {
  businessHours: 'admin.business_hours',
  timezone: 'admin.timezone',
  currency: 'admin.currency',
  taxRate: 'admin.tax_rate',
} as const;

@Injectable()
export class AdminSettingsService {
  constructor(private readonly prisma: PrismaService) {}

  async getCompanySettings(): Promise<CompanySettings> {
    const company = await this.prisma.companySetting.findFirst({
      orderBy: { createdAt: 'asc' },
    });

    const systemSettings = await this.prisma.systemSetting.findMany({
      where: {
        settingKey: {
          in: Object.values(SYSTEM_KEYS),
        },
      },
    });

    const map = new Map(
      systemSettings.map((setting) => [setting.settingKey, setting.settingValue]),
    );

    return {
      id: company?.id,
      companyName: company?.companyName ?? 'Yelo Laundry',
      phone: company?.phone ?? null,
      email: company?.email ?? null,
      address: company?.address ?? null,
      logoUrl: company?.logoUrl ?? null,
      businessHours: map.get(SYSTEM_KEYS.businessHours) ?? '08:00-20:00',
      timezone: map.get(SYSTEM_KEYS.timezone) ?? 'Asia/Jakarta',
      currency: map.get(SYSTEM_KEYS.currency) ?? 'IDR',
      taxRate: map.has(SYSTEM_KEYS.taxRate)
        ? Number(map.get(SYSTEM_KEYS.taxRate))
        : 0,
    };
  }

  async updateCompanySettings(
    dto: Partial<CompanySettings>,
  ): Promise<CompanySettings> {
    const existing = await this.prisma.companySetting.findFirst({
      orderBy: { createdAt: 'asc' },
    });

    if (existing) {
      await this.prisma.companySetting.update({
        where: { id: existing.id },
        data: {
          ...(dto.companyName !== undefined && { companyName: dto.companyName }),
          ...(dto.phone !== undefined && { phone: dto.phone }),
          ...(dto.email !== undefined && { email: dto.email }),
          ...(dto.address !== undefined && { address: dto.address }),
          ...(dto.logoUrl !== undefined && { logoUrl: dto.logoUrl }),
        },
      });
    } else {
      await this.prisma.companySetting.create({
        data: {
          companyName: dto.companyName ?? 'Yelo Laundry',
          phone: dto.phone ?? null,
          email: dto.email ?? null,
          address: dto.address ?? null,
          logoUrl: dto.logoUrl ?? null,
        },
      });
    }

    const systemUpdates: Array<{ key: string; value: string }> = [];

    if (dto.businessHours !== undefined && dto.businessHours !== null) {
      systemUpdates.push({
        key: SYSTEM_KEYS.businessHours,
        value: dto.businessHours,
      });
    }

    if (dto.timezone !== undefined && dto.timezone !== null) {
      systemUpdates.push({ key: SYSTEM_KEYS.timezone, value: dto.timezone });
    }

    if (dto.currency !== undefined && dto.currency !== null) {
      systemUpdates.push({ key: SYSTEM_KEYS.currency, value: dto.currency });
    }

    if (dto.taxRate !== undefined) {
      systemUpdates.push({
        key: SYSTEM_KEYS.taxRate,
        value: String(dto.taxRate),
      });
    }

    for (const update of systemUpdates) {
      await this.prisma.systemSetting.upsert({
        where: { settingKey: update.key },
        create: {
          settingKey: update.key,
          settingValue: update.value,
        },
        update: {
          settingValue: update.value,
        },
      });
    }

    return this.getCompanySettings();
  }
}
