import { Injectable } from '@nestjs/common';
import {
  IroningStatus,
  OrderStatus,
  Prisma,
} from '@prisma/client';
import { PrismaService } from '../database/prisma/prisma.service';
import { LaundryOrderQueryDto } from './dto/laundry.dto';
import {
  laundryOrderDetailSelect,
  laundryOrderListSelect,
  LaundryOrderDetailRecord,
} from './laundry.select';
import { ProductionHistoryService } from './production-history.service';
import { ProductionSettingsRepository } from './production-settings.repository';
import {
  mapPriorityToPrisma,
  NEXT_STAGE,
  PREVIOUS_STAGE,
  ProductionRecord,
  ProductionStatus,
} from './utils/production-meta.util';
import {
  inferProductionStageFromOrderStatus,
  mapProductionStageToOrderStatus,
  PRODUCTION_ELIGIBLE_STATUSES,
  TERMINAL_ORDER_STATUSES,
} from './utils/production-status.util';

@Injectable()
export class LaundryRepository {
  constructor(
    private readonly prisma: PrismaService,
    private readonly productionSettings: ProductionSettingsRepository,
    private readonly historyService: ProductionHistoryService,
  ) {}

  findOrders(query: LaundryOrderQueryDto, orderIds?: string[]) {
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const skip = (page - 1) * limit;
    const where = this.buildWhereClause(query, orderIds);

    return this.prisma.$transaction([
      this.prisma.order.findMany({
        where,
        skip,
        take: limit,
        orderBy: { receivedDate: 'asc' },
        select: laundryOrderListSelect,
      }),
      this.prisma.order.count({ where }),
    ]);
  }

  findOrderById(orderId: string): Promise<LaundryOrderDetailRecord | null> {
    return this.prisma.order.findFirst({
      where: { id: orderId, deletedAt: null },
      select: laundryOrderDetailSelect,
    });
  }

  async ensureProductionRecord(
    orderId: string,
    employeeId: string,
  ): Promise<ProductionRecord> {
    const existing = await this.productionSettings.getByOrderId(orderId);

    if (existing) {
      return existing;
    }

    const order = await this.findOrderById(orderId);

    if (!order) {
      throw new Error('ORDER_NOT_FOUND');
    }

    if (TERMINAL_ORDER_STATUSES.includes(order.orderStatus)) {
      throw new Error('ORDER_TERMINAL');
    }

    const currentStage = inferProductionStageFromOrderStatus(order.orderStatus);
    const record = this.productionSettings.createInitialRecord({
      orderId,
      employeeId,
      receivedAt: order.receivedDate?.toISOString() ?? order.orderDate.toISOString(),
      currentStage:
        currentStage === 'WAITING_WASH' && order.receivedDate
          ? 'RECEIVED'
          : currentStage,
    });

    if (record.currentStage === 'RECEIVED') {
      record.currentStage = 'WAITING_WASH';
      record.history.push(
        await this.historyService.recordStageStart(
          orderId,
          'WAITING_WASH',
          employeeId,
          'Auto-advanced to waiting wash',
        ),
      );
    }

    return this.productionSettings.save(record);
  }

  transitionStage(
    orderId: string,
    fromStage: ProductionStatus,
    toStage: ProductionStatus,
    employeeId: string,
    notes?: string,
    options?: {
      finishCurrent?: boolean;
      startNext?: boolean;
    },
  ): Promise<{
    order: LaundryOrderDetailRecord;
    production: ProductionRecord;
  }> {
    return this.prisma.$transaction(async (tx) => {
      const order = await tx.order.findFirst({
        where: { id: orderId, deletedAt: null },
        select: {
          id: true,
          orderStatus: true,
          receivedDate: true,
        },
      });

      if (!order) {
        throw new Error('ORDER_NOT_FOUND');
      }

      if (TERMINAL_ORDER_STATUSES.includes(order.orderStatus)) {
        throw new Error('ORDER_TERMINAL');
      }

      let production = await this.productionSettings.getByOrderId(orderId);

      if (!production) {
        production = this.productionSettings.createInitialRecord({
          orderId,
          employeeId,
          receivedAt: order.receivedDate?.toISOString() ?? new Date().toISOString(),
          currentStage: fromStage,
        });
      }

      if (production.currentStage !== fromStage) {
        throw new Error('INVALID_STAGE');
      }

      const expectedNext = NEXT_STAGE[fromStage];

      if (expectedNext !== toStage) {
        throw new Error('INVALID_TRANSITION');
      }

      if (options?.finishCurrent !== false) {
        const isWaitingStage = fromStage.startsWith('WAITING_');
        const openEvent = this.historyService.getOpenStageEvent(
          production,
          fromStage,
        );

        if (openEvent) {
          const completed = await this.historyService.recordStageFinish(
            orderId,
            openEvent,
            employeeId,
            notes,
          );

          production.history = production.history.map((event) =>
            event.stage === fromStage && !event.finishedAt ? completed : event,
          );
        } else if (!isWaitingStage) {
          throw new Error('STAGE_NOT_STARTED');
        } else {
          production.history.push({
            stage: fromStage,
            employeeId,
            startedAt: new Date().toISOString(),
            finishedAt: new Date().toISOString(),
            durationMinutes: 0,
            notes: notes ?? 'Queue stage completed',
          });
        }
      }

      if (options?.startNext !== false) {
        const started = await this.historyService.recordStageStart(
          orderId,
          toStage,
          employeeId,
          notes,
        );
        production.history.push(started);
      }

      const previousOrderStatus = order.orderStatus;
      const nextOrderStatus = mapProductionStageToOrderStatus(toStage);

      production.currentStage = toStage;
      production.updatedByEmployeeId = employeeId;
      production.updatedAt = new Date().toISOString();

      const updateData: Prisma.OrderUncheckedUpdateInput = {
        orderStatus: nextOrderStatus,
        updatedByEmployeeId: employeeId,
      };

      if (fromStage === 'RECEIVED' || toStage === 'WAITING_WASH') {
        updateData.receivedDate = order.receivedDate ?? new Date();
      }

      if (toStage === 'COMPLETED') {
        updateData.completedDate = new Date();
      }

      await tx.order.update({
        where: { id: orderId },
        data: updateData,
      });

      if (previousOrderStatus !== nextOrderStatus) {
        await this.historyService.recordStatusChange(
          orderId,
          previousOrderStatus,
          nextOrderStatus,
          employeeId,
          this.historyService.buildStatusChangeNotes(
            fromStage,
            toStage,
            notes,
          ),
        );
      }

      if (toStage === 'IRONING') {
        await this.ensureIroningJob(tx, orderId, employeeId, production.priority);
      }

      if (fromStage === 'IRONING' && toStage === 'QUALITY_CHECK') {
        await this.finishIroningJob(tx, orderId);
      }

      if (toStage === 'WAITING_IRON') {
        await this.ensureWaitingIroningJob(tx, orderId, production.priority);
      }

      await this.productionSettings.save(production);

      const detail = await tx.order.findUniqueOrThrow({
        where: { id: orderId },
        select: laundryOrderDetailSelect,
      });

      return {
        order: detail,
        production,
      };
    });
  }

  saveProductionRecord(record: ProductionRecord) {
    return this.productionSettings.save(record);
  }

  updateOrderStatus(
    orderId: string,
    orderStatus: OrderStatus,
    employeeId: string,
    previousStatus: OrderStatus,
    notes?: string,
  ) {
    return this.prisma.$transaction(async (tx) => {
      await tx.order.update({
        where: { id: orderId },
        data: {
          orderStatus,
          updatedByEmployeeId: employeeId,
          ...(orderStatus === OrderStatus.READY_FOR_PICKUP
            ? {}
            : {}),
        },
      });

      await this.historyService.recordStatusChange(
        orderId,
        previousStatus,
        orderStatus,
        employeeId,
        notes,
      );

      return tx.order.findUniqueOrThrow({
        where: { id: orderId },
        select: laundryOrderDetailSelect,
      });
    });
  }

  getDashboardCounts() {
    const startOfDay = new Date();
    startOfDay.setHours(0, 0, 0, 0);

    return this.prisma.order.count({
      where: {
        deletedAt: null,
        orderStatus: OrderStatus.COMPLETED,
        completedDate: { gte: startOfDay },
      },
    });
  }

  countDelayedOrders(orderIds: string[]) {
    if (orderIds.length === 0) {
      return Promise.resolve(0);
    }

    return this.prisma.order.count({
      where: {
        id: { in: orderIds },
        deletedAt: null,
        estimatedFinishDate: { lt: new Date() },
        orderStatus: { not: OrderStatus.COMPLETED },
      },
    });
  }

  private async ensureWaitingIroningJob(
    tx: Prisma.TransactionClient,
    orderId: string,
    priority: ProductionRecord['priority'],
  ) {
    const existing = await tx.ironingJob.findFirst({
      where: { orderId, deletedAt: null },
      select: { id: true },
    });

    if (existing) {
      return;
    }

    await tx.ironingJob.create({
      data: {
        orderId,
        status: IroningStatus.WAITING,
        priority: mapPriorityToPrisma(priority),
      },
    });
  }

  private async ensureIroningJob(
    tx: Prisma.TransactionClient,
    orderId: string,
    employeeId: string,
    priority: ProductionRecord['priority'],
  ) {
    const existing = await tx.ironingJob.findFirst({
      where: { orderId, deletedAt: null },
      orderBy: { createdAt: 'desc' },
    });

    if (existing) {
      await tx.ironingJob.update({
        where: { id: existing.id },
        data: {
          employeeId,
          status: IroningStatus.IN_PROGRESS,
          startedAt: existing.startedAt ?? new Date(),
          acceptedAt: existing.acceptedAt ?? new Date(),
          priority: mapPriorityToPrisma(priority),
        },
      });

      return;
    }

    await tx.ironingJob.create({
      data: {
        orderId,
        employeeId,
        status: IroningStatus.IN_PROGRESS,
        acceptedAt: new Date(),
        startedAt: new Date(),
        priority: mapPriorityToPrisma(priority),
      },
    });
  }

  private async finishIroningJob(
    tx: Prisma.TransactionClient,
    orderId: string,
  ) {
    const job = await tx.ironingJob.findFirst({
      where: { orderId, deletedAt: null, status: IroningStatus.IN_PROGRESS },
      orderBy: { createdAt: 'desc' },
    });

    if (!job) {
      return;
    }

    const finishedAt = new Date();
    const actualMinutes = job.startedAt
      ? Math.max(
          0,
          Math.round(
            (finishedAt.getTime() - job.startedAt.getTime()) / 60000,
          ),
        )
      : null;

    await tx.ironingJob.update({
      where: { id: job.id },
      data: {
        status: IroningStatus.FINISHED,
        finishedAt,
        actualMinutes,
      },
    });
  }

  private buildWhereClause(
    query: LaundryOrderQueryDto,
    orderIds?: string[],
  ): Prisma.OrderWhereInput {
    const where: Prisma.OrderWhereInput = {
      deletedAt: null,
      orderStatus: { in: PRODUCTION_ELIGIBLE_STATUSES },
    };

    if (orderIds?.length) {
      where.id = { in: orderIds };
    }

    if (query.search) {
      const search = query.search.trim();
      where.OR = [
        { invoiceNumber: { contains: search, mode: 'insensitive' } },
        { queueNumber: { contains: search, mode: 'insensitive' } },
        {
          customer: {
            OR: [
              { fullName: { contains: search, mode: 'insensitive' } },
              { phone: { contains: search, mode: 'insensitive' } },
            ],
          },
        },
      ];
    }

    if (query.date) {
      const start = new Date(query.date);
      start.setHours(0, 0, 0, 0);
      const end = new Date(query.date);
      end.setHours(23, 59, 59, 999);
      where.receivedDate = { gte: start, lte: end };
    } else if (query.dateFrom || query.dateTo) {
      where.receivedDate = {
        ...(query.dateFrom ? { gte: query.dateFrom } : {}),
        ...(query.dateTo ? { lte: query.dateTo } : {}),
      };
    }

    return where;
  }

  getStagePair(action: ProductionActionKind): {
    from: ProductionStatus;
    to: ProductionStatus;
  } {
    switch (action) {
      case 'start-washing':
        return { from: 'WAITING_WASH', to: 'WASHING' };
      case 'finish-washing':
        return { from: 'WASHING', to: 'WAITING_DRY' };
      case 'start-drying':
        return { from: 'WAITING_DRY', to: 'DRYING' };
      case 'finish-drying':
        return { from: 'DRYING', to: 'WAITING_IRON' };
      case 'start-ironing':
        return { from: 'WAITING_IRON', to: 'IRONING' };
      case 'finish-ironing':
        return { from: 'IRONING', to: 'QUALITY_CHECK' };
      default:
        throw new Error('UNKNOWN_ACTION');
    }
  }

  validateCanStart(stage: ProductionStatus, production: ProductionRecord) {
    const previous = PREVIOUS_STAGE[stage];

    if (!previous) {
      return;
    }

    const previousEvent = this.historyService.getLatestStageEvent(
      production,
      previous,
    );

    if (!previousEvent?.finishedAt && production.currentStage !== stage) {
      throw new Error('PREVIOUS_STAGE_NOT_FINISHED');
    }
  }
}

export type ProductionActionKind =
  | 'start-washing'
  | 'finish-washing'
  | 'start-drying'
  | 'finish-drying'
  | 'start-ironing'
  | 'finish-ironing';
