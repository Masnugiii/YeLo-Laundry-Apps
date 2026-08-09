"use client";

import { BiBarChart, BiPieChart } from "@/components/bi/bi-charts";
import { ReportExportBar } from "@/components/bi/report-export-bar";
import { ReportKpiGrid } from "@/components/bi/report-kpi-grid";
import {
  ReportPageShell,
  useReportFilters,
} from "@/components/bi/report-page-shell";
import { Card } from "@/components/ui/card";
import { usePayrollAnalytics } from "@/hooks/use-reports";
import { formatCurrency } from "@/lib/utils";

export default function PayrollAnalyticsPage() {
  const filters = useReportFilters("this_month");
  const query = usePayrollAnalytics(filters.applied);
  const data = query.data;

  const exportRows =
    data?.byEmployee.map((e) => ({
      Employee: e.employeeName,
      Code: e.employeeCode,
      "Net Salary": e.netSalary,
      Bonus: e.bonus,
      Deduction: e.deduction,
      Periods: e.periods,
    })) ?? [];

  return (
    <ReportPageShell
      title="Payroll Analytics"
      description="Payroll history, bonus, deductions, and breakdown by employee and role."
      filters={filters}
      query={query}
    >
      {data ? (
        <>
          <ReportExportBar
            filename="payroll-analytics"
            title="Payroll Analytics"
            rows={exportRows}
          />
          <ReportKpiGrid
            items={[
              { title: "Total Payroll", value: formatCurrency(data.summary.totalPayroll) },
              { title: "Total Bonus", value: formatCurrency(data.summary.totalBonus) },
              {
                title: "Total Deduction",
                value: formatCurrency(data.summary.totalDeduction),
              },
              {
                title: "Average Payroll",
                value: formatCurrency(data.summary.averagePayroll),
              },
            ]}
          />
          <div className="grid gap-4 xl:grid-cols-2">
            <BiBarChart
              title="Payroll by Employee"
              data={data.byEmployee.slice(0, 10).map((e) => ({
                label: e.employeeName,
                value: e.netSalary,
              }))}
              currency
            />
            <BiPieChart
              title="Payroll by Role"
              data={data.byRole.map((r) => ({ name: r.role, value: r.netSalary }))}
              currency
            />
          </div>
          <Card className="overflow-x-auto p-4">
            <h3 className="mb-4 font-semibold">Payroll History</h3>
            <table className="min-w-full text-sm">
              <thead>
                <tr className="border-b text-left text-slate-500">
                  <th className="px-3 py-2">Employee</th>
                  <th className="px-3 py-2">Period</th>
                  <th className="px-3 py-2">Net Salary</th>
                  <th className="px-3 py-2">Bonus</th>
                  <th className="px-3 py-2">Deduction</th>
                  <th className="px-3 py-2">Status</th>
                </tr>
              </thead>
              <tbody>
                {data.history.map((row) => (
                  <tr key={row.id} className="border-b">
                    <td className="px-3 py-2">{row.employeeName}</td>
                    <td className="px-3 py-2">
                      {new Date(row.periodStart).toLocaleDateString()} –{" "}
                      {new Date(row.periodEnd).toLocaleDateString()}
                    </td>
                    <td className="px-3 py-2">{formatCurrency(row.netSalary)}</td>
                    <td className="px-3 py-2">{formatCurrency(row.totalBonus)}</td>
                    <td className="px-3 py-2">{formatCurrency(row.totalDeduction)}</td>
                    <td className="px-3 py-2">{row.status}</td>
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
