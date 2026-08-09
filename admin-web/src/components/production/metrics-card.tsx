import { Card } from "@/components/ui/card";
import { computeProductionMetrics } from "@/lib/production-stages";
import type { ProductionDetail } from "@/types/production";

interface ProductionMetricsCardProps {
  order: ProductionDetail;
}

export function ProductionMetricsCard({ order }: ProductionMetricsCardProps) {
  const metrics = computeProductionMetrics(
    order.productionHistory,
    order.receivedAt,
  );

  const items = [
    { label: "Production Time", value: `${metrics.productionTimeMinutes} min` },
    { label: "Waiting Time", value: `${metrics.waitingTimeMinutes} min` },
    { label: "Processing Time", value: `${metrics.processingTimeMinutes} min` },
    { label: "Total Duration", value: `${metrics.totalDurationMinutes} min` },
  ];

  return (
    <Card className="space-y-4">
      <h3 className="text-lg font-semibold text-slate-900 dark:text-slate-100">
        Production Metrics
      </h3>
      <div className="grid gap-3 sm:grid-cols-2">
        {items.map((item) => (
          <div
            key={item.label}
            className="rounded-lg border border-slate-200 p-4 dark:border-slate-800"
          >
            <p className="text-sm text-slate-500">{item.label}</p>
            <p className="mt-1 text-xl font-semibold text-slate-900 dark:text-slate-100">
              {item.value}
            </p>
          </div>
        ))}
      </div>
    </Card>
  );
}
