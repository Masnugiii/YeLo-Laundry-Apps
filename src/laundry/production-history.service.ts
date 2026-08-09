import { Injectable } from '@nestjs/common';
import { OrderStatus, TimelineType } from '@prisma/client';
import { PrismaService } from '../database/prisma/prisma.service';
import {
  ProductionRecord,
  ProductionStageEvent,
  ProductionStatus,
} from './utils/production-meta.util';
import { mapProductionStageToOrderStatus } from './utils/production-status.util';

@Injectable()
export class ProductionHistoryService {
  constructor(private readonly prisma: PrismaService) {}

  async recordStageStart(
    orderId: string,
    stage: ProductionStatus,
    employeeId: string,
    notes?: string,
  ): Promise<ProductionStageEvent> {
    const event: ProductionStageEvent = {
      stage,
      employeeId,
      startedAt: new Date().toISOString(),
      notes,
    };

    await this.prisma.orderTimeline.create({
      data: {
        orderId,
        timelineType: TimelineType.IRONING,
        title: `Production ${stage} started`,
        description: notes ?? `Stage ${stage} started`,
        employeeId,
      },
    });

    return event;
  }

  async recordStageFinish(
    orderId: string,
    event: ProductionStageEvent,
    employeeId: string,
    notes?: string,
  ): Promise<ProductionStageEvent> {
    const finishedAt = new Date();
    const durationMinutes = Math.max(
      0,
      Math.round(
        (finishedAt.getTime() - new Date(event.startedAt).getTime()) / 60000,
      ),
    );

    const completed: ProductionStageEvent = {
      ...event,
      finishedAt: finishedAt.toISOString(),
      durationMinutes,
      notes: notes ?? event.notes,
    };

    await this.prisma.orderTimeline.create({
      data: {
        orderId,
        timelineType: TimelineType.IRONING,
        title: `Production ${event.stage} finished`,
        description:
          notes ??
          `Stage ${event.stage} completed in ${durationMinutes} minutes`,
        employeeId,
      },
    });

    return completed;
  }

  async recordStatusChange(
    orderId: string,
    previousStatus: OrderStatus | null,
    currentStatus: OrderStatus,
    employeeId: string,
    notes?: string,
  ): Promise<void> {
    await this.prisma.orderStatusHistory.create({
      data: {
        orderId,
        previousStatus: previousStatus ?? undefined,
        currentStatus,
        changedByEmployeeId: employeeId,
        notes,
      },
    });
  }

  getOpenStageEvent(
    record: ProductionRecord,
    stage: ProductionStatus,
  ): ProductionStageEvent | null {
    const events = record.history.filter((event) => event.stage === stage);

    return events.find((event) => !event.finishedAt) ?? null;
  }

  getLatestStageEvent(
    record: ProductionRecord,
    stage: ProductionStatus,
  ): ProductionStageEvent | null {
    const events = record.history.filter((event) => event.stage === stage);

    return events.at(-1) ?? null;
  }

  buildStatusChangeNotes(
    fromStage: ProductionStatus,
    toStage: ProductionStatus,
    notes?: string,
  ): string {
    return notes?.trim()
      ? `${fromStage} -> ${toStage}: ${notes}`
      : `Production transition ${fromStage} -> ${toStage}`;
  }

  resolveOrderStatusForStage(stage: ProductionStatus): OrderStatus {
    return mapProductionStageToOrderStatus(stage);
  }
}
