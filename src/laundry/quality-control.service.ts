import { BadRequestException, Injectable } from '@nestjs/common';
import { randomUUID } from 'crypto';
import {
  ProductionRecord,
  ProductionStatus,
  QualityCheckRecord,
  ReworkStage,
} from './utils/production-meta.util';
import { ProductionHistoryService } from './production-history.service';
import { ProductionSettingsRepository } from './production-settings.repository';
import { mapProductionStageToOrderStatus } from './utils/production-status.util';

export interface QualityCheckInput {
  passed: boolean;
  notes?: string;
  reworkStage?: ReworkStage;
  reason?: string;
}

@Injectable()
export class QualityControlService {
  constructor(
    private readonly productionSettings: ProductionSettingsRepository,
    private readonly historyService: ProductionHistoryService,
  ) {}

  async applyQualityCheck(
    record: ProductionRecord,
    input: QualityCheckInput,
    employeeId: string,
  ): Promise<{
    record: ProductionRecord;
    targetStage: ProductionStatus;
    qualityCheck: QualityCheckRecord;
  }> {
    if (record.currentStage !== 'QUALITY_CHECK') {
      throw new BadRequestException(
        'Order must be in QUALITY_CHECK stage before quality control',
      );
    }

    const openEvent = this.historyService.getOpenStageEvent(
      record,
      'QUALITY_CHECK',
    );

    if (openEvent) {
      const completed = await this.historyService.recordStageFinish(
        record.orderId,
        openEvent,
        employeeId,
        input.notes,
      );
      record.history = record.history.map((event) =>
        event.startedAt === openEvent.startedAt &&
        event.stage === 'QUALITY_CHECK'
          ? completed
          : event,
      );
    }

    const qualityCheck: QualityCheckRecord = {
      id: randomUUID(),
      result: input.passed ? 'PASS' : 'REWORK',
      passed: input.passed,
      reworkStage: input.passed ? undefined : input.reworkStage,
      reason: input.reason,
      notes: input.notes,
      employeeId,
      checkedAt: new Date().toISOString(),
    };

    record.qualityChecks.push(qualityCheck);

    if (input.passed) {
      record.currentStage = 'READY';
      record.updatedByEmployeeId = employeeId;
      record.updatedAt = new Date().toISOString();

      const readyEvent = await this.historyService.recordStageStart(
        record.orderId,
        'READY',
        employeeId,
        input.notes,
      );
      record.history.push(readyEvent);

      return {
        record,
        targetStage: 'READY',
        qualityCheck,
      };
    }

    if (!input.reworkStage) {
      throw new BadRequestException(
        'reworkStage is required when quality check fails',
      );
    }

    const targetStage = input.reworkStage;
    record.currentStage = targetStage;
    record.updatedByEmployeeId = employeeId;
    record.updatedAt = new Date().toISOString();

    const reworkEvent = await this.historyService.recordStageStart(
      record.orderId,
      targetStage,
      employeeId,
      input.reason ?? input.notes,
    );
    record.history.push(reworkEvent);

    return {
      record,
      targetStage,
      qualityCheck,
    };
  }

  resolveOrderStatus(stage: ProductionStatus) {
    return mapProductionStageToOrderStatus(stage);
  }
}
