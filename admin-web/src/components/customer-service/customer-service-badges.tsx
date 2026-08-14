import { Badge } from "@/components/ui/badge";
import type {
  CustomerServiceCategory,
  CustomerServiceStatus,
} from "@/types/customer-service";

const STATUS_STYLES: Record<CustomerServiceStatus, string> = {
  OPEN: "bg-blue-100 text-blue-700 dark:bg-blue-950 dark:text-blue-300",
  IN_PROGRESS:
    "bg-amber-100 text-amber-700 dark:bg-amber-950 dark:text-amber-300",
  WAITING_CUSTOMER:
    "bg-violet-100 text-violet-700 dark:bg-violet-950 dark:text-violet-300",
  RESOLVED:
    "bg-emerald-100 text-emerald-700 dark:bg-emerald-950 dark:text-emerald-300",
  CLOSED: "bg-slate-100 text-slate-700 dark:bg-slate-800 dark:text-slate-300",
};

const CATEGORY_STYLES: Record<CustomerServiceCategory, string> = {
  ORDER_BARU: "bg-sky-100 text-sky-700 dark:bg-sky-950 dark:text-sky-300",
  KOMPLAIN: "bg-red-100 text-red-700 dark:bg-red-950 dark:text-red-300",
  PERTANYAAN:
    "bg-yellow-100 text-yellow-700 dark:bg-yellow-950 dark:text-yellow-300",
  PROMO: "bg-purple-100 text-purple-700 dark:bg-purple-950 dark:text-purple-300",
  TRACKING_ORDER:
    "bg-emerald-100 text-emerald-700 dark:bg-emerald-950 dark:text-emerald-300",
  LAINNYA: "bg-slate-100 text-slate-700 dark:bg-slate-800 dark:text-slate-300",
};

export function CustomerServiceStatusBadge({ status }: { status: string }) {
  const normalized = status.toUpperCase() as CustomerServiceStatus;
  const style =
    STATUS_STYLES[normalized] ??
    "bg-slate-100 text-slate-700 dark:bg-slate-800 dark:text-slate-300";

  return <Badge className={style}>{normalized.replaceAll("_", " ")}</Badge>;
}

export function CustomerServiceCategoryBadge({
  category,
}: {
  category: string;
}) {
  const normalized = category.toUpperCase() as CustomerServiceCategory;
  const style =
    CATEGORY_STYLES[normalized] ??
    "bg-slate-100 text-slate-700 dark:bg-slate-800 dark:text-slate-300";

  return <Badge className={style}>{normalized.replaceAll("_", " ")}</Badge>;
}

export function CustomerServiceUnreadBadge({ isUnread }: { isUnread: boolean }) {
  if (!isUnread) {
    return <span className="text-slate-400">Read</span>;
  }

  return (
    <Badge className="bg-blue-100 text-blue-700 dark:bg-blue-950 dark:text-blue-300">
      Unread
    </Badge>
  );
}
