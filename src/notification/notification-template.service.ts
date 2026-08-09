import { Injectable } from '@nestjs/common';
import { PrismaService } from '../database/prisma/prisma.service';
import { NOTIFICATION_EVENTS } from './constants/notification.constants';
import { TemplateVariable } from './constants/notification.constants';

export interface RenderedTemplate {
  title: string;
  body: string;
}

export interface TemplateContext {
  customerName?: string;
  orderNumber?: string;
  amount?: string | number;
  driverName?: string;
  estimatedTime?: string;
}

const DEFAULT_TEMPLATES: Record<
  string,
  { title: string; body: string; variables: TemplateVariable[] }
> = {
  [NOTIFICATION_EVENTS.ORDER_CREATED]: {
    title: 'Order Created',
    body: 'Order {{orderNumber}} has been created for {{customerName}}.',
    variables: ['orderNumber', 'customerName'],
  },
  [NOTIFICATION_EVENTS.ORDER_CANCELLED]: {
    title: 'Order Cancelled',
    body: 'Order {{orderNumber}} has been cancelled.',
    variables: ['orderNumber'],
  },
  [NOTIFICATION_EVENTS.PAYMENT_SUCCESS]: {
    title: 'Payment Successful',
    body: 'Payment of {{amount}} for order {{orderNumber}} was successful.',
    variables: ['amount', 'orderNumber'],
  },
  [NOTIFICATION_EVENTS.PAYMENT_FAILED]: {
    title: 'Payment Failed',
    body: 'Payment for order {{orderNumber}} has failed.',
    variables: ['orderNumber'],
  },
  [NOTIFICATION_EVENTS.REFUND_SUCCESS]: {
    title: 'Refund Processed',
    body: 'Refund of {{amount}} for order {{orderNumber}} has been processed.',
    variables: ['amount', 'orderNumber'],
  },
  [NOTIFICATION_EVENTS.LAUNDRY_STARTED]: {
    title: 'Laundry Started',
    body: 'Laundry production has started for order {{orderNumber}}.',
    variables: ['orderNumber'],
  },
  [NOTIFICATION_EVENTS.LAUNDRY_FINISHED]: {
    title: 'Laundry Finished',
    body: 'Laundry production is finished for order {{orderNumber}}.',
    variables: ['orderNumber'],
  },
  [NOTIFICATION_EVENTS.READY_FOR_PICKUP]: {
    title: 'Ready For Pickup',
    body: 'Order {{orderNumber}} is ready for pickup.',
    variables: ['orderNumber'],
  },
  [NOTIFICATION_EVENTS.PICKUP_REQUESTED]: {
    title: 'Pickup Requested',
    body: 'Pickup requested for order {{orderNumber}}.',
    variables: ['orderNumber'],
  },
  [NOTIFICATION_EVENTS.DRIVER_ASSIGNED]: {
    title: 'Driver Assigned',
    body: 'Driver {{driverName}} assigned for order {{orderNumber}}.',
    variables: ['driverName', 'orderNumber'],
  },
  [NOTIFICATION_EVENTS.DRIVER_ON_THE_WAY]: {
    title: 'Driver On The Way',
    body: 'Driver is on the way for order {{orderNumber}}. ETA {{estimatedTime}}.',
    variables: ['orderNumber', 'estimatedTime'],
  },
  [NOTIFICATION_EVENTS.DRIVER_STARTED]: {
    title: 'Delivery Started',
    body: 'Driver has started delivery for order {{orderNumber}}.',
    variables: ['orderNumber'],
  },
  [NOTIFICATION_EVENTS.PICKUP_COMPLETED]: {
    title: 'Pickup Completed',
    body: 'Pickup completed for order {{orderNumber}}.',
    variables: ['orderNumber'],
  },
  [NOTIFICATION_EVENTS.DELIVERY_STARTED]: {
    title: 'Delivery Started',
    body: 'Delivery started for order {{orderNumber}}.',
    variables: ['orderNumber'],
  },
  [NOTIFICATION_EVENTS.DELIVERY_COMPLETED]: {
    title: 'Delivery Completed',
    body: 'Order {{orderNumber}} has been delivered successfully.',
    variables: ['orderNumber'],
  },
  [NOTIFICATION_EVENTS.ATTENDANCE_LATE]: {
    title: 'Late Attendance',
    body: '{{customerName}} was marked late today.',
    variables: ['customerName'],
  },
  [NOTIFICATION_EVENTS.LEAVE_APPROVED]: {
    title: 'Leave Approved',
    body: 'Your leave request has been approved.',
    variables: [],
  },
  [NOTIFICATION_EVENTS.LEAVE_REJECTED]: {
    title: 'Leave Rejected',
    body: 'Your leave request has been rejected.',
    variables: [],
  },
  [NOTIFICATION_EVENTS.WALLET_TOPUP]: {
    title: 'Wallet Top Up',
    body: 'Wallet topped up with {{amount}}.',
    variables: ['amount'],
  },
  [NOTIFICATION_EVENTS.WALLET_DEDUCTION]: {
    title: 'Wallet Deduction',
    body: 'Wallet deducted by {{amount}}.',
    variables: ['amount'],
  },
  [NOTIFICATION_EVENTS.PROMOTION]: {
    title: 'Promotion',
    body: 'New promotion available for {{customerName}}.',
    variables: ['customerName'],
  },
};

@Injectable()
export class NotificationTemplateService {
  constructor(private readonly prisma: PrismaService) {}

  async render(
    templateCode: string,
    context: TemplateContext,
    fallback?: { title: string; body: string },
  ): Promise<RenderedTemplate> {
    const dbTemplate = await this.prisma.notificationTemplate.findFirst({
      where: {
        code: templateCode,
        isActive: true,
        deletedAt: null,
      },
      select: { title: true, body: true },
    });

    const template =
      dbTemplate ??
      DEFAULT_TEMPLATES[templateCode] ??
      fallback ?? {
        title: 'Notification',
        body: 'You have a new notification.',
      };

    return {
      title: this.interpolate(template.title, context),
      body: this.interpolate(template.body, context),
    };
  }

  private interpolate(template: string, context: TemplateContext): string {
    return template.replace(/\{\{(\w+)\}\}/g, (_, key: string) => {
      const value = context[key as keyof TemplateContext];
      return value !== undefined && value !== null ? String(value) : '';
    });
  }
}
