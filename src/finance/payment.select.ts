import { Prisma } from '@prisma/client';

const employeeSummarySelect = {
  id: true,
  fullName: true,
  employeeCode: true,
} satisfies Prisma.EmployeeSelect;

const customerSummarySelect = {
  id: true,
  customerCode: true,
  fullName: true,
  phone: true,
} satisfies Prisma.CustomerSelect;

const orderSummarySelect = {
  id: true,
  invoiceNumber: true,
  queueNumber: true,
  paymentStatus: true,
  orderStatus: true,
  notes: true,
  customerId: true,
  customer: { select: customerSummarySelect },
  items: {
    where: { deletedAt: null },
    select: {
      subtotal: true,
    },
  },
} satisfies Prisma.OrderSelect;

export const paymentListSelect = {
  id: true,
  orderId: true,
  paymentMethodId: true,
  amount: true,
  paidAt: true,
  referenceNumber: true,
  paymentStatus: true,
  notes: true,
  createdAt: true,
  updatedAt: true,
  paymentMethod: {
    select: {
      id: true,
      code: true,
      name: true,
    },
  },
  receivedByEmployee: { select: employeeSummarySelect },
  order: { select: orderSummarySelect },
} satisfies Prisma.PaymentSelect;

export const paymentDetailSelect = paymentListSelect;

export type PaymentListRecord = Prisma.PaymentGetPayload<{
  select: typeof paymentListSelect;
}>;

export type PaymentDetailRecord = Prisma.PaymentGetPayload<{
  select: typeof paymentDetailSelect;
}>;
