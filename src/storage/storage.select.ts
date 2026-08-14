import { Prisma } from '@prisma/client';

const storageOrderSelect = {
  id: true,
  queueNumber: true,
  invoiceNumber: true,
  orderStatus: true,
  storageAssignedAt: true,
  customer: {
    select: {
      id: true,
      fullName: true,
      phone: true,
    },
  },
  storageAssignedBy: {
    select: {
      id: true,
      fullName: true,
      employeeCode: true,
    },
  },
} satisfies Prisma.OrderSelect;

export const storageBoxWithOrdersSelect = {
  id: true,
  code: true,
  boxNumber: true,
  isActive: true,
  locker: {
    select: {
      id: true,
      code: true,
      name: true,
    },
  },
  currentOrders: {
    where: { deletedAt: null },
    select: storageOrderSelect,
    orderBy: { storageAssignedAt: 'asc' as const },
  },
} satisfies Prisma.StorageBoxSelect;

export type StorageBoxWithOrders = Prisma.StorageBoxGetPayload<{
  select: typeof storageBoxWithOrdersSelect;
}>;

export const storageLockerWithBoxesSelect = {
  id: true,
  code: true,
  name: true,
  isActive: true,
  boxes: {
    select: storageBoxWithOrdersSelect,
    orderBy: { boxNumber: 'asc' as const },
  },
} satisfies Prisma.StorageLockerSelect;

export type StorageLockerWithBoxes = Prisma.StorageLockerGetPayload<{
  select: typeof storageLockerWithBoxesSelect;
}>;

/** @deprecated Use StorageBoxWithOrders */
export type StorageBoxWithOrder = StorageBoxWithOrders;

/** @deprecated Use storageBoxWithOrdersSelect */
export const storageBoxWithOrderSelect = storageBoxWithOrdersSelect;
