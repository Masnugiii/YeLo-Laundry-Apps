import { Card } from "@/components/ui/card";
import { formatCurrency } from "@/lib/utils";
import type { PaymentHistorySummary } from "@/types/finance";

export function PaymentHistoryCard({
  summary,
}: {
  summary: PaymentHistorySummary;
}) {
  const items = [
    { label: "Cash", value: summary.cash },
    { label: "Transfer", value: summary.transfer },
    { label: "QRIS", value: summary.qris },
    { label: "Wallet", value: summary.wallet },
    { label: "Outstanding", value: summary.outstanding },
    { label: "Refund", value: summary.refund },
  ];

  return (
    <Card className="space-y-4">
      <h3 className="text-lg font-semibold">Payment History</h3>
      <div className="grid gap-3 sm:grid-cols-2 xl:grid-cols-3">
        {items.map((item) => (
          <div
            key={item.label}
            className="rounded-lg border border-slate-200 p-4 dark:border-slate-800"
          >
            <p className="text-sm text-slate-500">{item.label}</p>
            <p className="mt-1 text-lg font-semibold">{formatCurrency(item.value)}</p>
          </div>
        ))}
      </div>
    </Card>
  );
}
