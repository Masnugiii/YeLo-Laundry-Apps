import {
  LaundryOrderDetailRecord,
  LaundryOrderListRecord,
} from './laundry.select';
import {
  ProductionRecord,
  ProductionStageEvent,
  ProductionStatus,
  QualityCheckRecord,
  mapPrismaPriorityToProduction,
} from './utils/production-meta.util';

export interface ProductionStageResponse {
  stage: ProductionStatus;
  employeeId: string;
  startedAt: string;
  finishedAt: string | null;
  durationMinutes: number | null;
  notes: string | null;
}

export interface LaundryOrderListItem {
  orderId: string;
  orderNumber: string;
  queueNumber: string;
  customerName: string;
  customerPhone: string;
  orderStatus: string;
  productionStatus: ProductionStatus;
  priority: string;
  serviceSummary: string;
  totalWeight: number;
  totalPieces: number;
  receivedAt: string;
  updatedAt: string;
  stageStartedAt: string | null;
  estimatedFinishDate: Date | null;
  isDelayed: boolean;
  remainingMinutes: number | null;
  assignedEmployee: {
    id: string;
    fullName: string;
    employeeCode: string;
  } | null;
}

export interface LaundryOrderDetail extends LaundryOrderListItem {
  items: Array<{
    id: string;
    serviceCode: string;
    serviceName: string;
    quantity: number;
    weight: number | null;
    subtotal: number;
  }>;
  productionHistory: ProductionStageResponse[];
  qualityChecks: QualityCheckRecord[];
  orderTimelines: Array<{
    id: string;
    title: string;
    description: string | null;
    employee: {
      id: string;
      fullName: string;
      employeeCode: string;
    } | null;
    createdAt: Date;
  }>;
  statusHistory: Array<{
    id: string;
    previousStatus: string | null;
    currentStatus: string;
    notes: string | null;
    changedBy: {
      id: string;
      fullName: string;
      employeeCode: string;
    } | null;
    changedAt: Date;
  }>;
}

export interface PaginatedLaundryOrders {
  items: LaundryOrderListItem[];
  meta: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}

export interface LaundryDashboard {
  receiving: number;
  sorting: number;
  waitingWashing: number;
  currentlyWashing: number;
  waitingDrying: number;
  currentlyDrying: number;
  waitingIroning: number;
  currentlyIroning: number;
  qualityCheck: number;
  packing: number;
  readyForPickup: number;
  completedToday: number;
  delayed: number;
  averageProductionTimeMinutes: number;
}

function decimalToNumber(value: { toString(): string } | number): number {
  return Number(value);
}

function mapStageEvent(event: ProductionStageEvent): ProductionStageResponse {
  return {
    stage: event.stage,
    employeeId: event.employeeId,
    startedAt: event.startedAt,
    finishedAt: event.finishedAt ?? null,
    durationMinutes: event.durationMinutes ?? null,
    notes: event.notes ?? null,
  };
}

function getAssignedEmployee(
  record: ProductionRecord,
  order: LaundryOrderListRecord,
) {
  const openStage = [...record.history]
    .reverse()
    .find((event) => !event.finishedAt);

  if (openStage) {
    const ironingEmployee = order.ironingJobs[0]?.employee;

    if (ironingEmployee && openStage.stage === 'IRONING') {
      return ironingEmployee;
    }

    return order.createdByEmployee;
  }

  return order.ironingJobs[0]?.employee ?? null;
}

function getOpenStageEvent(record: ProductionRecord) {
  return [...record.history].reverse().find((event) => !event.finishedAt) ?? null;
}

function computeDelay(order: LaundryOrderListRecord) {
  if (!order.estimatedFinishDate) {
    return { isDelayed: false, remainingMinutes: null };
  }

  const remainingMs = order.estimatedFinishDate.getTime() - Date.now();
  return {
    isDelayed: remainingMs < 0,
    remainingMinutes: Math.round(remainingMs / 60000),
  };
}

function summarizeItems(order: LaundryOrderListRecord) {
  const serviceNames = [...new Set(order.items.map((item) => item.service.serviceName))];
  const totalWeight = order.items.reduce(
    (sum, item) => sum + (item.weight ? decimalToNumber(item.weight) : 0),
    0,
  );
  const totalPieces = order.items.reduce(
    (sum, item) => sum + decimalToNumber(item.quantity),
    0,
  );

  return {
    serviceSummary: serviceNames.join(', ') || '-',
    totalWeight,
    totalPieces,
  };
}

export function toLaundryOrderListItem(
  order: LaundryOrderListRecord,
  production: ProductionRecord,
): LaundryOrderListItem {
  const summary = summarizeItems(order);
  const delay = computeDelay(order);
  const openStage = getOpenStageEvent(production);

  return {
    orderId: order.id,
    orderNumber: order.invoiceNumber,
    queueNumber: order.queueNumber,
    customerName: order.customer.fullName,
    customerPhone: order.customer.phone,
    orderStatus: order.orderStatus,
    productionStatus: production.currentStage,
    priority: production.priority,
    serviceSummary: summary.serviceSummary,
    totalWeight: summary.totalWeight,
    totalPieces: summary.totalPieces,
    receivedAt: production.receivedAt,
    updatedAt: production.updatedAt,
    stageStartedAt: openStage?.startedAt ?? null,
    estimatedFinishDate: order.estimatedFinishDate,
    isDelayed: delay.isDelayed,
    remainingMinutes: delay.remainingMinutes,
    assignedEmployee: getAssignedEmployee(production, order),
  };
}

export function toLaundryOrderDetail(
  order: LaundryOrderDetailRecord,
  production: ProductionRecord,
): LaundryOrderDetail {
  const listItem = toLaundryOrderListItem(order, production);

  return {
    ...listItem,
    priority:
      production.priority ??
      (order.ironingJobs[0]
        ? mapPrismaPriorityToProduction(order.ironingJobs[0].priority)
        : 'NORMAL'),
    items: order.items.map((item) => ({
      id: item.id,
      serviceCode: item.service.serviceCode,
      serviceName: item.service.serviceName,
      quantity: decimalToNumber(item.quantity),
      weight: item.weight ? decimalToNumber(item.weight) : null,
      subtotal: decimalToNumber(item.subtotal),
    })),
    productionHistory: production.history.map(mapStageEvent),
    qualityChecks: production.qualityChecks,
    orderTimelines: order.timelines.map((entry) => ({
      id: entry.id,
      title: entry.title,
      description: entry.description,
      employee: entry.employee,
      createdAt: entry.createdAt,
    })),
    statusHistory: order.statusHistories.map((entry) => ({
      id: entry.id,
      previousStatus: entry.previousStatus,
      currentStatus: entry.currentStatus,
      notes: entry.notes,
      changedBy: entry.changedByEmployee,
      changedAt: entry.createdAt,
    })),
  };
}

export function toQueueItem(
  order: LaundryOrderListRecord,
  production: ProductionRecord,
): LaundryOrderListItem {
  return toLaundryOrderListItem(order, production);
}
