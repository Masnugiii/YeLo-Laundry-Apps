import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../database/prisma/prisma.service';
import {
  NOTIFICATION_CHANNELS,
  NotificationChannel,
  NotificationStatus,
} from './constants/notification.constants';
import { ChannelDispatchLog } from './utils/notification-meta.util';

export interface PushDispatchPayload {
  deviceTokens: string[];
  title: string;
  body: string;
  data?: Record<string, string>;
}

export interface EmailDispatchPayload {
  to: string;
  subject: string;
  body: string;
}

export interface SmsDispatchPayload {
  to: string;
  message: string;
}

export interface DispatchResult {
  success: boolean;
  errorMessage?: string;
}

export interface PushNotificationProvider {
  send(payload: PushDispatchPayload): Promise<DispatchResult>;
}

export interface EmailNotificationProvider {
  send(payload: EmailDispatchPayload): Promise<DispatchResult>;
}

export interface SmsNotificationProvider {
  send(payload: SmsDispatchPayload): Promise<DispatchResult>;
}

@Injectable()
export class LogPushNotificationProvider implements PushNotificationProvider {
  private readonly logger = new Logger(LogPushNotificationProvider.name);

  async send(payload: PushDispatchPayload): Promise<DispatchResult> {
    this.logger.log(
      `Push dispatch prepared for ${payload.deviceTokens.length} device(s): ${payload.title}`,
    );
    return { success: true };
  }
}

@Injectable()
export class LogEmailNotificationProvider implements EmailNotificationProvider {
  private readonly logger = new Logger(LogEmailNotificationProvider.name);

  async send(payload: EmailDispatchPayload): Promise<DispatchResult> {
    this.logger.log(`Email dispatch prepared for ${payload.to}: ${payload.subject}`);
    return { success: true };
  }
}

@Injectable()
export class LogSmsNotificationProvider implements SmsNotificationProvider {
  private readonly logger = new Logger(LogSmsNotificationProvider.name);

  async send(payload: SmsDispatchPayload): Promise<DispatchResult> {
    this.logger.log(`SMS dispatch prepared for ${payload.to}`);
    return { success: true };
  }
}

export interface DispatchRequest {
  channels: NotificationChannel[];
  title: string;
  body: string;
  recipientEmail?: string;
  recipientPhone?: string;
  customerId?: string;
  data?: Record<string, string>;
}

@Injectable()
export class NotificationDispatcherService {
  constructor(
    private readonly pushProvider: LogPushNotificationProvider,
    private readonly emailProvider: LogEmailNotificationProvider,
    private readonly smsProvider: LogSmsNotificationProvider,
    private readonly prisma: PrismaService,
  ) {}

  async dispatch(request: DispatchRequest): Promise<ChannelDispatchLog[]> {
    const logs: ChannelDispatchLog[] = [];
    const uniqueChannels = [...new Set(request.channels)];

    for (const channel of uniqueChannels) {
      const attemptedAt = new Date().toISOString();
      let result: DispatchResult = { success: true };

      try {
        switch (channel) {
          case NOTIFICATION_CHANNELS.IN_APP:
            result = { success: true };
            break;
          case NOTIFICATION_CHANNELS.PUSH:
            result = await this.dispatchPush(request);
            break;
          case NOTIFICATION_CHANNELS.EMAIL:
            result = await this.dispatchEmail(request);
            break;
          case NOTIFICATION_CHANNELS.SMS:
            result = await this.dispatchSms(request);
            break;
          default:
            result = { success: false, errorMessage: `Unsupported channel ${channel}` };
        }
      } catch (error) {
        result = {
          success: false,
          errorMessage:
            error instanceof Error ? error.message : 'Dispatch failed unexpectedly',
        };
      }

      logs.push({
        channel,
        status: result.success
          ? (channel === NOTIFICATION_CHANNELS.IN_APP
              ? 'SENT'
              : 'DELIVERED')
          : 'FAILED',
        attemptedAt,
        completedAt: new Date().toISOString(),
        errorMessage: result.errorMessage,
      });
    }

    return logs;
  }

  private async dispatchPush(request: DispatchRequest): Promise<DispatchResult> {
    if (!request.customerId) {
      return { success: false, errorMessage: 'Customer ID required for push dispatch' };
    }

    const devices = await this.prisma.customerDevice.findMany({
      where: {
        customerId: request.customerId,
        deletedAt: null,
      },
      select: { deviceToken: true },
    });

    if (!devices.length) {
      return { success: false, errorMessage: 'No registered customer devices' };
    }

    return this.pushProvider.send({
      deviceTokens: devices.map((device) => device.deviceToken),
      title: request.title,
      body: request.body,
      data: request.data,
    });
  }

  private async dispatchEmail(request: DispatchRequest): Promise<DispatchResult> {
    if (!request.recipientEmail) {
      return { success: false, errorMessage: 'Recipient email not available' };
    }

    return this.emailProvider.send({
      to: request.recipientEmail,
      subject: request.title,
      body: request.body,
    });
  }

  private async dispatchSms(request: DispatchRequest): Promise<DispatchResult> {
    if (!request.recipientPhone) {
      return { success: false, errorMessage: 'Recipient phone not available' };
    }

    return this.smsProvider.send({
      to: request.recipientPhone,
      message: request.body,
    });
  }
}
