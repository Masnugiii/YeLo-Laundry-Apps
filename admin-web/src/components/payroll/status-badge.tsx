import { Badge } from "@/components/ui/badge";
import { cn } from "@/lib/utils";
import type { PayrollRecordStatus } from "@/types/payroll";

const STATUS_STYLES: Record<PayrollRecordStatus, string> = {
  DRAFT: "bg-slate-100 text-slate-700 dark:bg-slate-800 dark:text-slate-200",
  CALCULATED: "bg-blue-100 text-blue-800 dark:bg-blue-950 dark:text-blue-200",
  APPROVED: "bg-amber-100 text-amber-800 dark:bg-amber-950 dark:text-amber-200",
  PAID: "bg-emerald-100 text-emerald-800 dark:bg-emerald-950 dark:text-emerald-200",
};

export function PayrollStatusBadge({ status }: { status: PayrollRecordStatus }) {
  return (
    <Badge className={cn(STATUS_STYLES[status])}>
      {status.charAt(0) + status.slice(1).toLowerCase()}
    </Badge>
  );
}
