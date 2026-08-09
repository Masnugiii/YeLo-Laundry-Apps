import { Prisma } from '@prisma/client';

export const customerAddressSelect = {
  id: true,
  customerId: true,
  recipientName: true,
  phone: true,
  province: true,
  city: true,
  district: true,
  postalCode: true,
  addressDetail: true,
  latitude: true,
  longitude: true,
  isDefault: true,
  createdAt: true,
  updatedAt: true,
  deletedAt: true,
} satisfies Prisma.CustomerAddressSelect;

export type CustomerAddressRecord = Prisma.CustomerAddressGetPayload<{
  select: typeof customerAddressSelect;
}>;
