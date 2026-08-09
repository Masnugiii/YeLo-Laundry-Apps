import { Prisma } from '@prisma/client';

const employeeSummarySelect = {
  id: true,
  fullName: true,
  employeeCode: true,
  phone: true,
} satisfies Prisma.EmployeeSelect;

const customerSummarySelect = {
  id: true,
  customerCode: true,
  fullName: true,
  phone: true,
} satisfies Prisma.CustomerSelect;

const addressSelect = {
  id: true,
  recipientName: true,
  phone: true,
  province: true,
  city: true,
  district: true,
  postalCode: true,
  addressDetail: true,
  isDefault: true,
} satisfies Prisma.CustomerAddressSelect;

const orderSummarySelect = {
  id: true,
  invoiceNumber: true,
  queueNumber: true,
  orderStatus: true,
  paymentStatus: true,
  pickupRequired: true,
  deliveryRequired: true,
  receivedDate: true,
  estimatedFinishDate: true,
  orderDate: true,
  customer: { select: customerSummarySelect },
} satisfies Prisma.OrderSelect;

export const pickupJobListSelect = {
  id: true,
  orderId: true,
  driverId: true,
  pickupAddressId: true,
  scheduledPickupAt: true,
  assignedAt: true,
  acceptedAt: true,
  arrivedAt: true,
  completedAt: true,
  status: true,
  notes: true,
  createdAt: true,
  updatedAt: true,
  driver: { select: employeeSummarySelect },
  pickupAddress: { select: addressSelect },
  order: { select: orderSummarySelect },
} satisfies Prisma.PickupJobSelect;

export const deliveryJobListSelect = {
  id: true,
  orderId: true,
  driverId: true,
  deliveryAddressId: true,
  scheduledDeliveryAt: true,
  assignedAt: true,
  acceptedAt: true,
  departedAt: true,
  completedAt: true,
  status: true,
  proofPhotoUrl: true,
  customerSignatureUrl: true,
  notes: true,
  createdAt: true,
  updatedAt: true,
  driver: { select: employeeSummarySelect },
  deliveryAddress: { select: addressSelect },
  order: { select: orderSummarySelect },
} satisfies Prisma.DeliveryJobSelect;

export type PickupJobRecord = Prisma.PickupJobGetPayload<{
  select: typeof pickupJobListSelect;
}>;

export type DeliveryJobRecord = Prisma.DeliveryJobGetPayload<{
  select: typeof deliveryJobListSelect;
}>;

export const driverActivitySelect = {
  id: true,
  driverId: true,
  orderId: true,
  activityType: true,
  latitude: true,
  longitude: true,
  description: true,
  createdAt: true,
} satisfies Prisma.DriverActivitySelect;
