import { Prisma } from '@prisma/client';

export const notificationListSelect = {
  id: true,
  title: true,
  body: true,
  type: true,
  priority: true,
  senderEmployeeId: true,
  createdAt: true,
  deletedAt: true,
  senderEmployee: {
    select: {
      id: true,
      fullName: true,
      employeeCode: true,
    },
  },
  reads: {
    select: {
      employeeId: true,
      readAt: true,
    },
  },
} satisfies Prisma.NotificationSelect;

export type NotificationListRecord = Prisma.NotificationGetPayload<{
  select: typeof notificationListSelect;
}>;

export const notificationDetailSelect = {
  ...notificationListSelect,
} satisfies Prisma.NotificationSelect;

export type NotificationDetailRecord = Prisma.NotificationGetPayload<{
  select: typeof notificationDetailSelect;
}>;
