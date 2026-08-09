"use client";

import { BiAreaChart, BiLineChart } from "@/components/bi/bi-charts";
import { ReportExportBar } from "@/components/bi/report-export-bar";
import { ReportKpiGrid } from "@/components/bi/report-kpi-grid";
import {
  ReportPageShell,
  useReportFilters,
} from "@/components/bi/report-page-shell";
import { useFinanceAnalytics } from "@/hooks/use-reports";
import { formatCurrency } from "@/lib/utils";

export default function FinanceAnalyticsPage() {
  const filters = useReportFilters("this_month");
  const query = useFinanceAnalytics(filters.applied);
  const data = query.data;

  const exportRows = data
    ? [
        { Metric: "Revenue", Value: data.revenue },
        { Metric: "Expense", Value: data.expense },
        { Metric: "Payroll", Value: data.payroll },
        { Metric: "Gross Profit", Value: data.grossProfit },
        { Metric: "Net Profit", Value: data.netProfit },
        { Metric: "Cash Flow", Value: data.cashFlow },
        { Metric: "Operating Margin %", Value: data.operatingMargin },
      ]
    : [];

  return (
    <ReportPageShell
      title="Finance Analytics"
      description="Revenue, expenses, payroll, profit, cash flow, and operating margin."
      filters={filters}
      query={query}
    >
      {data ? (
        <>
          <ReportExportBar
            filename="finance-analytics"
            title="Finance Analytics"
            rows={exportRows}
          />
          <ReportKpiGrid
            items={[
              { title: "Revenue", value: formatCurrency(data.revenue) },
              { title: "Expense", value: formatCurrency(data.expense) },
              { title: "Payroll", value: formatCurrency(data.payroll) },
              { title: "Gross Profit", value: formatCurrency(data.grossProfit) },
              { title: "Net Profit", value: formatCurrency(data.netProfit) },
              { title: "Cash Flow", value: formatCurrency(data.cashFlow) },
              { title: "Operating Margin", value: `${data.operatingMargin}%` },
            ]}
          />
          <div className="grid gap-4 xl:grid-cols-2">
            <BiAreaChart
              title="Revenue vs Expenses"
              data={data.trend}
              lines={[
                { key: "revenue", color: "#2563eb", label: "Revenue" },
                { key: "expenses", color: "#ef4444", label: "Expenses" },
                { key: "netProfit", color: "#16a34a", label: "Net Profit" },
              ]}
            />
            <BiLineChart title="Cash Flow Trend" data={data.cashFlowTrend} currency />
          </div>
        </>
      ) : null}
    </ReportPageShell>
  );
}
