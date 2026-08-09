import { Badge } from "@/components/ui/badge";
import type { EmployeeStatus } from "@/types/employee";

const STATUS_STYLES: Record<EmployeeStatus, string> = {
  ACTIVE: "bg-emerald-100 text-emerald-700 dark:bg-emerald-950 dark:text-emerald-300",
  INACTIVE: "bg-slate-100 text-slate-700 dark:bg-slate-800 dark:text-slate-300",
  SUSPENDED: "bg-amber-100 text-amber-700 dark:bg-amber-950 dark:text-amber-300",
  RESIGNED: "bg-red-100 text-red-700 dark:bg-red-950 dark:text-red-300",
};

export function EmployeeStatusBadge({ status }: { status: string }) {
  const normalized = status.toUpperCase() as EmployeeStatus;
  const style =
    STATUS_STYLES[normalized] ??
    "bg-slate-100 text-slate-700 dark:bg-slate-800 dark:text-slate-300";

  return <Badge className={style}>{normalized}</Badge>;
}
