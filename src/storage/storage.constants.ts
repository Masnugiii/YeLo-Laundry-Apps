export const LOCKER_BOX_COUNTS = {
  A: 9,
  B: 15,
  C: 15,
} as const;

export const LOCKER_CODES = ['A', 'B', 'C'] as const;

export type LockerCode = (typeof LOCKER_CODES)[number];

export const TOTAL_STORAGE_BOXES = 39;

export const ACTIVE_STORAGE_ORDER_STATUSES = [
  'CREATED',
  'WAITING_PAYMENT',
  'PAYMENT_CONFIRMED',
  'WAITING_BINATU',
  'IRONING_ACCEPTED',
  'CURRENTLY_IRONING',
  'FINISHED_IRONING',
  'READY_FOR_PICKUP',
  'WAITING_PICKUP_DRIVER',
  'PICKUP_COMPLETED',
  'WAITING_DELIVERY',
  'OUT_FOR_DELIVERY',
  'DELIVERED',
] as const;
