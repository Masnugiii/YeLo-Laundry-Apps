import { Card, CardTitle, CardValue } from "@/components/ui/card";
import { formatCurrency, formatDate } from "@/lib/utils";
import type { PayrollDashboard } from "@/types/payroll";

export function PayrollKpiCards({ data }: { data: PayrollDashboard }) {
  const metrics = [
    {
      title: "Current Period",
      value: `${formatDate(data.currentPeriod.start)} – ${formatDate(data.currentPeriod.end)}`,
    },
    {
      title: "Employees Waiting Payroll",
      value: String(data.employeesWaitingPayroll),
    },
    {
      title: "Estimated Payroll",
      value: formatCurrency(data.estimatedPayroll),
    },
    {
      title: "Paid Payroll",
      value: formatCurrency(data.paidPayroll),
    },
    {
      title: "Total Bonus",
      value: formatCurrency(data.totalBonus),
    },
    {
      title: "Total Deduction",
      value: formatCurrency(data.totalDeduction),
    },
  ];

  return (
    <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-3">
      {metrics.map((metric) => (
        <Card key={metric.title}>
          <CardTitle>{metric.title}</CardTitle>
          <CardValue className="text-lg">{metric.value}</CardValue>
        </Card>
      ))}
    </div>
  );
}
