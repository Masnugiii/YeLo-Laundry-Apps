"use client";

import { useRouter } from "next/navigation";
import { useEffect } from "react";
import { ReportKpiGrid } from "@/components/bi/report-kpi-grid";
import {
  ReportPageShell,
  useReportFilters,
} from "@/components/bi/report-page-shell";
import { Card } from "@/components/ui/card";
import { useForecastReport } from "@/hooks/use-reports";
import { isOwnerRole } from "@/lib/auth";
import { formatCurrency } from "@/lib/utils";

export default function ForecastPage() {
  const router = useRouter();
  const filters = useReportFilters("last_30_days");
  const query = useForecastReport(filters.applied);
  const data = query.data;

  useEffect(() => {
    if (!isOwnerRole()) {
      router.replace("/bi/executive");
    }
  }, [router]);

  if (!isOwnerRole()) return null;

  return (
    <ReportPageShell
      title="Forecast"
      description="Revenue, orders, payroll, and production estimates based on historical averages."
      filters={filters}
      query={query}
    >
      {data ? (
        <>
          <Card className="p-4 text-sm text-slate-600 dark:text-slate-300">
            {data.disclaimer} Based on {data.basedOnDays} days of historical data (
            {data.method}).
          </Card>
          <ReportKpiGrid
            items={[
              {
                title: "Revenue (Next 7 Days)",
                value: formatCurrency(data.forecast.revenue.next7Days),
              },
              {
                title: "Revenue (Next 30 Days)",
                value: formatCurrency(data.forecast.revenue.next30Days),
              },
              {
                title: "Orders (Next 7 Days)",
                value: String(data.forecast.orders.next7Days),
              },
              {
                title: "Orders (Next 30 Days)",
                value: String(data.forecast.orders.next30Days),
              },
              {
                title: "Payroll (Next Period)",
                value: formatCurrency(data.forecast.payroll.nextPeriod),
              },
              {
                title: "Production (Next 7 Days)",
                value: `${data.forecast.production.next7DaysKg} kg`,
              },
              {
                title: "Production (Next 30 Days)",
                value: `${data.forecast.production.next30DaysKg} kg`,
              },
              {
                title: "Avg Daily Revenue",
                value: formatCurrency(data.historical.avgDailyRevenue),
              },
            ]}
          />
        </>
      ) : null}
    </ReportPageShell>
  );
}
