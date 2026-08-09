import { Injectable, Logger } from '@nestjs/common';
import { RoleCode } from '@prisma/client';
import { ROLES } from '../auth/constants/roles.constant';
import { NotificationConfigService } from '../settings/config/notification-config.service';
import {
  API_NOTIFICATION_PRIORITIES,
  API_NOTIFICATION_TYPES,
  NOTIFICATION_CHANNELS,
  NOTIFICATION_EVENTS,
  NotificationEventKey,
} from './constants/notification.constants';
import { NotificationAuditService } from './notification-audit.service';
import { NotificationDispatcherService } from './notification-dispatcher.service';
import { NotificationRepository } from './notification.repository';
import {
  NotificationTemplateService,
  TemplateContext,
} from './notification-template.service';
import { mapApiPriorityToPrisma, mapApiTypeToPrisma } from './utils/notification-type.util';
import { ApiNotificationType } from './constants/notification.constants';

export interface NotificationEventPayload {
  eventKey?: string;
  deduplicateKey?: string;
  templateCode: NotificationEventKey | string;
  type: ApiNotificationType;
  priority?: string;
  channels?: string[];
  senderEmployeeId?: string;
  orderId?: string;
  orderNumber?: string;
  customerId?: string;
  customerName?: string;
  driverId?: string;
  driverName?: string;
  amount?: string | number;
  estimatedTime?: string;
  title?: string;
  body?: string;
  notifyRoles?: string[];
  notifyEmployeeIds?: string[];
  notifyCustomer?: boolean;
}

@Injectable()
export class NotificationEventService {
  private readonly logger = new Logger(NotificationEventService.name);

  constructor(
    private readonly repository: NotificationRepository,
    private readonly templateService: NotificationTemplateService,
    private readonly dispatcher: NotificationDispatcherService,
    private readonly auditService: NotificationAuditService,
    private readonly notificationConfigService: NotificationConfigService,
  ) {}

  async publish(payload: NotificationEventPayload): Promise<void> {
    const deduplicateKey =
      payload.deduplicateKey ??
      (payload.eventKey ? `${payload.templateCode}:${payload.eventKey}` : undefined);

    if (deduplicateKey && (await this.repository.isEventProcessed(deduplicateKey))) {
      this.logger.debug(`Skipping duplicate notification event: ${deduplicateKey}`);
      return;
    }

    const isEnabled = await this.notificationConfigService.isTemplateCodeEnabled(
      payload.templateCode,
    );
    if (!isEnabled) {
      this.logger.debug(
        `Skipping notification event ${payload.templateCode}: outlet toggle disabled`,
      );
      return;
    }

    const context: TemplateContext = {
      customerName: payload.customerName,
      orderNumber: payload.orderNumber,
      amount: payload.amount,
      driverName: payload.driverName,
      estimatedTime: payload.estimatedTime,
    };

    const rendered = await this.templateService.render(
      payload.templateCode,
      context,
      payload.title && payload.body
        ? { title: payload.title, body: payload.body }
        : undefined,
    );

    const channels = (payload.channels ?? [NOTIFICATION_CHANNELS.IN_APP]) as never[];
    const priority = mapApiPriorityToPrisma(
      (payload.priority ?? API_NOTIFICATION_PRIORITIES.NORMAL) as never,
    );
    const type = mapApiTypeToPrisma(payload.type);

    const recipients = await this.resolveRecipients(payload);
    let firstNotificationId: string | undefined;

    for (const recipient of recipients) {
      const dispatchLog = await this.dispatcher.dispatch({
        channels: channels as never[],
        title: rendered.title,
        body: rendered.body,
        recipientEmail: recipient.email ?? undefined,
        recipientPhone: recipient.phone ?? undefined,
        customerId: recipient.customerId,
        data: {
          orderId: payload.orderId ?? '',
          orderNumber: payload.orderNumber ?? '',
          event: payload.templateCode,
        },
      });

      const result = await this.repository.createNotification({
        title: rendered.title,
        body: rendered.body,
        type,
        priority,
        senderEmployeeId: payload.senderEmployeeId,
        channels: channels as never[],
        recipientType: recipient.customerId ? 'CUSTOMER' : 'EMPLOYEE',
        recipientEmployeeId: recipient.employeeId,
        recipientCustomerId: recipient.customerId,
        recipientName: recipient.name,
        recipientPhone: recipient.phone ?? undefined,
        recipientEmail: recipient.email ?? undefined,
        orderId: payload.orderId,
        orderNumber: payload.orderNumber,
        customerName: payload.customerName,
        eventKey: deduplicateKey,
        templateCode: payload.templateCode,
        dispatchLog,
      });

      firstNotificationId ??= result.notification.id;

      await this.auditService.log({
        employeeId: payload.senderEmployeeId,
        action: 'notification_sent',
        referenceId: result.notification.id,
        description: `${payload.templateCode} -> ${recipient.name}`,
      });
    }

    if (deduplicateKey && firstNotificationId) {
      await this.repository.markEventProcessed(deduplicateKey, firstNotificationId);
    }
  }

  async publishPickupDeliveryEvent(
    event:
      | 'pickup_requested'
      | 'driver_assigned'
      | 'driver_on_the_way'
      | 'pickup_completed'
      | 'ready_for_delivery'
      | 'delivery_started'
      | 'delivery_completed',
    params: {
      orderId: string;
      orderNumber: string;
      employeeId?: string;
      driverId?: string;
      driverName?: string;
      customerId?: string;
      customerName?: string;
      estimatedTime?: string;
    },
  ): Promise<void> {
    const mapping: Record<
      typeof event,
      {
        templateCode: NotificationEventKey;
        type: ApiNotificationType;
        notifyRoles?: string[];
        notifyEmployeeIds?: string[];
        notifyCustomer?: boolean;
      }
    > = {
      pickup_requested: {
        templateCode: NOTIFICATION_EVENTS.PICKUP_REQUESTED,
        type: API_NOTIFICATION_TYPES.PICKUP,
        notifyRoles: [ROLES.OWNER, ROLES.MANAGER, ROLES.DRIVER],
      },
      driver_assigned: {
        templateCode: NOTIFICATION_EVENTS.DRIVER_ASSIGNED,
        type: API_NOTIFICATION_TYPES.PICKUP,
        notifyEmployeeIds: params.driverId ? [params.driverId] : undefined,
        notifyCustomer: true,
      },
      driver_on_the_way: {
        templateCode: NOTIFICATION_EVENTS.DRIVER_ON_THE_WAY,
        type: API_NOTIFICATION_TYPES.PICKUP,
        notifyCustomer: true,
        notifyEmployeeIds: params.driverId ? [params.driverId] : undefined,
      },
      pickup_completed: {
        templateCode: NOTIFICATION_EVENTS.PICKUP_COMPLETED,
        type: API_NOTIFICATION_TYPES.PICKUP,
        notifyRoles: [ROLES.OWNER, ROLES.MANAGER, ROLES.CASHIER],
        notifyCustomer: true,
      },
      ready_for_delivery: {
        templateCode: NOTIFICATION_EVENTS.READY_FOR_PICKUP,
        type: API_NOTIFICATION_TYPES.DELIVERY,
        notifyRoles: [ROLES.OWNER, ROLES.MANAGER, ROLES.DRIVER],
        notifyCustomer: true,
      },
      delivery_started: {
        templateCode: NOTIFICATION_EVENTS.DELIVERY_STARTED,
        type: API_NOTIFICATION_TYPES.DELIVERY,
        notifyCustomer: true,
        notifyEmployeeIds: params.driverId ? [params.driverId] : undefined,
      },
      delivery_completed: {
        templateCode: NOTIFICATION_EVENTS.DELIVERY_COMPLETED,
        type: API_NOTIFICATION_TYPES.DELIVERY,
        notifyRoles: [ROLES.OWNER, ROLES.MANAGER, ROLES.CASHIER],
        notifyCustomer: true,
      },
    };

    const config = mapping[event];

    await this.publish({
      templateCode: config.templateCode,
      type: config.type,
      eventKey: params.orderId,
      deduplicateKey: `${config.templateCode}:${params.orderId}`,
      senderEmployeeId: params.employeeId,
      orderId: params.orderId,
      orderNumber: params.orderNumber,
      customerId: params.customerId,
      customerName: params.customerName,
      driverId: params.driverId,
      driverName: params.driverName,
      estimatedTime: params.estimatedTime,
      notifyRoles: config.notifyRoles,
      notifyEmployeeIds: config.notifyEmployeeIds,
      notifyCustomer: config.notifyCustomer,
    });
  }

  private async resolveRecipients(payload: NotificationEventPayload) {
    const recipients: Array<{
      employeeId?: string;
      customerId?: string;
      name: string;
      phone?: string | null;
      email?: string | null;
    }> = [];
    const seen = new Set<string>();

    const addRecipient = (recipient: {
      employeeId?: string;
      customerId?: string;
      name: string;
      phone?: string | null;
      email?: string | null;
    }) => {
      const key = recipient.employeeId ?? recipient.customerId;
      if (!key || seen.has(key)) {
        return;
      }
      seen.add(key);
      recipients.push(recipient);
    };

    if (payload.notifyEmployeeIds?.length) {
      for (const employeeId of payload.notifyEmployeeIds) {
        const employee = await this.repository.findEmployeeById(employeeId);
        if (employee) {
          addRecipient({
            employeeId: employee.id,
            name: employee.fullName,
            phone: employee.phone,
            email: employee.email,
          });
        }
      }
    }

    if (payload.notifyRoles?.length) {
      const roleCodes = payload.notifyRoles
        .map((role) => this.mapRoleToCode(role))
        .filter((code): code is RoleCode => Boolean(code));

      const employees = await this.repository.findEmployeesByRoles(roleCodes);
      for (const employee of employees) {
        addRecipient({
          employeeId: employee.id,
          name: employee.fullName,
          phone: employee.phone,
          email: employee.email,
        });
      }
    }

    if (payload.notifyCustomer && payload.customerId) {
      const customer = await this.repository.findCustomerById(payload.customerId);
      if (customer) {
        addRecipient({
          customerId: customer.id,
          name: customer.fullName,
          phone: customer.phone,
          email: customer.email,
        });
      }
    }

    if (!recipients.length && payload.driverId) {
      const driver = await this.repository.findEmployeeById(payload.driverId);
      if (driver) {
        addRecipient({
          employeeId: driver.id,
          name: driver.fullName,
          phone: driver.phone,
          email: driver.email,
        });
      }
    }

    return recipients;
  }

  private mapRoleToCode(role: string): RoleCode | null {
    const mapping: Record<string, RoleCode> = {
      [ROLES.OWNER]: RoleCode.owner,
      [ROLES.MANAGER]: RoleCode.cashier_laundry_driver,
      [ROLES.CASHIER]: RoleCode.cashier,
      [ROLES.OPERATOR]: RoleCode.cashier_laundry,
      [ROLES.BINATU]: RoleCode.laundry,
      [ROLES.DRIVER]: RoleCode.driver,
    };

    return mapping[role] ?? null;
  }
}
