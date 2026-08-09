import { Card, CardTitle, CardValue } from "@/components/ui/card";
import { formatCurrency } from "@/lib/utils";
import type { OwnerSummary } from "@/types/finance";

export function OwnerSummaryCard({ summary }: { summary: OwnerSummary }) {
  const items = [
    { title: "Today's Revenue", value: summary.revenueToday },
    { title: "Today's Expense", value: summary.expenseToday },
    { title: "Today's Profit", value: summary.profitToday },
    { title: "This Month Revenue", value: summary.revenueThisMonth },
    { title: "This Month Expense", value: summary.expenseThisMonth },
    { title: "This Month Profit", value: summary.profitThisMonth },
  ];

  return (
    <Card className="space-y-4">
      <h3 className="text-lg font-semibold">Owner Summary</h3>
      <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-3">
        {items.map((item) => (
          <div key={item.title}>
            <CardTitle>{item.title}</CardTitle>
            <CardValue>{formatCurrency(item.value)}</CardValue>
          </div>
        ))}
      </div>
    </Card>
  );
}
