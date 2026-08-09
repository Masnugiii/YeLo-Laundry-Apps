import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { Skeleton } from "@/components/ui/badge";

export function QueryErrorState({
  title,
  message,
  onRetry,
}: {
  title: string;
  message: string;
  onRetry?: () => void;
}) {
  return (
    <Card className="flex flex-col items-center justify-center gap-4 py-16 text-center">
      <div>
        <h3 className="text-base font-semibold">{title}</h3>
        <p className="mt-2 text-sm text-slate-500">{message}</p>
      </div>
      {onRetry ? <Button onClick={onRetry}>Try again</Button> : null}
    </Card>
  );
}

export function EmptyState({
  title,
  description,
}: {
  title: string;
  description: string;
}) {
  return (
    <Card className="flex flex-col items-center justify-center gap-2 py-16 text-center">
      <h3 className="text-base font-semibold">{title}</h3>
      <p className="max-w-md text-sm text-slate-500">{description}</p>
    </Card>
  );
}

export function OrderListSkeleton() {
  return (
    <div className="space-y-4">
      <div className="grid gap-3 xl:grid-cols-4">
        {Array.from({ length: 4 }).map((_, index) => (
          <Skeleton key={index} className="h-10" />
        ))}
      </div>
      <Skeleton className="h-[28rem] w-full" />
    </div>
  );
}

export function OrderDetailSkeleton() {
  return (
    <div className="space-y-6">
      <Skeleton className="h-8 w-64" />
      <div className="grid gap-4 md:grid-cols-2">
        {Array.from({ length: 8 }).map((_, index) => (
          <Skeleton key={index} className="h-16 w-full" />
        ))}
      </div>
    </div>
  );
}
