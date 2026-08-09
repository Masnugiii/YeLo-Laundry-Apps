import { Prisma } from '@prisma/client';

export const customerDeviceSelect = {
  id: true,
  customerId: true,
  deviceToken: true,
  platform: true,
  lastLoginAt: true,
  createdAt: true,
  updatedAt: true,
  deletedAt: true,
} satisfies Prisma.CustomerDeviceSelect;

export type CustomerDeviceRecord = Prisma.CustomerDeviceGetPayload<{
  select: typeof customerDeviceSelect;
}>;
