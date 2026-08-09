import { Badge } from "@/components/ui/badge";
import {
  formatDeliveryStatus,
  formatLaundryStatus,
  formatPaymentStatus,
  formatPickupStatus,
} from "@/lib/order-labels";

export function PaymentStatusBadge({ status }: { status: string }) {
  const normalized = status.toUpperCase();
  const style =
    normalized === "PAID"
      ? "bg-emerald-100 text-emerald-700 dark:bg-emerald-950 dark:text-emerald-300"
      : normalized === "UNPAID"
        ? "bg-amber-100 text-amber-700 dark:bg-amber-950 dark:text-amber-300"
        : normalized === "REFUNDED"
          ? "bg-blue-100 text-blue-700 dark:bg-blue-950 dark:text-blue-300"
          : "bg-slate-100 text-slate-700 dark:bg-slate-800 dark:text-slate-300";

  return <Badge className={style}>{formatPaymentStatus(status)}</Badge>;
}

export function LaundryStatusBadge({ status }: { status: string }) {
  return (
    <Badge className="bg-indigo-100 text-indigo-700 dark:bg-indigo-950 dark:text-indigo-300">
      {formatLaundryStatus(status)}
    </Badge>
  );
}

export function PickupStatusBadge({ status }: { status: string | null }) {
  return (
    <Badge className="bg-cyan-100 text-cyan-700 dark:bg-cyan-950 dark:text-cyan-300">
      {formatPickupStatus(status)}
    </Badge>
  );
}

export function DeliveryStatusBadge({ status }: { status: string | null }) {
  return (
    <Badge className="bg-violet-100 text-violet-700 dark:bg-violet-950 dark:text-violet-300">
      {formatDeliveryStatus(status)}
    </Badge>
  );
}
