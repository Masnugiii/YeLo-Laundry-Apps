"use client";

import { BiBarChart, BiLineChart } from "@/components/bi/bi-charts";
import { ReportExportBar } from "@/components/bi/report-export-bar";
import { ReportKpiGrid } from "@/components/bi/report-kpi-grid";
import {
  ReportPageShell,
  useReportFilters,
} from "@/components/bi/report-page-shell";
import { useProductionAnalytics } from "@/hooks/use-reports";

export default function ProductionAnalyticsPage() {
  const filters = useReportFilters("this_month");
  const query = useProductionAnalytics(filters.applied);
  const data = query.data;

  const exportRows =
    data?.productionPerEmployee.map((e) => ({
      Employee: e.employeeName,
      Code: e.employeeCode,
      "Jobs Completed": e.jobsCompleted,
      "Total Minutes": e.totalMinutes,
    })) ?? [];

  return (
    <ReportPageShell
      title="Production Analytics"
      description="Laundry throughput, completion time, delays, and employee output."
      filters={filters}
      query={query}
    >
      {data ? (
        <>
          <ReportExportBar
            filename="production-analytics"
            title="Production Analytics"
            rows={exportRows}
          />
          <ReportKpiGrid
            items={[
              { title: "Kg Processed", value: `${data.kgProcessed} kg` },
              { title: "Pieces Processed", value: String(data.piecesProcessed) },
              {
                title: "Avg Completion (min)",
                value: String(data.averageCompletionMinutes),
              },
              { title: "Delayed Orders", value: String(data.delayedOrders) },
            ]}
          />
          <div className="grid gap-4 xl:grid-cols-2">
            <BiLineChart title="Production Trend" data={data.productionTrend} />
            <BiBarChart
              title="Production per Employee"
              data={data.productionPerEmployee.map((e) => ({
                label: e.employeeName,
                value: e.jobsCompleted,
              }))}
            />
          </div>
        </>
      ) : null}
    </ReportPageShell>
  );
}
