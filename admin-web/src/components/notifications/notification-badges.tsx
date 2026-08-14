import { Badge } from "@/components/ui/badge";

const TYPE_STYLES: Record<string, string> = {
  ORDER: "bg-blue-100 text-blue-700 dark:bg-blue-950 dark:text-blue-300",
  PAYMENT:
    "bg-emerald-100 text-emerald-700 dark:bg-emerald-950 dark:text-emerald-300",
  SYSTEM: "bg-slate-100 text-slate-700 dark:bg-slate-800 dark:text-slate-300",
  CUSTOMER:
    "bg-violet-100 text-violet-700 dark:bg-violet-950 dark:text-violet-300",
  ATTENDANCE:
    "bg-amber-100 text-amber-700 dark:bg-amber-950 dark:text-amber-300",
};

const PRIORITY_STYLES: Record<string, string> = {
  LOW: "bg-slate-100 text-slate-700 dark:bg-slate-800 dark:text-slate-300",
  NORMAL: "bg-blue-100 text-blue-700 dark:bg-blue-950 dark:text-blue-300",
  HIGH: "bg-red-100 text-red-700 dark:bg-red-950 dark:text-red-300",
};

export function NotificationTypeBadge({ type }: { type: string }) {
  const normalized = type.toUpperCase();
  const style =
    TYPE_STYLES[normalized] ??
    "bg-slate-100 text-slate-700 dark:bg-slate-800 dark:text-slate-300";

  return <Badge className={style}>{normalized}</Badge>;
}

export function NotificationPriorityBadge({ priority }: { priority: string }) {
  const normalized = priority.toUpperCase();
  const style =
    PRIORITY_STYLES[normalized] ??
    "bg-slate-100 text-slate-700 dark:bg-slate-800 dark:text-slate-300";

  return <Badge className={style}>{normalized}</Badge>;
}

export function NotificationReadBadge({ isRead }: { isRead: boolean }) {
  return (
    <Badge
      className={
        isRead
          ? "bg-slate-100 text-slate-700 dark:bg-slate-800 dark:text-slate-300"
          : "bg-blue-100 text-blue-700 dark:bg-blue-950 dark:text-blue-300"
      }
    >
      {isRead ? "Read" : "Unread"}
    </Badge>
  );
}
