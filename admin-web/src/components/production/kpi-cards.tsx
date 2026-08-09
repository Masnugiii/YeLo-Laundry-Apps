import { Card, CardTitle, CardValue } from "@/components/ui/card";
import type { ProductionDashboard } from "@/types/production";

interface KpiCardsProps {
  data: ProductionDashboard;
}

export function ProductionKpiCards({ data }: KpiCardsProps) {
  const metrics = [
    { title: "Receiving", value: data.receiving },
    { title: "Sorting", value: data.sorting },
    { title: "Washing", value: data.currentlyWashing + data.waitingWashing },
    { title: "Drying", value: data.currentlyDrying + data.waitingDrying },
    { title: "Ironing", value: data.currentlyIroning + data.waitingIroning },
    { title: "Quality Check", value: data.qualityCheck },
    { title: "Packing", value: data.packing },
    { title: "Ready Pickup", value: data.readyForPickup },
    { title: "Completed", value: data.completedToday },
    {
      title: "Delayed",
      value: data.delayed,
      highlight: data.delayed > 0 ? "text-red-600" : undefined,
    },
  ];

  return (
    <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-5">
      {metrics.map((metric) => (
        <Card key={metric.title}>
          <CardTitle>{metric.title}</CardTitle>
          <CardValue className={metric.highlight}>{metric.value}</CardValue>
        </Card>
      ))}
    </div>
  );
}
