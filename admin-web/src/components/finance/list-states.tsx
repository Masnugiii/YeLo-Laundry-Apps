import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";

export function FinanceListSkeleton() {
  return (
    <div className="space-y-4">
      <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
        {Array.from({ length: 8 }).map((_, index) => (
          <Card key={index} className="h-24 animate-pulse bg-slate-100 dark:bg-slate-900" />
        ))}
      </div>
      <Card className="h-96 animate-pulse bg-slate-100 dark:bg-slate-900" />
    </div>
  );
}

export function QueryErrorState({
  title,
  message,
  onRetry,
}: {
  title: string;
  message: string;
  onRetry: () => void;
}) {
  return (
    <Card className="flex flex-col items-center justify-center gap-3 p-10 text-center">
      <h3 className="text-lg font-semibold">{title}</h3>
      <p className="max-w-md text-sm text-slate-500">{message}</p>
      <Button onClick={onRetry}>Try Again</Button>
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
    <Card className="flex flex-col items-center justify-center gap-2 p-10 text-center">
      <h3 className="text-lg font-semibold">{title}</h3>
      <p className="max-w-md text-sm text-slate-500">{description}</p>
    </Card>
  );
}
