import { Card } from "@/components/ui/card";
import { Skeleton } from "@/components/ui/badge";

export {
  EmptyState,
  QueryErrorState,
} from "@/components/employees/list-states";

export function NotificationListSkeleton() {
  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between gap-3">
        <Skeleton className="h-10 w-40" />
        <Skeleton className="h-10 w-32" />
      </div>
      <Skeleton className="h-10 w-48" />
      <div className="overflow-hidden rounded-xl border border-slate-200 bg-white dark:border-slate-800 dark:bg-slate-900">
        {Array.from({ length: 8 }).map((_, index) => (
          <div
            key={index}
            className="flex items-center gap-4 border-t border-slate-100 px-4 py-4 first:border-t-0 dark:border-slate-800"
          >
            <Skeleton className="h-4 w-32" />
            <Skeleton className="hidden h-4 w-48 md:block" />
            <Skeleton className="h-6 w-16" />
            <Skeleton className="ml-auto h-6 w-14" />
          </div>
        ))}
      </div>
    </div>
  );
}
