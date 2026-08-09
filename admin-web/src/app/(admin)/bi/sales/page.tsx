"use client";

import { BiBarChart, BiLineChart, BiPieChart } from "@/components/bi/bi-charts";
import { ReportExportBar } from "@/components/bi/report-export-bar";
import { ReportKpiGrid } from "@/components/bi/report-kpi-grid";
import {
  ReportPageShell,
  useReportFilters,
} from "@/components/bi/report-page-shell";
import { useSalesReport } from "@/hooks/use-reports";
import { formatCurrency } from "@/lib/utils";

export default function SalesReportPage() {
  const filters = useReportFilters("this_month");
  const query = useSalesReport(filters.applied);
  const data = query.data;

  const serviceRows =
    data?.revenuePerService.map((item) => ({
      Service: item.serviceName,
      Code: item.serviceCode,
      Orders: item.orderCount,
      Revenue: item.revenue,
    })) ?? [];

  return (
    <ReportPageShell
      title="Sales Report"
      description="Revenue breakdown by time, service, employee, and customer."
      filters={filters}
      query={query}
    >
      {data ? (
        <>
          <ReportExportBar filename="sales-report" title="Sales Report" rows={serviceRows} />
          <ReportKpiGrid
            items={[
              { title: "Total Revenue", value: formatCurrency(data.summary.totalRevenue) },
              {
                title: "Average Transaction",
                value: formatCurrency(data.summary.averageTransaction),
              },
              {
                title: "Largest Transaction",
                value: formatCurrency(data.summary.largestTransaction),
              },
              {
                title: "Transactions",
                value: String(data.summary.transactionCount),
              },
            ]}
          />
          <div className="grid gap-4 xl:grid-cols-2">
            <BiLineChart title="Revenue per Day" data={data.revenuePerDay} currency />
            <BiBarChart title="Revenue per Week" data={data.revenuePerWeek} currency />
            <BiPieChart
              title="Revenue per Service"
              data={data.revenuePerService.slice(0, 8).map((s) => ({
                name: s.serviceName,
                value: s.revenue,
              }))}
              currency
            />
            <BiBarChart
              title="Top Employees by Revenue"
              data={data.revenuePerEmployee.slice(0, 10).map((e) => ({
                label: e.employeeName,
                value: e.revenue,
              }))}
              currency
            />
          </div>
        </>
      ) : null}
    </ReportPageShell>
  );
}
