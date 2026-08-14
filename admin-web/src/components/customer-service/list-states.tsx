import { Card } from "@/components/ui/card";
import { Skeleton } from "@/components/ui/badge";

export {
  EmptyState,
  QueryErrorState,
} from "@/components/employees/list-states";

export function CustomerServiceListSkeleton() {
  return (
    <div className="space-y-4">
      <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
        {Array.from({ length: 4 }).map((_, index) => (
          <Card key={index} className="h-24 animate-pulse bg-slate-100 dark:bg-slate-900" />
        ))}
      </div>
      <div className="grid gap-3 md:grid-cols-3">
        <Skeleton className="h-10 md:col-span-2" />
        <Skeleton className="h-10" />
      </div>
      <div className="overflow-hidden rounded-xl border border-slate-200 bg-white dark:border-slate-800 dark:bg-slate-900">
        {Array.from({ length: 6 }).map((_, index) => (
          <div
            key={index}
            className="flex items-center gap-4 border-t border-slate-100 px-4 py-4 first:border-t-0 dark:border-slate-800"
          >
            <Skeleton className="h-4 w-28" />
            <Skeleton className="h-4 w-24" />
            <Skeleton className="h-6 w-20" />
            <Skeleton className="hidden h-4 w-40 md:block" />
            <Skeleton className="ml-auto h-6 w-16" />
          </div>
        ))}
      </div>
    </div>
  );
}

export function CustomerServiceDetailSkeleton() {
  return (
    <div className="space-y-6">
      <Skeleton className="h-8 w-56" />
      <div className="grid gap-4 lg:grid-cols-3">
        <Card className="h-72 animate-pulse bg-slate-100 dark:bg-slate-900 lg:col-span-1" />
        <Card className="h-72 animate-pulse bg-slate-100 dark:bg-slate-900 lg:col-span-2" />
      </div>
    </div>
  );
}
