import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../database/prisma/prisma.service';
import { NOTIFICATION_EVENTS } from '../../notification/constants/notification.constants';
import {
  DEFAULT_NOTIFICATION_TOGGLE_SETTINGS,
  NOTIFICATION_SETTINGS_KEY,
  NotificationConfig,
  NotificationToggleSettings,
  UpdateNotificationConfigInput,
} from '../types/notification-settings.types';

const EVENT_TOGGLE_MAP: Partial<
  Record<string, keyof NotificationToggleSettings>
> = {
  [NOTIFICATION_EVENTS.ORDER_CREATED]: 'notify_new_order',
  [NOTIFICATION_EVENTS.ORDER_CANCELLED]: 'notify_new_order',
  [NOTIFICATION_EVENTS.LAUNDRY_STARTED]: 'notify_new_order',
  [NOTIFICATION_EVENTS.PAYMENT_SUCCESS]: 'notify_payment',
  [NOTIFICATION_EVENTS.PAYMENT_FAILED]: 'notify_payment',
  [NOTIFICATION_EVENTS.REFUND_SUCCESS]: 'notify_payment',
  [NOTIFICATION_EVENTS.LAUNDRY_FINISHED]: 'notify_ironing_finished',
  [NOTIFICATION_EVENTS.READY_FOR_PICKUP]: 'notify_ironing_finished',
  [NOTIFICATION_EVENTS.PICKUP_REQUESTED]: 'notify_pickup_delivery',
  [NOTIFICATION_EVENTS.PICKUP_COMPLETED]: 'notify_pickup_delivery',
  [NOTIFICATION_EVENTS.DELIVERY_STARTED]: 'notify_pickup_delivery',
  [NOTIFICATION_EVENTS.DELIVERY_COMPLETED]: 'notify_pickup_delivery',
  [NOTIFICATION_EVENTS.DRIVER_ASSIGNED]: 'notify_pickup_delivery',
  [NOTIFICATION_EVENTS.DRIVER_ON_THE_WAY]: 'notify_pickup_delivery',
  [NOTIFICATION_EVENTS.DRIVER_STARTED]: 'notify_pickup_delivery',
  [NOTIFICATION_EVENTS.WALLET_TOPUP]: 'notify_wallet',
  [NOTIFICATION_EVENTS.WALLET_DEDUCTION]: 'notify_wallet',
};

@Injectable()
export class NotificationConfigService {
  constructor(private readonly prisma: PrismaService) {}

  async getConfig(): Promise<NotificationConfig> {
    const [settings, templates] = await Promise.all([
      this.getToggleSettings(),
      this.prisma.notificationTemplate.findMany({
        where: { deletedAt: null },
        orderBy: { code: 'asc' },
        select: {
          id: true,
          code: true,
          title: true,
          body: true,
          isActive: true,
        },
      }),
    ]);

    return { settings, templates };
  }

  async getToggleSettings(): Promise<NotificationToggleSettings> {
    const setting = await this.prisma.systemSetting.findUnique({
      where: { settingKey: NOTIFICATION_SETTINGS_KEY },
      select: { settingValue: true },
    });

    if (!setting) {
      return { ...DEFAULT_NOTIFICATION_TOGGLE_SETTINGS };
    }

    return this.normalizeToggleSettings(
      JSON.parse(setting.settingValue) as Partial<NotificationToggleSettings>,
    );
  }

  async updateConfig(
    dto: UpdateNotificationConfigInput,
  ): Promise<NotificationConfig> {
    if (dto.settings) {
      const current = await this.getToggleSettings();
      const next = this.normalizeToggleSettings({
        ...current,
        ...dto.settings,
      });

      await this.prisma.systemSetting.upsert({
        where: { settingKey: NOTIFICATION_SETTINGS_KEY },
        create: {
          settingKey: NOTIFICATION_SETTINGS_KEY,
          settingValue: JSON.stringify(next),
          description: 'Notification outlet toggles',
        },
        update: { settingValue: JSON.stringify(next) },
      });
    }

    if (dto.templates?.length) {
      for (const template of dto.templates) {
        const existing = await this.prisma.notificationTemplate.findFirst({
          where: { id: template.id, deletedAt: null },
        });

        if (!existing) {
          throw new NotFoundException(
            `Notification template not found: ${template.id}`,
          );
        }

        await this.prisma.notificationTemplate.update({
          where: { id: template.id },
          data: {
            ...(template.title !== undefined && { title: template.title }),
            ...(template.body !== undefined && { body: template.body }),
            ...(template.isActive !== undefined && {
              isActive: template.isActive,
            }),
          },
        });
      }
    }

    return this.getConfig();
  }

  async isTemplateCodeEnabled(templateCode: string): Promise<boolean> {
    const toggleKey = EVENT_TOGGLE_MAP[templateCode];
    if (!toggleKey) {
      return true;
    }

    const settings = await this.getToggleSettings();
    return settings[toggleKey];
  }

  private normalizeToggleSettings(
    input: Partial<NotificationToggleSettings>,
  ): NotificationToggleSettings {
    return {
      notify_new_order:
        typeof input.notify_new_order === 'boolean'
          ? input.notify_new_order
          : DEFAULT_NOTIFICATION_TOGGLE_SETTINGS.notify_new_order,
      notify_payment:
        typeof input.notify_payment === 'boolean'
          ? input.notify_payment
          : DEFAULT_NOTIFICATION_TOGGLE_SETTINGS.notify_payment,
      notify_ironing_finished:
        typeof input.notify_ironing_finished === 'boolean'
          ? input.notify_ironing_finished
          : DEFAULT_NOTIFICATION_TOGGLE_SETTINGS.notify_ironing_finished,
      notify_pickup_delivery:
        typeof input.notify_pickup_delivery === 'boolean'
          ? input.notify_pickup_delivery
          : DEFAULT_NOTIFICATION_TOGGLE_SETTINGS.notify_pickup_delivery,
      notify_wallet:
        typeof input.notify_wallet === 'boolean'
          ? input.notify_wallet
          : DEFAULT_NOTIFICATION_TOGGLE_SETTINGS.notify_wallet,
    };
  }
}
