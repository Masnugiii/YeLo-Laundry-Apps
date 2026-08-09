export function formatLaundryStatus(status: string) {
  return status.replaceAll("_", " ");
}

export function formatPaymentStatus(status: string) {
  return status.replaceAll("_", " ");
}

export function formatPickupStatus(status: string | null) {
  if (!status) return "N/A";
  return status.replaceAll("_", " ");
}

export function formatDeliveryStatus(status: string | null) {
  if (!status) return "N/A";
  return status.replaceAll("_", " ");
}

export const ORDER_STATUSES = [
  "CREATED",
  "WAITING_PAYMENT",
  "PAYMENT_CONFIRMED",
  "WAITING_BINATU",
  "IRONING_ACCEPTED",
  "CURRENTLY_IRONING",
  "FINISHED_IRONING",
  "READY_FOR_PICKUP",
  "WAITING_PICKUP_DRIVER",
  "PICKUP_COMPLETED",
  "WAITING_DELIVERY",
  "OUT_FOR_DELIVERY",
  "DELIVERED",
  "COMPLETED",
  "CANCELLED",
] as const;

export const PAYMENT_STATUSES = ["UNPAID", "PAID", "CANCELLED", "REFUNDED"] as const;

export const PICKUP_STATUSES = [
  "WAITING_ASSIGNMENT",
  "ASSIGNED",
  "ACCEPTED",
  "ON_THE_WAY",
  "ARRIVED",
  "COMPLETED",
  "CANCELLED",
] as const;

export const DELIVERY_STATUSES = [
  "WAITING_ASSIGNMENT",
  "ASSIGNED",
  "ACCEPTED",
  "OUT_FOR_DELIVERY",
  "ARRIVED",
  "COMPLETED",
  "FAILED",
  "CANCELLED",
] as const;
