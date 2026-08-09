import { Card, CardTitle, CardValue } from "@/components/ui/card";
import type { EmployeeStatistics } from "@/types/employee";

export function EmployeeStatisticsCards({ data }: { data: EmployeeStatistics }) {
  const metrics = [
    { title: "Total Employees", value: data.totalEmployees },
    { title: "Active", value: data.activeEmployees },
    { title: "Inactive", value: data.inactiveEmployees },
    { title: "Managers", value: data.managers },
    { title: "Cashiers", value: data.cashiers },
    { title: "Operators", value: data.operators },
    { title: "Drivers", value: data.drivers },
    { title: "Binatu", value: data.binatu },
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
