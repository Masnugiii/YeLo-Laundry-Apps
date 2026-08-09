"use client";

import { BiBarChart } from "@/components/bi/bi-charts";
import { ReportExportBar } from "@/components/bi/report-export-bar";
import {
  ReportPageShell,
  useReportFilters,
} from "@/components/bi/report-page-shell";
import { Card } from "@/components/ui/card";
import { useEmployeePerformance } from "@/hooks/use-reports";
import { formatCurrency } from "@/lib/utils";

export default function EmployeePerformancePage() {
  const filters = useReportFilters("this_month");
  const query = useEmployeePerformance(filters.applied);
  const data = query.data;

  const exportRows =
    data?.employees.map((e) => ({
      Employee: e.employeeName,
      Code: e.employeeCode,
      Position: e.position,
      Attendance: e.attendanceDays,
      "Orders Completed": e.ordersCompleted,
      "Kg Processed": e.kgProcessed,
      Bonus: e.bonusEarned,
      Payroll: e.payroll,
      "Revenue Handled": e.revenueHandled,
      Productivity: e.productivity,
    })) ?? [];

  return (
    <ReportPageShell
      title="Employee Performance"
      description="Attendance, productivity, output, bonus, and payroll by employee."
      filters={filters}
      query={query}
    >
      {data ? (
        <>
          <ReportExportBar
            filename="employee-performance"
            title="Employee Performance"
            rows={exportRows}
          />
          <BiBarChart
            title="Revenue Handled by Employee"
            data={data.employees.slice(0, 12).map((e) => ({
              label: e.employeeName,
              value: e.revenueHandled,
            }))}
            currency
          />
          <Card className="overflow-x-auto p-4">
            <h3 className="mb-4 font-semibold">Employee Performance Table</h3>
            <table className="min-w-full text-sm">
              <thead>
                <tr className="border-b text-left text-slate-500">
                  <th className="px-3 py-2">Employee</th>
                  <th className="px-3 py-2">Attendance</th>
                  <th className="px-3 py-2">Orders</th>
                  <th className="px-3 py-2">Kg</th>
                  <th className="px-3 py-2">Bonus</th>
                  <th className="px-3 py-2">Payroll</th>
                  <th className="px-3 py-2">Revenue</th>
                </tr>
              </thead>
              <tbody>
                {data.employees.map((employee) => (
                  <tr key={employee.employeeId} className="border-b">
                    <td className="px-3 py-2">{employee.employeeName}</td>
                    <td className="px-3 py-2">{employee.attendanceDays}</td>
                    <td className="px-3 py-2">{employee.ordersCompleted}</td>
                    <td className="px-3 py-2">{employee.kgProcessed}</td>
                    <td className="px-3 py-2">{formatCurrency(employee.bonusEarned)}</td>
                    <td className="px-3 py-2">{formatCurrency(employee.payroll)}</td>
                    <td className="px-3 py-2">{formatCurrency(employee.revenueHandled)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </Card>
        </>
      ) : null}
    </ReportPageShell>
  );
}
