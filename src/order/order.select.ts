import { Prisma } from '@prisma/client';

const customerSummarySelect = {
  id: true,
  customerCode: true,
  fullName: true,
  phone: true,
  isActive: true,
} satisfies Prisma.CustomerSelect;

const employeeSummarySelect = {
  id: true,
  fullName: true,
  employeeCode: true,
} satisfies Prisma.EmployeeSelect;

const addressSummarySelect = {
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

const orderItemSelect = {
  id: true,
  serviceId: true,
  servicePriceId: true,
  quantity: true,
  weight: true,
  unitPrice: true,
  subtotal: true,
  notes: true,
  service: {
    select: {
      id: true,
      serviceCode: true,
      serviceName: true,
      unitType: true,
      category: {
        select: {
          id: true,
          code: true,
          name: true,
        },
      },
    },
  },
} satisfies Prisma.OrderItemSelect;

export const orderListSelect = {
  id: true,
  queueNumber: true,
  invoiceNumber: true,
  customerId: true,
  orderDate: true,
  estimatedFinishDate: true,
  completedDate: true,
  pickupRequired: true,
  deliveryRequired: true,
  paymentStatus: true,
  orderStatus: true,
  paymentMethod: true,
  notes: true,
  createdAt: true,
  updatedAt: true,
  customer: { select: customerSummarySelect },
  createdByEmployee: { select: employeeSummarySelect },
  updatedByEmployee: { select: employeeSummarySelect },
  pickupJob: {
    select: {
      status: true,
      driver: { select: employeeSummarySelect },
    },
  },
  deliveryJob: {
    select: {
      status: true,
      driver: { select: employeeSummarySelect },
    },
  },
  items: {
    where: { deletedAt: null },
    select: {
      id: true,
      quantity: true,
      weight: true,
      subtotal: true,
      service: {
        select: {
          id: true,
          serviceCode: true,
          serviceName: true,
          category: { select: { code: true, name: true } },
        },
      },
    },
  },
} satisfies Prisma.OrderSelect;

export const orderDetailSelect = {
  id: true,
  queueNumber: true,
  invoiceNumber: true,
  customerId: true,
  orderDate: true,
  receivedDate: true,
  estimatedFinishDate: true,
  completedDate: true,
  pickupRequired: true,
  deliveryRequired: true,
  pickupAddressId: true,
  deliveryAddressId: true,
  paymentStatus: true,
  orderStatus: true,
  paymentMethod: true,
  notes: true,
  storageBoxId: true,
  lastStorageBoxId: true,
  storageAssignedAt: true,
  storageAssignedByEmployeeId: true,
  createdByEmployeeId: true,
  updatedByEmployeeId: true,
  createdAt: true,
  updatedAt: true,
  customer: { select: customerSummarySelect },
  createdByEmployee: { select: employeeSummarySelect },
  updatedByEmployee: { select: employeeSummarySelect },
  pickupAddress: { select: addressSummarySelect },
  deliveryAddress: { select: addressSummarySelect },
  items: {
    where: { deletedAt: null },
    select: orderItemSelect,
  },
  statusHistories: {
    orderBy: { createdAt: 'asc' as const },
    select: {
      id: true,
      previousStatus: true,
      currentStatus: true,
      notes: true,
      createdAt: true,
      changedByEmployee: { select: employeeSummarySelect },
    },
  },
  timelines: {
    orderBy: { createdAt: 'asc' as const },
    select: {
      id: true,
      timelineType: true,
      title: true,
      description: true,
      createdAt: true,
      employee: { select: employeeSummarySelect },
    },
  },
  payments: {
    where: { deletedAt: null },
    select: {
      id: true,
      amount: true,
      paymentStatus: true,
      paidAt: true,
      referenceNumber: true,
      paymentMethod: { select: { code: true, name: true } },
    },
  },
  pickupJob: {
    select: {
      id: true,
      status: true,
      scheduledPickupAt: true,
      completedAt: true,
      driver: { select: employeeSummarySelect },
    },
  },
  deliveryJob: {
    select: {
      id: true,
      status: true,
      scheduledDeliveryAt: true,
      completedAt: true,
      driver: { select: employeeSummarySelect },
    },
  },
  storageBox: {
    select: {
      id: true,
      code: true,
      boxNumber: true,
      locker: { select: { code: true, name: true } },
    },
  },
  lastStorageBox: {
    select: {
      id: true,
      code: true,
      boxNumber: true,
      locker: { select: { code: true, name: true } },
    },
  },
  storageAssignedBy: { select: employeeSummarySelect },
} satisfies Prisma.OrderSelect;

export type OrderListRecord = Prisma.OrderGetPayload<{
  select: typeof orderListSelect;
}>;

export type OrderDetailRecord = Prisma.OrderGetPayload<{
  select: typeof orderDetailSelect;
}>;
