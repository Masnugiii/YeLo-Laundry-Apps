"use client";

import { FinanceCharts } from "@/components/finance/finance-charts";
import { FinancialSummaryCards } from "@/components/finance/financial-summary-cards";
import {
  FinanceReportFilterBar,
  useFinanceReportFilters,
} from "@/components/finance/finance-report-filter";
import { FinanceKpiCards } from "@/components/finance/kpi-cards";
import {
  FinanceListSkeleton,
  QueryErrorState,
} from "@/components/finance/list-states";
import { OwnerSummaryCard } from "@/components/finance/owner-summary";
import { PaymentHistoryCard } from "@/components/finance/payment-history-card";
import {
  useFinanceDashboard,
  useFinancialSummary,
  usePaymentHistory,
} from "@/hooks/use-finance";
import { getErrorMessage } from "@/lib/errors";

export default function FinanceDashboardPage() {
  const filters = useFinanceReportFilters("monthly");
  const dashboardQuery = useFinanceDashboard();
  const summaryQuery = useFinancialSummary(filters.applied);
  const paymentHistoryQuery = usePaymentHistory(filters.applied);

  if (dashboardQuery.isLoading || summaryQuery.isLoading) {
    return <FinanceListSkeleton />;
  }

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

  if (summaryQuery.isError || !summaryQuery.data) {
    return (
      <QueryErrorState
        title="Failed to load financial summary"
        message={getErrorMessage(
          summaryQuery.error,
          "Unable to fetch financial summary.",
        )}
        onRetry={() => summaryQuery.refetch()}
      />
    );
  }

  return (
    <div className="space-y-6">
      <FinanceReportFilterBar
        period={filters.period}
        dateFrom={filters.dateFrom}
        dateTo={filters.dateTo}
        onPeriodChange={filters.setPeriod}
        onDateFromChange={filters.setDateFrom}
        onDateToChange={filters.setDateTo}
        onApply={filters.applyFilters}
      />
      <FinancialSummaryCards data={summaryQuery.data} />
      <FinanceKpiCards data={dashboardQuery.data} />
      <OwnerSummaryCard summary={dashboardQuery.data.ownerSummary} />
      {paymentHistoryQuery.data ? (
        <PaymentHistoryCard summary={paymentHistoryQuery.data} />
      ) : null}
      <FinanceCharts data={dashboardQuery.data} />
    </div>
  );
}
