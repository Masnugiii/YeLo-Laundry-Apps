import { Card, CardTitle, CardValue } from "@/components/ui/card";

export function ReportKpiGrid({
  items,
}: {
  items: Array<{ title: string; value: string }>;
}) {
  return (
    <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
      {items.map((item) => (
        <Card key={item.title}>
          <CardTitle>{item.title}</CardTitle>
          <CardValue className="text-lg">{item.value}</CardValue>
        </Card>
      ))}
    </div>
  );
}
