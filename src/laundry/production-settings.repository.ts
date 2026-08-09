import { Injectable } from '@nestjs/common';
import { PrismaService } from '../database/prisma/prisma.service';
import {
  buildProductionSettingKey,
  parseProductionRecord,
  PRODUCTION_SETTING_PREFIX,
  ProductionPriority,
  ProductionRecord,
  ProductionStatus,
  PRIORITY_WEIGHT,
} from './utils/production-meta.util';

@Injectable()
export class ProductionSettingsRepository {
  constructor(private readonly prisma: PrismaService) {}

  async getByOrderId(orderId: string): Promise<ProductionRecord | null> {
    const setting = await this.prisma.systemSetting.findUnique({
      where: { settingKey: buildProductionSettingKey(orderId) },
      select: { settingValue: true },
    });

    return setting ? parseProductionRecord(setting.settingValue) : null;
  }

  async save(record: ProductionRecord): Promise<ProductionRecord> {
    await this.prisma.systemSetting.upsert({
      where: { settingKey: buildProductionSettingKey(record.orderId) },
      create: {
        settingKey: buildProductionSettingKey(record.orderId),
        settingValue: JSON.stringify(record),
        description: `Production ${record.orderId}`,
      },
      update: {
        settingValue: JSON.stringify(record),
      },
    });

    return record;
  }

  async listByStages(stages: ProductionStatus[]): Promise<ProductionRecord[]> {
    const settings = await this.prisma.systemSetting.findMany({
      where: { settingKey: { startsWith: PRODUCTION_SETTING_PREFIX } },
      select: { settingValue: true },
    });

    return settings
      .map((setting) => parseProductionRecord(setting.settingValue))
      .filter((record): record is ProductionRecord => record !== null)
      .filter((record) => stages.includes(record.currentStage));
  }

  async listAll(): Promise<ProductionRecord[]> {
    const settings = await this.prisma.systemSetting.findMany({
      where: { settingKey: { startsWith: PRODUCTION_SETTING_PREFIX } },
      select: { settingValue: true },
    });

    return settings
      .map((setting) => parseProductionRecord(setting.settingValue))
      .filter((record): record is ProductionRecord => record !== null);
  }

  sortByPriorityAndReceiveTime(
    records: ProductionRecord[],
  ): ProductionRecord[] {
    return [...records].sort((a, b) => {
      const priorityDiff =
        PRIORITY_WEIGHT[b.priority] - PRIORITY_WEIGHT[a.priority];

      if (priorityDiff !== 0) {
        return priorityDiff;
      }

      return (
        new Date(a.receivedAt).getTime() - new Date(b.receivedAt).getTime()
      );
    });
  }

  createInitialRecord(params: {
    orderId: string;
    employeeId: string;
    priority?: ProductionPriority;
    receivedAt?: string;
    currentStage?: ProductionStatus;
  }): ProductionRecord {
    const now = new Date().toISOString();

    return {
      orderId: params.orderId,
      priority: params.priority ?? 'NORMAL',
      currentStage: params.currentStage ?? 'RECEIVED',
      receivedAt: params.receivedAt ?? now,
      history: [
        {
          stage: params.currentStage ?? 'RECEIVED',
          employeeId: params.employeeId,
          startedAt: now,
          notes: 'Production record initialized',
        },
      ],
      qualityChecks: [],
      createdByEmployeeId: params.employeeId,
      createdAt: now,
      updatedAt: now,
    };
  }
}
