import { Card, CardTitle, CardValue } from "@/components/ui/card";
import { formatCurrency } from "@/lib/utils";
import type { FinancialSummary } from "@/types/finance";

export function FinancialSummaryCards({ data }: { data: FinancialSummary }) {
  const metrics = [
    { title: "Revenue", value: formatCurrency(data.revenue.total) },
    {
      title: "Payments",
      value: `${data.revenue.paymentCount} transactions`,
    },
    { title: "Expenses", value: formatCurrency(data.expense.total) },
    { title: "Gross Profit", value: formatCurrency(data.profitLoss.grossProfit) },
    { title: "Net Profit", value: formatCurrency(data.profitLoss.netProfit) },
    { title: "Cash", value: formatCurrency(data.payment.cash) },
    { title: "QRIS", value: formatCurrency(data.payment.qris) },
    { title: "Transfer", value: formatCurrency(data.payment.transfer) },
    { title: "Wallet Payments", value: formatCurrency(data.payment.wallet) },
    { title: "Wallet Top-up", value: formatCurrency(data.wallet.topUp) },
    {
      title: "Wallet Balance",
      value: formatCurrency(data.wallet.currentBalance),
    },
    {
      title: "Outstanding",
      value: formatCurrency(data.payment.outstanding),
    },
  ];

  return (
    <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
      {metrics.map((metric) => (
        <Card key={metric.title}>
          <CardTitle>{metric.title}</CardTitle>
          <CardValue>{metric.value}</CardValue>
        </Card>
      ))}
    </div>
  );
}
