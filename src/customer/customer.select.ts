import { Prisma } from '@prisma/client';

export const customerListSelect = {
  id: true,
  customerCode: true,
  fullName: true,
  phone: true,
  email: true,
  gender: true,
  birthDate: true,
  occupation: true,
  photoUrl: true,
  isActive: true,
  createdAt: true,
  updatedAt: true,
  deletedAt: true,
  wallet: {
    select: {
      currentBalance: true,
      currency: true,
      isActive: true,
    },
  },
  rewardPoints: {
    where: { deletedAt: null },
    select: { point: true },
  },
} satisfies Prisma.CustomerSelect;

export const customerDetailSelect = {
  ...customerListSelect,
  defaultAddress: {
    select: {
      id: true,
      recipientName: true,
      phone: true,
      province: true,
      city: true,
      district: true,
      postalCode: true,
      addressDetail: true,
      isDefault: true,
    },
  },
  addresses: {
    where: { deletedAt: null },
    select: {
      id: true,
      recipientName: true,
      phone: true,
      province: true,
      city: true,
      district: true,
      postalCode: true,
      addressDetail: true,
      isDefault: true,
    },
    orderBy: { isDefault: 'desc' as const },
  },
} satisfies Prisma.CustomerSelect;

export const customerSearchSelect = {
  id: true,
  customerCode: true,
  fullName: true,
  phone: true,
  isActive: true,
  wallet: {
    select: {
      currentBalance: true,
    },
  },
} satisfies Prisma.CustomerSelect;

export type CustomerListRecord = Prisma.CustomerGetPayload<{
  select: typeof customerListSelect;
}>;

export type CustomerDetailRecord = Prisma.CustomerGetPayload<{
  select: typeof customerDetailSelect;
}>;

export type CustomerSearchRecord = Prisma.CustomerGetPayload<{
  select: typeof customerSearchSelect;
}>;
