import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { OrderStatus } from '@prisma/client';
import { ApiSuccessResponse } from '../common/interfaces/api-response.interface';
import { LaundryAuditService } from './laundry-audit.service';
import {
  LaundryDashboard,
  LaundryOrderDetail,
  LaundryOrderListItem,
  PaginatedLaundryOrders,
  toLaundryOrderDetail,
  toLaundryOrderListItem,
  toQueueItem,
} from './laundry.mapper';
import {
  LaundryRepository,
  ProductionActionKind,
} from './laundry.repository';
import { ProductionSettingsRepository } from './production-settings.repository';
import { QualityControlService } from './quality-control.service';
import {
  LaundryOrderQueryDto,
  ProductionActionDto,
  QualityCheckDto,
} from './dto/laundry.dto';
import { ProductionHistoryService } from './production-history.service';
import { ProductionStatus } from './utils/production-meta.util';
import { mapProductionStageToOrderStatus } from './utils/production-status.util';

@Injectable()
export class LaundryService {
  constructor(
    private readonly laundryRepository: LaundryRepository,
    private readonly productionSettings: ProductionSettingsRepository,
    private readonly qualityControlService: QualityControlService,
    private readonly historyService: ProductionHistoryService,
    private readonly auditService: LaundryAuditService,
  ) {}

  async getDashboard(): Promise<ApiSuccessResponse<LaundryDashboard>> {
    const records = await this.productionSettings.listAll();
    const completedToday = await this.laundryRepository.getDashboardCounts();

    const activeOrderIds = records
      .filter((record) => record.currentStage !== 'COMPLETED')
      .map((record) => record.orderId);
    const delayed =
      await this.laundryRepository.countDelayedOrders(activeOrderIds);

    const durations = records
      .flatMap((record) => record.history)
      .map((event) => event.durationMinutes ?? 0)
      .filter((minutes) => minutes > 0);

    const averageProductionTimeMinutes =
      durations.length > 0
        ? Math.round(
            durations.reduce((sum, value) => sum + value, 0) / durations.length,
          )
        : 0;

    const countStage = (stage: ProductionStatus) =>
      records.filter((record) => record.currentStage === stage).length;

    return {
      success: true,
      message: 'Production dashboard retrieved successfully',
      data: {
        receiving: countStage('RECEIVED'),
        sorting: countStage('WAITING_WASH'),
        waitingWashing: countStage('WAITING_WASH'),
        currentlyWashing: countStage('WASHING'),
        waitingDrying: countStage('WAITING_DRY'),
        currentlyDrying: countStage('DRYING'),
        waitingIroning: countStage('WAITING_IRON'),
        currentlyIroning: countStage('IRONING'),
        qualityCheck: countStage('QUALITY_CHECK'),
        packing: countStage('QUALITY_CHECK'),
        readyForPickup: countStage('READY'),
        completedToday,
        delayed,
        averageProductionTimeMinutes,
      },
    };
  }

  async findOrders(
    query: LaundryOrderQueryDto,
  ): Promise<ApiSuccessResponse<PaginatedLaundryOrders>> {
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;

    let orderIds: string[] | undefined;

    if (query.status) {
      const records = await this.productionSettings.listByStages([query.status]);
      orderIds = records.map((record) => record.orderId);

      if (orderIds.length === 0) {
        return {
          success: true,
          message: 'Production orders retrieved successfully',
          data: {
            items: [],
            meta: { page, limit, total: 0, totalPages: 1 },
          },
        };
      }
    }

    const [orders, total] = await this.laundryRepository.findOrders(
      query,
      orderIds,
    );

    const items: LaundryOrderListItem[] = [];

    for (const order of orders) {
      const production =
        (await this.productionSettings.getByOrderId(order.id)) ??
        this.productionSettings.createInitialRecord({
          orderId: order.id,
          employeeId: order.createdByEmployee.id,
          receivedAt:
            order.receivedDate?.toISOString() ?? order.orderDate.toISOString(),
        });

      if (query.status && production.currentStage !== query.status) {
        continue;
      }

      if (query.priority && production.priority !== query.priority) {
        continue;
      }

      if (query.service) {
        const serviceMatch = order.items.some((item) =>
          item.service.serviceName
            .toLowerCase()
            .includes(query.service!.toLowerCase()),
        );
        if (!serviceMatch) {
          continue;
        }
      }

      const listItem = toLaundryOrderListItem(order, production);

      if (query.employeeId && listItem.assignedEmployee?.id !== query.employeeId) {
        continue;
      }

      if (query.delayStatus === 'delayed' && !listItem.isDelayed) {
        continue;
      }

      if (query.delayStatus === 'on_track' && listItem.isDelayed) {
        continue;
      }

      items.push(listItem);
    }

    return {
      success: true,
      message: 'Production orders retrieved successfully',
      data: {
        items,
        meta: {
          page,
          limit,
          total: query.status ? items.length : total,
          totalPages: Math.ceil((query.status ? items.length : total) / limit) || 1,
        },
      },
    };
  }

  async findOrderDetail(
    orderId: string,
    employeeId: string,
  ): Promise<ApiSuccessResponse<LaundryOrderDetail>> {
    const order = await this.laundryRepository.findOrderById(orderId);

    if (!order) {
      throw new NotFoundException('Order not found');
    }

    const production = await this.laundryRepository.ensureProductionRecord(
      orderId,
      employeeId,
    );

    return {
      success: true,
      message: 'Production order detail retrieved successfully',
      data: toLaundryOrderDetail(order, production),
    };
  }

  async runProductionAction(
    orderId: string,
    action: ProductionActionKind,
    dto: ProductionActionDto,
    employeeId: string,
  ): Promise<ApiSuccessResponse<LaundryOrderDetail>> {
    const { from, to } = this.laundryRepository.getStagePair(action);

    let result;

    try {
      result = await this.laundryRepository.transitionStage(
        orderId,
        from,
        to,
        employeeId,
        dto.notes,
      );
    } catch (error) {
      this.handleWorkflowError(error);
    }

    await this.auditService.log({
      employeeId,
      action,
      referenceId: orderId,
      description: `Production ${from} -> ${to}`,
    });

    return {
      success: true,
      message: `Production stage updated to ${to}`,
      data: toLaundryOrderDetail(result!.order, result!.production),
    };
  }

  async qualityCheck(
    orderId: string,
    dto: QualityCheckDto,
    employeeId: string,
  ): Promise<ApiSuccessResponse<LaundryOrderDetail>> {
    const order = await this.laundryRepository.findOrderById(orderId);

    if (!order) {
      throw new NotFoundException('Order not found');
    }

    let production = await this.laundryRepository.ensureProductionRecord(
      orderId,
      employeeId,
    );

    const result = await this.qualityControlService.applyQualityCheck(
      production,
      dto,
      employeeId,
    );

    production = await this.laundryRepository.saveProductionRecord(
      result.record,
    );

    const nextOrderStatus = this.qualityControlService.resolveOrderStatus(
      result.targetStage,
    );

    const updatedOrder = await this.laundryRepository.updateOrderStatus(
      orderId,
      nextOrderStatus,
      employeeId,
      order.orderStatus,
      dto.notes,
    );

    await this.auditService.log({
      employeeId,
      action: dto.passed ? 'quality_check_pass' : 'quality_check_rework',
      referenceId: orderId,
      description: dto.notes ?? dto.reason,
    });

    return {
      success: true,
      message: dto.passed
        ? 'Quality check passed'
        : 'Quality check failed — order sent for rework',
      data: toLaundryOrderDetail(updatedOrder, production),
    };
  }

  async markReady(
    orderId: string,
    dto: ProductionActionDto,
    employeeId: string,
  ): Promise<ApiSuccessResponse<LaundryOrderDetail>> {
    const order = await this.laundryRepository.findOrderById(orderId);

    if (!order) {
      throw new NotFoundException('Order not found');
    }

    let production = await this.laundryRepository.ensureProductionRecord(
      orderId,
      employeeId,
    );

    if (!['READY', 'QUALITY_CHECK'].includes(production.currentStage)) {
      throw new BadRequestException(
        'Order must pass quality check before ready for pickup',
      );
    }

    if (production.currentStage === 'QUALITY_CHECK') {
      const lastCheck = production.qualityChecks.at(-1);

      if (!lastCheck?.passed) {
        throw new BadRequestException(
          'Quality check must pass before marking ready',
        );
      }
    }

    if (production.currentStage === 'QUALITY_CHECK') {
      const openEvent = this.historyService.getOpenStageEvent(
        production,
        'QUALITY_CHECK',
      );

      if (openEvent) {
        const completed = await this.historyService.recordStageFinish(
          orderId,
          openEvent,
          employeeId,
          dto.notes,
        );
        production.history = production.history.map((event) =>
          event.stage === 'QUALITY_CHECK' && !event.finishedAt
            ? completed
            : event,
        );
      }

      const readyEvent = await this.historyService.recordStageStart(
        orderId,
        'READY',
        employeeId,
        dto.notes,
      );
      production.history.push(readyEvent);
      production.currentStage = 'READY';
    }

    production.updatedByEmployeeId = employeeId;
    production.updatedAt = new Date().toISOString();
    production = await this.laundryRepository.saveProductionRecord(production);

    const updatedOrder = await this.laundryRepository.updateOrderStatus(
      orderId,
      OrderStatus.READY_FOR_PICKUP,
      employeeId,
      order.orderStatus,
      dto.notes ?? 'Marked ready for pickup',
    );

    await this.auditService.log({
      employeeId,
      action: 'mark_ready',
      referenceId: orderId,
      description: dto.notes ?? 'Order ready for pickup',
    });

    return {
      success: true,
      message: 'Order marked ready for pickup',
      data: toLaundryOrderDetail(updatedOrder, production),
    };
  }

  async getQueue(
    stages: ProductionStatus[],
  ): Promise<ApiSuccessResponse<LaundryOrderListItem[]>> {
    const records = this.productionSettings.sortByPriorityAndReceiveTime(
      await this.productionSettings.listByStages(stages),
    );

    if (records.length === 0) {
      return {
        success: true,
        message: 'Production queue retrieved successfully',
        data: [],
      };
    }

    const orders = await this.laundryRepository.findOrders(
      { page: 1, limit: records.length },
      records.map((record) => record.orderId),
    );

    const orderMap = new Map(orders[0].map((order) => [order.id, order]));

    const items = records
      .map((record) => {
        const order = orderMap.get(record.orderId);

        if (!order) {
          return null;
        }

        return toQueueItem(order, record);
      })
      .filter((item): item is LaundryOrderListItem => item !== null);

    return {
      success: true,
      message: 'Production queue retrieved successfully',
      data: items,
    };
  }

  private handleWorkflowError(error: unknown): never {
    if (error instanceof Error) {
      switch (error.message) {
        case 'ORDER_NOT_FOUND':
          throw new NotFoundException('Order not found');
        case 'ORDER_TERMINAL':
          throw new BadRequestException('Order cannot re-enter production');
        case 'INVALID_STAGE':
          throw new BadRequestException('Order is not in the expected production stage');
        case 'INVALID_TRANSITION':
          throw new BadRequestException('Invalid production stage transition');
        case 'STAGE_NOT_STARTED':
          throw new BadRequestException('Cannot finish a stage that has not started');
        case 'PREVIOUS_STAGE_NOT_FINISHED':
          throw new BadRequestException('Previous production stage is not finished');
      }
    }

    throw error;
  }
}
