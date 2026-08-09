import { Prisma } from '@prisma/client';

const customerSummarySelect = {
  id: true,
  customerCode: true,
  fullName: true,
  phone: true,
} satisfies Prisma.CustomerSelect;

const employeeSummarySelect = {
  id: true,
  fullName: true,
  employeeCode: true,
} satisfies Prisma.EmployeeSelect;

export const laundryOrderListSelect = {
  id: true,
  queueNumber: true,
  invoiceNumber: true,
  orderDate: true,
  receivedDate: true,
  estimatedFinishDate: true,
  orderStatus: true,
  paymentStatus: true,
  notes: true,
  createdAt: true,
  updatedAt: true,
  customer: { select: customerSummarySelect },
  createdByEmployee: { select: employeeSummarySelect },
  ironingJobs: {
    where: { deletedAt: null },
    orderBy: { createdAt: 'desc' as const },
    take: 1,
    select: {
      id: true,
      status: true,
      priority: true,
      employeeId: true,
      startedAt: true,
      finishedAt: true,
      actualMinutes: true,
      employee: { select: employeeSummarySelect },
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
          serviceCode: true,
          serviceName: true,
        },
      },
    },
  },
} satisfies Prisma.OrderSelect;

export const laundryOrderDetailSelect = {
  ...laundryOrderListSelect,
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
    where: { timelineType: 'IRONING' },
    orderBy: { createdAt: 'asc' as const },
    select: {
      id: true,
      title: true,
      description: true,
      createdAt: true,
      employee: { select: employeeSummarySelect },
    },
  },
} satisfies Prisma.OrderSelect;

export type LaundryOrderListRecord = Prisma.OrderGetPayload<{
  select: typeof laundryOrderListSelect;
}>;

export type LaundryOrderDetailRecord = Prisma.OrderGetPayload<{
  select: typeof laundryOrderDetailSelect;
}>;
