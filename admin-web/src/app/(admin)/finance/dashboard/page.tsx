"use client";

import { FinanceCharts } from "@/components/finance/finance-charts";
import { FinanceKpiCards } from "@/components/finance/kpi-cards";
import {
  FinanceListSkeleton,
  QueryErrorState,
} from "@/components/finance/list-states";
import { OwnerSummaryCard } from "@/components/finance/owner-summary";
import { PaymentHistoryCard } from "@/components/finance/payment-history-card";
import { useFinanceDashboard, usePaymentHistory } from "@/hooks/use-finance";
import { getErrorMessage } from "@/lib/errors";

export default function FinanceDashboardPage() {
  const dashboardQuery = useFinanceDashboard();
  const paymentHistoryQuery = usePaymentHistory({ period: "monthly" });

  if (dashboardQuery.isLoading) return <FinanceListSkeleton />;

  if (dashboardQuery.isError || !dashboardQuery.data) {
    return (
      <QueryErrorState
        title="Failed to load finance dashboard"
        message={getErrorMessage(
          dashboardQuery.error,
          "Unable to fetch finance dashboard.",
        )}
        onRetry={() => dashboardQuery.refetch()}
      />
    );
  }

  return (
    <div className="space-y-6">
      <FinanceKpiCards data={dashboardQuery.data} />
      <OwnerSummaryCard summary={dashboardQuery.data.ownerSummary} />
      {paymentHistoryQuery.data ? (
        <PaymentHistoryCard summary={paymentHistoryQuery.data} />
      ) : null}
      <FinanceCharts data={dashboardQuery.data} />
    </div>
  );
}
