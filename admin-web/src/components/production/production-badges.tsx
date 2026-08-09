import { Badge } from "@/components/ui/badge";
import { cn } from "@/lib/utils";
import { STAGE_LABELS } from "@/lib/production-stages";
import type { ProductionPriority, ProductionStatus } from "@/types/production";

export function PriorityBadge({ priority }: { priority: ProductionPriority }) {
  const styles: Record<ProductionPriority, string> = {
    NORMAL: "bg-slate-100 text-slate-700 dark:bg-slate-800 dark:text-slate-200",
    EXPRESS: "bg-amber-100 text-amber-800 dark:bg-amber-950 dark:text-amber-200",
    VIP: "bg-violet-100 text-violet-800 dark:bg-violet-950 dark:text-violet-200",
  };

  return (
    <Badge className={cn("border-0", styles[priority])}>{priority}</Badge>
  );
}

export function StageBadge({ stage }: { stage: ProductionStatus }) {
  return (
    <Badge className="border border-slate-200 bg-transparent dark:border-slate-700">
      {STAGE_LABELS[stage]}
    </Badge>
  );
}

export function DelayBadge({
  isDelayed,
  remainingMinutes,
}: {
  isDelayed: boolean;
  remainingMinutes: number | null;
}) {
  if (!isDelayed && remainingMinutes === null) return null;

  if (isDelayed) {
    return (
      <Badge className="border-0 bg-red-100 text-red-700 dark:bg-red-950 dark:text-red-200">
        Delayed
      </Badge>
    );
  }

  if (remainingMinutes !== null && remainingMinutes <= 120) {
    return (
      <Badge className="border-0 bg-orange-100 text-orange-700 dark:bg-orange-950 dark:text-orange-200">
        Due Soon
      </Badge>
    );
  }

  return null;
}
