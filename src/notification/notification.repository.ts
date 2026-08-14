import { Injectable } from '@nestjs/common';
import {
  NotificationType,
  PriorityLevel,
  Prisma,
} from '@prisma/client';
import { PrismaService } from '../database/prisma/prisma.service';
import { NotificationQueryDto } from './dto/notification.dto';
import {
  notificationDetailSelect,
  notificationListSelect,
  NotificationListRecord,
} from './notification.select';
import {
  NOTIFICATION_CUSTOMER_INDEX_PREFIX,
  NOTIFICATION_EMPLOYEE_INDEX_PREFIX,
  NOTIFICATION_META_PREFIX,
  NOTIFICATION_STATUSES,
  NotificationChannel,
  NotificationStatus,
} from './constants/notification.constants';
import { mapApiTypeToPrisma } from './utils/notification-type.util';
import {
  buildCustomerIndexKey,
  buildEmployeeIndexKey,
  buildEventDedupKey,
  buildMetaSettingKey,
  encodeNotificationMeta,
  extractNotificationIdFromIndexKey,
  NotificationDeliveryMeta,
  parseNotificationMeta,
} from './utils/notification-meta.util';

export interface CreateNotificationInput {
  title: string;
  body: string;
  type: NotificationType;
  priority: PriorityLevel;
  senderEmployeeId?: string;
  channels: NotificationChannel[];
  recipientType: 'EMPLOYEE' | 'CUSTOMER';
  recipientEmployeeId?: string;
  recipientCustomerId?: string;
  recipientName?: string;
  recipientPhone?: string;
  recipientEmail?: string;
  orderId?: string;
  orderNumber?: string;
  customerName?: string;
  eventKey?: string;
  templateCode?: string;
  status?: NotificationStatus;
  dispatchLog?: NotificationDeliveryMeta['dispatchLog'];
}

@Injectable()
export class NotificationRepository {
  constructor(private readonly prisma: PrismaService) {}

  async isEventProcessed(eventKey: string): Promise<boolean> {
    const setting = await this.prisma.systemSetting.findUnique({
      where: { settingKey: buildEventDedupKey(eventKey) },
      select: { id: true },
    });

    return Boolean(setting);
  }

  async markEventProcessed(eventKey: string, notificationId: string) {
    await this.prisma.systemSetting.upsert({
      where: { settingKey: buildEventDedupKey(eventKey) },
      create: {
        settingKey: buildEventDedupKey(eventKey),
        settingValue: notificationId,
        description: `Notification event ${eventKey}`,
      },
      update: { settingValue: notificationId },
    });
  }

  async createNotification(input: CreateNotificationInput) {
    return this.prisma.$transaction(async (tx) => {
      const notification = await tx.notification.create({
        data: {
          title: input.title,
          body: input.body,
          type: input.type,
          priority: input.priority,
          senderEmployeeId: input.senderEmployeeId,
        },
        select: notificationDetailSelect,
      });

      const status =
        input.status ??
        (input.dispatchLog?.some((log) => log.status === 'FAILED')
          ? NOTIFICATION_STATUSES.FAILED
          : NOTIFICATION_STATUSES.SENT);

      const meta: NotificationDeliveryMeta = {
        notificationId: notification.id,
        channels: input.channels,
        status,
        recipientType: input.recipientType,
        recipientEmployeeId: input.recipientEmployeeId,
        recipientCustomerId: input.recipientCustomerId,
        recipientName: input.recipientName,
        recipientPhone: input.recipientPhone,
        recipientEmail: input.recipientEmail,
        orderId: input.orderId,
        orderNumber: input.orderNumber,
        customerName: input.customerName,
        eventKey: input.eventKey,
        templateCode: input.templateCode,
        createdByEmployeeId: input.senderEmployeeId,
        sentAt: new Date().toISOString(),
        dispatchLog: input.dispatchLog ?? [],
      };

      await tx.systemSetting.create({
        data: {
          settingKey: buildMetaSettingKey(notification.id),
          settingValue: encodeNotificationMeta(meta),
          description: `Notification delivery ${notification.id}`,
        },
      });

      if (input.recipientEmployeeId) {
        await tx.systemSetting.create({
          data: {
            settingKey: buildEmployeeIndexKey(
              input.recipientEmployeeId,
              notification.id,
            ),
            settingValue: '1',
            description: `Employee notification index ${notification.id}`,
          },
        });
      }

      if (input.recipientCustomerId) {
        await tx.systemSetting.create({
          data: {
            settingKey: buildCustomerIndexKey(
              input.recipientCustomerId,
              notification.id,
            ),
            settingValue: '1',
            description: `Customer notification index ${notification.id}`,
          },
        });
      }

      return { notification, meta };
    });
  }

  async findNotificationIdsForEmployee(employeeId: string): Promise<string[]> {
    const settings = await this.prisma.systemSetting.findMany({
      where: {
        settingKey: { startsWith: `${NOTIFICATION_EMPLOYEE_INDEX_PREFIX}${employeeId}.` },
      },
      select: { settingKey: true },
    });

    return settings
      .map((setting) =>
        extractNotificationIdFromIndexKey(
          `${NOTIFICATION_EMPLOYEE_INDEX_PREFIX}${employeeId}.`,
          setting.settingKey,
        ),
      )
      .filter((id): id is string => Boolean(id));
  }

  async findNotificationIdsForCustomer(customerId: string): Promise<string[]> {
    const settings = await this.prisma.systemSetting.findMany({
      where: {
        settingKey: {
          startsWith: `${NOTIFICATION_CUSTOMER_INDEX_PREFIX}${customerId}.`,
        },
      },
      select: { settingKey: true },
    });

    return settings
      .map((setting) =>
        extractNotificationIdFromIndexKey(
          `${NOTIFICATION_CUSTOMER_INDEX_PREFIX}${customerId}.`,
          setting.settingKey,
        ),
      )
      .filter((id): id is string => Boolean(id));
  }

  async findMany(
    query: NotificationQueryDto,
    scope: {
      employeeId?: string;
      customerId?: string;
      canViewAll: boolean;
    },
  ) {
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const skip = (page - 1) * limit;

    let scopedIds: string[] | undefined;

    if (scope.customerId) {
      scopedIds = await this.findNotificationIdsForCustomer(scope.customerId);
    } else if (!scope.canViewAll && scope.employeeId) {
      scopedIds = await this.findNotificationIdsForEmployee(scope.employeeId);
    }

    const where: Prisma.NotificationWhereInput = {
      deletedAt: null,
      ...(scopedIds ? { id: { in: scopedIds } } : {}),
      ...(query.type
        ? { type: mapApiTypeToPrisma(query.type as never) }
        : {}),
      ...(query.priority
        ? { priority: query.priority as PriorityLevel }
        : {}),
      ...(query.dateFrom || query.dateTo
        ? {
            createdAt: {
              ...(query.dateFrom ? { gte: query.dateFrom } : {}),
              ...(query.dateTo ? { lte: query.dateTo } : {}),
            },
          }
        : {}),
      ...(query.search
        ? {
            OR: [
              { title: { contains: query.search, mode: 'insensitive' } },
              { body: { contains: query.search, mode: 'insensitive' } },
            ],
          }
        : {}),
      ...(query.recipient
        ? {
            OR: [
              { senderEmployeeId: query.recipient },
            ],
          }
        : {}),
    };

    const [records, total] = await this.prisma.$transaction([
      this.prisma.notification.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        select: notificationListSelect,
      }),
      this.prisma.notification.count({ where }),
    ]);

    const metas = await this.loadMetas(records.map((record) => record.id));
    const filtered = this.applyMetaFilters(records, metas, query, scope);

    return {
      records: filtered.records,
      metas: filtered.metas,
      total: scopedIds ? filtered.records.length : total,
      page,
      limit,
    };
  }

  private applyMetaFilters(
    records: NotificationListRecord[],
    metas: Map<string, NotificationDeliveryMeta>,
    query: NotificationQueryDto,
    scope: { employeeId?: string; customerId?: string },
  ) {
    let filteredRecords = records;

    if (query.status) {
      filteredRecords = filteredRecords.filter(
        (record) => metas.get(record.id)?.status === query.status,
      );
    }

    if (query.search) {
      const term = query.search.toLowerCase();
      filteredRecords = filteredRecords.filter((record) => {
        const meta = metas.get(record.id);
        return (
          record.title.toLowerCase().includes(term) ||
          record.body.toLowerCase().includes(term) ||
          meta?.orderNumber?.toLowerCase().includes(term) ||
          meta?.customerName?.toLowerCase().includes(term) ||
          meta?.recipientName?.toLowerCase().includes(term)
        );
      });
    }

    if (query.recipient) {
      filteredRecords = filteredRecords.filter((record) => {
        const meta = metas.get(record.id);
        return (
          meta?.recipientEmployeeId === query.recipient ||
          meta?.recipientCustomerId === query.recipient
        );
      });
    }

    if (query.isRead !== undefined) {
      filteredRecords = filteredRecords.filter((record) => {
        const meta = metas.get(record.id);
        const employeeRead = scope.employeeId
          ? record.reads.some((read) => read.employeeId === scope.employeeId)
          : false;
        const customerRead = Boolean(meta?.readAt);
        const isRead = scope.customerId ? customerRead : employeeRead;
        return query.isRead ? isRead : !isRead;
      });
    }

    const filteredMetas = new Map<string, NotificationDeliveryMeta>();
    for (const record of filteredRecords) {
      const meta = metas.get(record.id);
      if (meta) {
        filteredMetas.set(record.id, meta);
      }
    }

    return { records: filteredRecords, metas: filteredMetas };
  }

  async findById(id: string) {
    return this.prisma.notification.findFirst({
      where: { id, deletedAt: null },
      select: notificationDetailSelect,
    });
  }

  async getMeta(notificationId: string): Promise<NotificationDeliveryMeta | null> {
    const setting = await this.prisma.systemSetting.findUnique({
      where: { settingKey: buildMetaSettingKey(notificationId) },
      select: { settingValue: true },
    });

    if (!setting) {
      return null;
    }

    return parseNotificationMeta(setting.settingValue);
  }

  async loadMetas(
    notificationIds: string[],
  ): Promise<Map<string, NotificationDeliveryMeta>> {
    if (!notificationIds.length) {
      return new Map();
    }

    const settings = await this.prisma.systemSetting.findMany({
      where: {
        settingKey: {
          in: notificationIds.map((id) => buildMetaSettingKey(id)),
        },
      },
      select: { settingKey: true, settingValue: true },
    });

    const map = new Map<string, NotificationDeliveryMeta>();

    for (const setting of settings) {
      const notificationId = setting.settingKey.replace(NOTIFICATION_META_PREFIX, '');
      const meta = parseNotificationMeta(setting.settingValue);
      if (meta) {
        map.set(notificationId, meta);
      }
    }

    return map;
  }

  async markEmployeeRead(notificationId: string, employeeId: string) {
    return this.prisma.$transaction(async (tx) => {
      await tx.notificationRead.upsert({
        where: {
          notificationId_employeeId: {
            notificationId,
            employeeId,
          },
        },
        create: { notificationId, employeeId },
        update: { readAt: new Date() },
      });

      await this.updateMetaReadStatus(tx, notificationId);
    });
  }

  async markCustomerRead(notificationId: string) {
    return this.prisma.$transaction(async (tx) => {
      await this.updateMetaReadStatus(tx, notificationId, true);
    });
  }

  async markAllEmployeeRead(employeeId: string) {
    const notificationIds = await this.findNotificationIdsForEmployee(employeeId);

    if (!notificationIds.length) {
      return 0;
    }

    await this.prisma.$transaction(async (tx) => {
      for (const notificationId of notificationIds) {
        await tx.notificationRead.upsert({
          where: {
            notificationId_employeeId: {
              notificationId,
              employeeId,
            },
          },
          create: { notificationId, employeeId },
          update: { readAt: new Date() },
        });
        await this.updateMetaReadStatus(tx, notificationId);
      }
    });

    return notificationIds.length;
  }

  async markAllCustomerRead(customerId: string) {
    const notificationIds = await this.findNotificationIdsForCustomer(customerId);

    if (!notificationIds.length) {
      return 0;
    }

    const metas = await this.loadMetas(notificationIds);
    let updated = 0;

    await this.prisma.$transaction(async (tx) => {
      for (const notificationId of notificationIds) {
        const meta = metas.get(notificationId);
        if (!meta || meta.recipientCustomerId !== customerId || meta.readAt) {
          continue;
        }

        await this.updateMetaReadStatus(tx, notificationId, true);
        updated += 1;
      }
    });

    return updated;
  }

  private async updateMetaReadStatus(
    tx: Prisma.TransactionClient,
    notificationId: string,
    forceCustomer = false,
  ) {
    const setting = await tx.systemSetting.findUnique({
      where: { settingKey: buildMetaSettingKey(notificationId) },
      select: { settingValue: true },
    });

    if (!setting) {
      return;
    }

    const meta = parseNotificationMeta(setting.settingValue);
    if (!meta) {
      return;
    }

    meta.status = NOTIFICATION_STATUSES.READ;
    meta.readAt = new Date().toISOString();

    if (forceCustomer || meta.recipientType === 'CUSTOMER') {
      meta.readAt = new Date().toISOString();
    }

    await tx.systemSetting.update({
      where: { settingKey: buildMetaSettingKey(notificationId) },
      data: { settingValue: encodeNotificationMeta(meta) },
    });
  }

  async softDelete(notificationId: string) {
    return this.prisma.$transaction(async (tx) => {
      const notification = await tx.notification.update({
        where: { id: notificationId },
        data: { deletedAt: new Date() },
        select: { id: true },
      });

      const setting = await tx.systemSetting.findUnique({
        where: { settingKey: buildMetaSettingKey(notificationId) },
        select: { settingValue: true },
      });

      if (setting) {
        const meta = parseNotificationMeta(setting.settingValue);
        if (meta) {
          meta.deletedAt = new Date().toISOString();
          await tx.systemSetting.update({
            where: { settingKey: buildMetaSettingKey(notificationId) },
            data: { settingValue: encodeNotificationMeta(meta) },
          });
        }
      }

      return notification;
    });
  }

  async countUnreadForEmployee(employeeId: string): Promise<number> {
    const notificationIds = await this.findNotificationIdsForEmployee(employeeId);

    if (!notificationIds.length) {
      return 0;
    }

    const readCount = await this.prisma.notificationRead.count({
      where: {
        employeeId,
        notificationId: { in: notificationIds },
      },
    });

    return notificationIds.length - readCount;
  }

  async countUnreadForCustomer(customerId: string): Promise<number> {
    const notificationIds = await this.findNotificationIdsForCustomer(customerId);

    if (!notificationIds.length) {
      return 0;
    }

    const metas = await this.loadMetas(notificationIds);
    let unread = 0;

    for (const id of notificationIds) {
      const meta = metas.get(id);
      if (!meta?.readAt) {
        unread += 1;
      }
    }

    return unread;
  }

  async getDashboard(scope: { employeeId?: string; canViewAll: boolean }) {
    const startOfDay = new Date();
    startOfDay.setHours(0, 0, 0, 0);

    let notificationIds: string[] | undefined;

    if (!scope.canViewAll && scope.employeeId) {
      notificationIds = await this.findNotificationIdsForEmployee(scope.employeeId);
    }

    const baseWhere: Prisma.NotificationWhereInput = {
      deletedAt: null,
      ...(notificationIds ? { id: { in: notificationIds } } : {}),
    };

    const [todayCount, sentTodayCount] = await this.prisma.$transaction([
      this.prisma.notification.count({
        where: {
          ...baseWhere,
          createdAt: { gte: startOfDay },
        },
      }),
      this.prisma.notification.count({
        where: {
          ...baseWhere,
          createdAt: { gte: startOfDay },
        },
      }),
    ]);

    const todayRecords = await this.prisma.notification.findMany({
      where: {
        ...baseWhere,
        createdAt: { gte: startOfDay },
      },
      select: notificationListSelect,
    });

    const metas = await this.loadMetas(todayRecords.map((record) => record.id));

    let failedNotifications = 0;
    let pendingQueue = 0;
    let readToday = 0;

    for (const record of todayRecords) {
      const meta = metas.get(record.id);
      if (meta?.status === NOTIFICATION_STATUSES.FAILED) {
        failedNotifications += 1;
      }
      if (
        meta?.status === NOTIFICATION_STATUSES.PENDING ||
        meta?.status === NOTIFICATION_STATUSES.QUEUED
      ) {
        pendingQueue += 1;
      }
      if (meta?.readAt && new Date(meta.readAt) >= startOfDay) {
        readToday += 1;
      } else if (
        scope.employeeId &&
        record.reads.some(
          (read) =>
            read.employeeId === scope.employeeId &&
            read.readAt >= startOfDay,
        )
      ) {
        readToday += 1;
      }
    }

    const unreadCount = scope.employeeId
      ? await this.countUnreadForEmployee(scope.employeeId)
      : await this.prisma.notification.count({
          where: {
            ...baseWhere,
            reads: { none: {} },
          },
        });

    return {
      unreadCount,
      todayNotifications: todayCount,
      failedNotifications,
      pendingQueue,
      sentToday: sentTodayCount,
      readToday,
    };
  }

  async findEmployeesByRoles(roleCodes: string[]) {
    return this.prisma.employee.findMany({
      where: {
        deletedAt: null,
        status: 'active',
        employeeRoles: {
          some: {
            deletedAt: null,
            role: {
              code: { in: roleCodes as never[] },
              deletedAt: null,
            },
          },
        },
      },
      select: {
        id: true,
        fullName: true,
        phone: true,
        email: true,
      },
    });
  }

  async findEmployeeById(employeeId: string) {
    return this.prisma.employee.findFirst({
      where: { id: employeeId, deletedAt: null },
      select: {
        id: true,
        fullName: true,
        phone: true,
        email: true,
      },
    });
  }

  async findCustomerById(customerId: string) {
    return this.prisma.customer.findFirst({
      where: { id: customerId, deletedAt: null },
      select: {
        id: true,
        fullName: true,
        phone: true,
        email: true,
      },
    });
  }
}
