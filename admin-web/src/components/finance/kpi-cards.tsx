import { Card, CardTitle, CardValue } from "@/components/ui/card";
import { formatCurrency } from "@/lib/utils";
import type { FinanceDashboard } from "@/types/finance";

export function FinanceKpiCards({ data }: { data: FinanceDashboard }) {
  const metrics = [
    { title: "Today's Revenue", value: formatCurrency(data.revenueToday) },
    { title: "Weekly Revenue", value: formatCurrency(data.revenueThisWeek) },
    { title: "Monthly Revenue", value: formatCurrency(data.revenueThisMonth) },
    { title: "Yearly Revenue", value: formatCurrency(data.revenueThisYear) },
    {
      title: "Outstanding Payment",
      value: formatCurrency(data.outstandingPayment),
    },
    { title: "Cash Income", value: formatCurrency(data.cashIncome) },
    { title: "Digital Payment", value: formatCurrency(data.digitalPayment) },
    { title: "Expenses", value: formatCurrency(data.expenseAmount) },
    { title: "Payroll", value: formatCurrency(data.payrollAmount) },
    { title: "Net Profit", value: formatCurrency(data.netProfit) },
    {
      title: "Average Order Value",
      value: formatCurrency(data.averageOrderValue),
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
