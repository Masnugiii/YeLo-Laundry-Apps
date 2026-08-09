"use client";

import { BiLineChart, BiPieChart } from "@/components/bi/bi-charts";
import { ReportExportBar } from "@/components/bi/report-export-bar";
import { ReportKpiGrid } from "@/components/bi/report-kpi-grid";
import {
  ReportPageShell,
  useReportFilters,
} from "@/components/bi/report-page-shell";
import { useWalletAnalytics } from "@/hooks/use-reports";
import { formatCurrency } from "@/lib/utils";

export default function WalletAnalyticsPage() {
  const filters = useReportFilters("this_month");
  const query = useWalletAnalytics(filters.applied);
  const data = query.data;

  const exportRows = data
    ? [
        { Type: "Top Up", Amount: data.topUp },
        { Type: "Wallet Payment", Amount: data.walletPayment },
        { Type: "Refund", Amount: data.refund },
        { Type: "Adjustment", Amount: data.adjustment },
        { Type: "Promotion", Amount: data.promotion },
        { Type: "Current Balance", Amount: data.currentBalance },
      ]
    : [];

  return (
    <ReportPageShell
      title="Wallet Analytics"
      description="Wallet top-ups, payments, refunds, adjustments, and balance trends."
      filters={filters}
      query={query}
    >
      {data ? (
        <>
          <ReportExportBar
            filename="wallet-analytics"
            title="Wallet Analytics"
            rows={exportRows}
          />
          <ReportKpiGrid
            items={[
              { title: "Top Up", value: formatCurrency(data.topUp) },
              { title: "Wallet Payment", value: formatCurrency(data.walletPayment) },
              { title: "Refund", value: formatCurrency(data.refund) },
              { title: "Adjustment", value: formatCurrency(data.adjustment) },
              { title: "Current Balance", value: formatCurrency(data.currentBalance) },
              { title: "Active Wallets", value: String(data.activeWallets) },
            ]}
          />
          <div className="grid gap-4 xl:grid-cols-2">
            <BiPieChart
              title="Wallet Activity Breakdown"
              data={data.breakdown.map((b) => ({ name: b.type, value: b.amount }))}
              currency
            />
            <BiLineChart title="Wallet Activity Trend" data={data.trend} currency />
          </div>
        </>
      ) : null}
    </ReportPageShell>
  );
}
