import {
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { ROLES } from '../auth/constants/roles.constant';
import { Role } from '../auth/constants/roles.constant';
import { ApiSuccessResponse } from '../common/interfaces/api-response.interface';
import { isAuthenticatedCustomer } from '../customer/interfaces/authenticated-customer.interface';
import {
  API_NOTIFICATION_PRIORITIES,
  NOTIFICATION_CHANNELS,
} from './constants/notification.constants';
import { NotificationQueryDto, SendNotificationDto } from './dto/notification.dto';
import { NotificationAuditService } from './notification-audit.service';
import { NotificationDispatcherService } from './notification-dispatcher.service';
import {
  NotificationDashboard,
  NotificationResponse,
  PaginatedNotifications,
  toNotificationResponse,
} from './notification.mapper';
import { NotificationRepository } from './notification.repository';
import {
  mapApiPriorityToPrisma,
  mapApiTypeToPrisma,
} from './utils/notification-type.util';

export interface NotificationActor {
  employeeId?: string;
  customerId?: string;
  roles: Role[];
}

@Injectable()
export class NotificationService {
  constructor(
    private readonly repository: NotificationRepository,
    private readonly dispatcher: NotificationDispatcherService,
    private readonly auditService: NotificationAuditService,
  ) {}

  async findAll(
    query: NotificationQueryDto,
    actor: NotificationActor,
  ): Promise<ApiSuccessResponse<PaginatedNotifications>> {
    const scope = this.resolveScope(actor);
    const result = await this.repository.findMany(query, scope);

    const items = result.records.map((record) => {
      const meta = result.metas.get(record.id) ?? null;
      const readRecord = scope.employeeId
        ? record.reads.find((read) => read.employeeId === scope.employeeId)
        : undefined;

      return toNotificationResponse(record, meta, {
        isRead: scope.customerId
          ? Boolean(meta?.readAt)
          : Boolean(readRecord),
        readAt: scope.customerId
          ? meta?.readAt
          : readRecord?.readAt.toISOString(),
      });
    });

    return {
      success: true,
      message: 'Notifications retrieved successfully',
      data: {
        items,
        meta: {
          page: result.page,
          limit: result.limit,
          total: result.total,
          totalPages: Math.ceil(result.total / result.limit) || 1,
        },
      },
    };
  }

  async findOne(
    id: string,
    actor: NotificationActor,
  ): Promise<ApiSuccessResponse<NotificationResponse>> {
    const record = await this.repository.findById(id);

    if (!record) {
      throw new NotFoundException('Notification not found');
    }

    const meta = await this.repository.getMeta(id);
    this.ensureAccess(actor, meta);

    const readRecord = actor.employeeId
      ? record.reads.find((read) => read.employeeId === actor.employeeId)
      : undefined;

    return {
      success: true,
      message: 'Notification retrieved successfully',
      data: toNotificationResponse(record, meta, {
        isRead: actor.customerId
          ? Boolean(meta?.readAt)
          : Boolean(readRecord),
        readAt: actor.customerId
          ? meta?.readAt
          : readRecord?.readAt.toISOString(),
      }),
    };
  }

  async sendManual(
    dto: SendNotificationDto,
    actor: NotificationActor,
  ): Promise<ApiSuccessResponse<NotificationResponse>> {
    if (!actor.roles.includes(ROLES.OWNER)) {
      throw new ForbiddenException('Only owner can send manual notifications');
    }

    if (!dto.recipientEmployeeId && !dto.recipientCustomerId) {
      throw new ForbiddenException('Recipient is required');
    }

    const channels = (dto.channels ?? [NOTIFICATION_CHANNELS.IN_APP]) as never[];
    let recipientName = dto.customerName;
    let recipientPhone: string | undefined;
    let recipientEmail: string | undefined;
    let customerId: string | undefined;

    if (dto.recipientEmployeeId) {
      const employee = await this.repository.findEmployeeById(dto.recipientEmployeeId);
      if (!employee) {
        throw new NotFoundException('Recipient employee not found');
      }
      recipientName = employee.fullName;
      recipientPhone = employee.phone;
      recipientEmail = employee.email ?? undefined;
    }

    if (dto.recipientCustomerId) {
      const customer = await this.repository.findCustomerById(dto.recipientCustomerId);
      if (!customer) {
        throw new NotFoundException('Recipient customer not found');
      }
      recipientName = customer.fullName;
      recipientPhone = customer.phone;
      recipientEmail = customer.email ?? undefined;
      customerId = customer.id;
    }

    const dispatchLog = await this.dispatcher.dispatch({
      channels: channels as never[],
      title: dto.title,
      body: dto.message,
      recipientEmail,
      recipientPhone,
      customerId,
      data: {
        orderId: dto.orderId ?? '',
        orderNumber: dto.orderNumber ?? '',
      },
    });

    const result = await this.repository.createNotification({
      title: dto.title,
      body: dto.message,
      type: mapApiTypeToPrisma(dto.type as never),
      priority: mapApiPriorityToPrisma(
        (dto.priority ?? API_NOTIFICATION_PRIORITIES.NORMAL) as never,
      ),
      senderEmployeeId: actor.employeeId,
      channels: channels as never[],
      recipientType: dto.recipientCustomerId ? 'CUSTOMER' : 'EMPLOYEE',
      recipientEmployeeId: dto.recipientEmployeeId,
      recipientCustomerId: dto.recipientCustomerId,
      recipientName,
      recipientPhone,
      recipientEmail,
      orderId: dto.orderId,
      orderNumber: dto.orderNumber,
      customerName: dto.customerName,
      dispatchLog,
    });

    await this.auditService.log({
      employeeId: actor.employeeId,
      action: 'manual_notification_sent',
      referenceId: result.notification.id,
      description: dto.title,
    });

    return {
      success: true,
      message: 'Notification sent successfully',
      data: toNotificationResponse(result.notification, result.meta, {
        isRead: false,
      }),
    };
  }

  async markRead(
    id: string,
    actor: NotificationActor,
  ): Promise<ApiSuccessResponse<NotificationResponse>> {
    const record = await this.repository.findById(id);

    if (!record) {
      throw new NotFoundException('Notification not found');
    }

    const meta = await this.repository.getMeta(id);
    this.ensureAccess(actor, meta);

    if (actor.customerId) {
      await this.repository.markCustomerRead(id);
    } else if (actor.employeeId) {
      await this.repository.markEmployeeRead(id, actor.employeeId);
    }

    return this.findOne(id, actor);
  }

  async markAllRead(
    actor: NotificationActor,
  ): Promise<ApiSuccessResponse<{ updated: number }>> {
    let updated = 0;

    if (actor.customerId) {
      updated = await this.repository.markAllCustomerRead(actor.customerId);
    } else if (actor.employeeId) {
      updated = await this.repository.markAllEmployeeRead(actor.employeeId);
    }

    return {
      success: true,
      message: 'All notifications marked as read',
      data: { updated },
    };
  }

  async remove(
    id: string,
    actor: NotificationActor,
  ): Promise<ApiSuccessResponse<{ id: string }>> {
    if (!actor.roles.includes(ROLES.OWNER)) {
      throw new ForbiddenException('Only owner can delete notifications');
    }

    const record = await this.repository.findById(id);

    if (!record) {
      throw new NotFoundException('Notification not found');
    }

    await this.repository.softDelete(id);

    await this.auditService.log({
      employeeId: actor.employeeId,
      action: 'notification_deleted',
      referenceId: id,
    });

    return {
      success: true,
      message: 'Notification deleted successfully',
      data: { id },
    };
  }

  async getUnreadCount(
    actor: NotificationActor,
  ): Promise<ApiSuccessResponse<{ count: number }>> {
    let count = 0;

    if (actor.customerId) {
      count = await this.repository.countUnreadForCustomer(actor.customerId);
    } else if (actor.employeeId) {
      count = await this.repository.countUnreadForEmployee(actor.employeeId);
    }

    return {
      success: true,
      message: 'Unread count retrieved successfully',
      data: { count },
    };
  }

  async getDashboard(
    actor: NotificationActor,
  ): Promise<ApiSuccessResponse<NotificationDashboard>> {
    const scope = this.resolveScope(actor);

    if (
      !scope.canViewAll &&
      !actor.roles.includes(ROLES.MANAGER) &&
      !actor.roles.includes(ROLES.OWNER)
    ) {
      throw new ForbiddenException('Dashboard access denied');
    }

    const dashboard = await this.repository.getDashboard(scope);

    return {
      success: true,
      message: 'Notification dashboard retrieved successfully',
      data: dashboard,
    };
  }

  private resolveScope(actor: NotificationActor) {
    const canViewAll =
      actor.roles.includes(ROLES.OWNER) ||
      actor.roles.includes(ROLES.MANAGER);

    return {
      employeeId: actor.employeeId,
      customerId: actor.customerId,
      canViewAll,
    };
  }

  private ensureAccess(
    actor: NotificationActor,
    meta: import('./utils/notification-meta.util').NotificationDeliveryMeta | null,
  ) {
    if (actor.roles.includes(ROLES.OWNER) || actor.roles.includes(ROLES.MANAGER)) {
      return;
    }

    if (actor.customerId) {
      if (meta?.recipientCustomerId !== actor.customerId) {
        throw new ForbiddenException('Access denied');
      }
      return;
    }

    if (actor.employeeId) {
      if (meta?.recipientEmployeeId && meta.recipientEmployeeId !== actor.employeeId) {
        throw new ForbiddenException('Access denied');
      }
    }
  }

  static actorFromUser(user: unknown): NotificationActor {
    if (isAuthenticatedCustomer(user)) {
      return {
        customerId: user.customerId,
        roles: [],
      };
    }

    const employee = user as {
      employeeId: string;
      roles: Role[];
    };

    return {
      employeeId: employee.employeeId,
      roles: employee.roles ?? [],
    };
  }
}
