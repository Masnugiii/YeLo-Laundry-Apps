import { OrderStatus } from '@prisma/client';

export interface LaundryTrackingStep {
  key: string;
  label: string;
  status: 'completed' | 'current' | 'pending';
  completedAt: string | null;
}

const LAUNDRY_STEPS: Array<{ key: string; label: string; statuses: OrderStatus[] }> = [
  { key: 'receiving', label: 'Receiving', statuses: [OrderStatus.CREATED, OrderStatus.WAITING_PAYMENT] },
  {
    key: 'washing',
    label: 'Washing',
    statuses: [OrderStatus.PAYMENT_CONFIRMED, OrderStatus.WAITING_BINATU],
  },
  {
    key: 'drying',
    label: 'Drying',
    statuses: [OrderStatus.IRONING_ACCEPTED],
  },
  {
    key: 'ironing',
    label: 'Ironing',
    statuses: [OrderStatus.CURRENTLY_IRONING, OrderStatus.FINISHED_IRONING],
  },
  {
    key: 'quality_check',
    label: 'Quality Check',
    statuses: [OrderStatus.READY_FOR_PICKUP],
  },
  {
    key: 'ready_pickup',
    label: 'Ready Pickup',
    statuses: [
      OrderStatus.WAITING_PICKUP_DRIVER,
      OrderStatus.PICKUP_COMPLETED,
      OrderStatus.WAITING_DELIVERY,
    ],
  },
  {
    key: 'completed',
    label: 'Completed',
    statuses: [OrderStatus.OUT_FOR_DELIVERY, OrderStatus.DELIVERED, OrderStatus.COMPLETED],
  },
];

export function buildLaundryTracking(
  orderStatus: OrderStatus,
  statusHistory: Array<{ toStatus: string; changedAt: Date }>,
): LaundryTrackingStep[] {
  const currentIndex = LAUNDRY_STEPS.findIndex((step) =>
    step.statuses.includes(orderStatus),
  );
  const resolvedIndex = currentIndex === -1 ? 0 : currentIndex;

  return LAUNDRY_STEPS.map((step, index) => {
    const historyEntry = statusHistory.find((entry) =>
      step.statuses.includes(entry.toStatus as OrderStatus),
    );

    let status: LaundryTrackingStep['status'] = 'pending';

    if (index < resolvedIndex) {
      status = 'completed';
    } else if (index === resolvedIndex) {
      status = 'current';
    }

    if (orderStatus === OrderStatus.CANCELLED) {
      status = index <= resolvedIndex ? 'completed' : 'pending';
    }

    return {
      key: step.key,
      label: step.label,
      status,
      completedAt: historyEntry?.changedAt.toISOString() ?? null,
    };
  });
}

export interface CustomerDashboardData {
  greetingName: string;
  activeOrders: number;
  readyPickup: number;
  walletBalance: number;
  rewardPoints: number;
  unreadNotifications: number;
  latestNotifications: Array<{
    id: string;
    title: string;
    message: string;
    createdAt: string;
    isRead: boolean;
  }>;
}

export interface CustomerRewardSummary {
  currentPoints: number;
  expiredPoints: number;
}

export interface PaginatedRewardHistory {
  items: Array<{
    id: string;
    point: number;
    type: string;
    description: string | null;
    expiredAt: string | null;
    createdAt: string;
  }>;
  meta: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}
