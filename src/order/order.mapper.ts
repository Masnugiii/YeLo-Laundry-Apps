import { Decimal } from '@prisma/client/runtime/library';
import { OrderFinancialMeta, decodeOrderNotes } from './utils/order-meta.util';
import { OrderDetailRecord, OrderListRecord } from './order.select';

export interface OrderItemResponse {
  id: string;
  serviceId: string;
  serviceCode: string;
  serviceName: string;
  serviceCategoryCode: string | null;
  serviceCategoryName: string | null;
  quantity: number;
  weight: number | null;
  unitPrice: number;
  subtotal: number;
  notes: string | null;
}

export interface OrderTimelineItem {
  id: string;
  type: string;
  title: string;
  description: string | null;
  employee: {
    id: string;
    fullName: string;
    employeeCode: string;
  } | null;
  createdAt: Date;
}

export interface OrderStatusHistoryItem {
  id: string;
  fromStatus: string | null;
  toStatus: string;
  notes: string | null;
  changedBy: {
    id: string;
    fullName: string;
    employeeCode: string;
  } | null;
  changedAt: Date;
}

export interface OrderListItem {
  id: string;
  orderNumber: string;
  invoiceNumber: string;
  queueNumber: string;
  customerId: string;
  customerName: string;
  customerPhone: string;
  orderStatus: string;
  paymentStatus: string;
  serviceSummary: string;
  totalWeight: number;
  itemCount: number;
  subtotal: number;
  discount: number;
  tax: number;
  serviceFee: number;
  grandTotal: number;
  pickupRequired: boolean;
  deliveryRequired: boolean;
  pickupStatus: string | null;
  deliveryStatus: string | null;
  assignedEmployee: {
    id: string;
    fullName: string;
    employeeCode: string;
  } | null;
  estimatedFinishDate: Date | null;
  completedDate: Date | null;
  orderDate: Date;
  createdBy: {
    id: string;
    fullName: string;
    employeeCode: string;
  };
  createdAt: Date;
}

export interface OrderDetail extends OrderListItem {
  receivedDate: Date | null;
  actualFinishDate: Date | null;
  paymentMethod: string | null;
  notes: string | null;
  items: OrderItemResponse[];
  timeline: OrderTimelineItem[];
  statusHistory: OrderStatusHistoryItem[];
  pickupAddress: Record<string, unknown> | null;
  deliveryAddress: Record<string, unknown> | null;
  pickup: Record<string, unknown> | null;
  delivery: Record<string, unknown> | null;
  paymentsSummary: {
    totalPaid: number;
    remaining: number;
  };
  updatedAt: Date;
}

export interface PaginatedOrders {
  items: OrderListItem[];
  meta: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}

export interface OrderStatistics {
  totalOrders: number;
  todayOrders: number;
  completedOrders: number;
  cancelledOrders: number;
  revenueToday: number;
  revenueThisMonth: number;
  averageTicket: number;
}

function decimalToNumber(value: Decimal | number | null | undefined): number {
  if (value === null || value === undefined) {
    return 0;
  }

  return Number(value);
}

export function calculateItemSubtotal(
  unitPrice: number,
  quantity: number,
): number {
  return Number((unitPrice * quantity).toFixed(2));
}

export function calculateOrderTotals(
  itemsSubtotal: number,
  meta: OrderFinancialMeta,
): {
  subtotal: number;
  discount: number;
  tax: number;
  serviceFee: number;
  grandTotal: number;
} {
  const subtotal = itemsSubtotal;
  const discount = meta.discount;
  const tax = meta.tax;
  const serviceFee = meta.serviceFee;
  const grandTotal = Number(
    (subtotal - discount + tax + serviceFee).toFixed(2),
  );

  return { subtotal, discount, tax, serviceFee, grandTotal };
}

function sumItemsSubtotal(
  items: Array<{ subtotal: Decimal | number }>,
): number {
  return items.reduce(
    (total, item) => total + decimalToNumber(item.subtotal),
    0,
  );
}

function mapAddress(
  address: OrderDetailRecord['pickupAddress'],
): Record<string, unknown> | null {
  if (!address) {
    return null;
  }

  return {
    id: address.id,
    recipientName: address.recipientName,
    phone: address.phone,
    province: address.province,
    city: address.city,
    district: address.district,
    postalCode: address.postalCode,
    addressDetail: address.addressDetail,
    isDefault: address.isDefault,
  };
}

export function toOrderListItem(order: OrderListRecord): OrderListItem {
  const { meta, notes: _notes } = decodeOrderNotes(order.notes);
  const itemsSubtotal = sumItemsSubtotal(order.items);
  const totals = calculateOrderTotals(itemsSubtotal, meta);
  const serviceNames = [
    ...new Set(order.items.map((item) => item.service.serviceName)),
  ];
  const totalWeight = order.items.reduce(
    (sum, item) => sum + (item.weight ? decimalToNumber(item.weight) : 0),
    0,
  );
  const assignedEmployee =
    order.pickupJob?.driver ??
    order.deliveryJob?.driver ??
    order.updatedByEmployee ??
    null;

  return {
    id: order.id,
    orderNumber: order.invoiceNumber,
    invoiceNumber: order.invoiceNumber,
    queueNumber: order.queueNumber,
    customerId: order.customerId,
    customerName: order.customer.fullName,
    customerPhone: order.customer.phone,
    orderStatus: order.orderStatus,
    paymentStatus: order.paymentStatus,
    serviceSummary: serviceNames.join(', ') || '-',
    totalWeight,
    itemCount: order.items.length,
    ...totals,
    pickupRequired: order.pickupRequired,
    deliveryRequired: order.deliveryRequired,
    pickupStatus: order.pickupJob?.status ?? null,
    deliveryStatus: order.deliveryJob?.status ?? null,
    assignedEmployee,
    estimatedFinishDate: order.estimatedFinishDate,
    completedDate: order.completedDate,
    orderDate: order.orderDate,
    createdBy: order.createdByEmployee,
    createdAt: order.createdAt,
  };
}

export function toOrderDetail(order: OrderDetailRecord): OrderDetail {
  const listItem = toOrderListItem(order as unknown as OrderListRecord);
  const { notes } = decodeOrderNotes(order.notes);

  const totalPaid = order.payments
    .filter((payment) => payment.paymentStatus === 'PAID')
    .reduce((sum, payment) => sum + decimalToNumber(payment.amount), 0);

  return {
    ...listItem,
    receivedDate: order.receivedDate,
    actualFinishDate: order.completedDate,
    paymentMethod: order.paymentMethod,
    notes,
    items: order.items.map((item) => ({
      id: item.id,
      serviceId: item.serviceId,
      serviceCode: item.service.serviceCode,
      serviceName: item.service.serviceName,
      serviceCategoryCode: item.service.category?.code ?? null,
      serviceCategoryName: item.service.category?.name ?? null,
      quantity: decimalToNumber(item.quantity),
      weight: item.weight ? decimalToNumber(item.weight) : null,
      unitPrice: decimalToNumber(item.unitPrice),
      subtotal: decimalToNumber(item.subtotal),
      notes: item.notes,
    })),
    timeline: order.timelines.map((entry) => ({
      id: entry.id,
      type: entry.timelineType,
      title: entry.title,
      description: entry.description,
      employee: entry.employee,
      createdAt: entry.createdAt,
    })),
    statusHistory: order.statusHistories.map((entry) => ({
      id: entry.id,
      fromStatus: entry.previousStatus,
      toStatus: entry.currentStatus,
      notes: entry.notes,
      changedBy: entry.changedByEmployee,
      changedAt: entry.createdAt,
    })),
    pickupAddress: mapAddress(order.pickupAddress),
    deliveryAddress: mapAddress(order.deliveryAddress),
    pickup: order.pickupJob
      ? {
          id: order.pickupJob.id,
          status: order.pickupJob.status,
          scheduledPickupAt: order.pickupJob.scheduledPickupAt,
          completedAt: order.pickupJob.completedAt,
          driver: order.pickupJob.driver,
        }
      : null,
    delivery: order.deliveryJob
      ? {
          id: order.deliveryJob.id,
          status: order.deliveryJob.status,
          scheduledDeliveryAt: order.deliveryJob.scheduledDeliveryAt,
          completedAt: order.deliveryJob.completedAt,
          driver: order.deliveryJob.driver,
        }
      : null,
    paymentsSummary: {
      totalPaid,
      remaining: Math.max(listItem.grandTotal - totalPaid, 0),
    },
    updatedAt: order.updatedAt,
  };
}
