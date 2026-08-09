"use client";

import { useMemo } from "react";
import { FinancialSummaryCards } from "@/components/finance/financial-summary-cards";
import {
  FinanceReportFilterBar,
  useFinanceReportFilters,
} from "@/components/finance/finance-report-filter";
import {
  EmptyState,
  FinanceListSkeleton,
  QueryErrorState,
} from "@/components/finance/list-states";
import {
  useExpenses,
  useFinancialSummary,
  useRevenue,
} from "@/hooks/use-finance";
import { getErrorMessage } from "@/lib/errors";
import { formatCurrency, formatDate } from "@/lib/utils";

export default function ReportsPage() {
  const filters = useFinanceReportFilters("monthly");
  const summaryQuery = useFinancialSummary(filters.applied);

  const listParams = useMemo(
    () => ({
      page: 1,
      limit: 10,
      ...(filters.applied.dateFrom ? { dateFrom: filters.applied.dateFrom } : {}),
      ...(filters.applied.dateTo ? { dateTo: filters.applied.dateTo } : {}),
    }),
    [filters.applied],
  );

  const revenueQuery = useRevenue(listParams);
  const expensesQuery = useExpenses(listParams);

  if (summaryQuery.isLoading) return <FinanceListSkeleton />;

  if (summaryQuery.isError || !summaryQuery.data) {
    return (
      <div className="space-y-6">
        <div>
          <h2 className="text-xl font-semibold">Financial Reports</h2>
          <p className="text-sm text-slate-500">
            Revenue, expenses, payments, wallet, and profit/loss for the selected
            period.
          </p>
        </div>
        <FinanceReportFilterBar
          period={filters.period}
          dateFrom={filters.dateFrom}
          dateTo={filters.dateTo}
          onPeriodChange={filters.setPeriod}
          onDateFromChange={filters.setDateFrom}
          onDateToChange={filters.setDateTo}
          onApply={filters.applyFilters}
        />
        <QueryErrorState
          title="Failed to load financial reports"
          message={getErrorMessage(
            summaryQuery.error,
            "Unable to fetch financial summary.",
          )}
          onRetry={() => summaryQuery.refetch()}
        />
      </div>
    );
  }

  const revenueItems = revenueQuery.data?.items ?? [];
  const expenseItems = expensesQuery.data?.items ?? [];

  return (
    <div className="space-y-6">
      <div>
        <h2 className="text-xl font-semibold">Financial Reports</h2>
        <p className="text-sm text-slate-500">
          Revenue, expenses, payments, wallet, and profit/loss for the selected
          period.
        </p>
      </div>

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

      <section className="space-y-3">
        <h3 className="text-lg font-semibold">Revenue Records</h3>
        {revenueQuery.isLoading ? (
          <FinanceListSkeleton />
        ) : revenueQuery.isError ? (
          <QueryErrorState
            title="Failed to load revenue records"
            message={getErrorMessage(
              revenueQuery.error,
              "Unable to fetch revenue records.",
            )}
            onRetry={() => revenueQuery.refetch()}
          />
        ) : revenueItems.length === 0 ? (
          <EmptyState
            title="No revenue records"
            description="No paid transactions found for this period."
          />
        ) : (
          <div className="overflow-x-auto rounded-xl border border-slate-200 dark:border-slate-800">
            <table className="min-w-full divide-y divide-slate-200 text-sm dark:divide-slate-800">
              <thead className="bg-slate-50 dark:bg-slate-900/50">
                <tr>
                  {[
                    "Invoice",
                    "Customer",
                    "Method",
                    "Amount",
                    "Paid Date",
                    "Cashier",
                  ].map((header) => (
                    <th
                      key={header}
                      className="px-4 py-3 text-left font-medium text-slate-500"
                    >
                      {header}
                    </th>
                  ))}
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-200 bg-white dark:divide-slate-800 dark:bg-slate-950">
                {revenueItems.map((item) => (
                  <tr key={item.id}>
                    <td className="px-4 py-3">{item.invoice}</td>
                    <td className="px-4 py-3">{item.customerName}</td>
                    <td className="px-4 py-3">{item.paymentMethod}</td>
                    <td className="px-4 py-3">{formatCurrency(item.amount)}</td>
                    <td className="px-4 py-3">{formatDate(item.paidDate)}</td>
                    <td className="px-4 py-3">{item.cashier}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </section>

      <section className="space-y-3">
        <h3 className="text-lg font-semibold">Expense Records</h3>
        {expensesQuery.isLoading ? (
          <FinanceListSkeleton />
        ) : expensesQuery.isError ? (
          <QueryErrorState
            title="Failed to load expense records"
            message={getErrorMessage(
              expensesQuery.error,
              "Unable to fetch expense records.",
            )}
            onRetry={() => expensesQuery.refetch()}
          />
        ) : expenseItems.length === 0 ? (
          <EmptyState
            title="No expense records"
            description="No expenses found for this period."
          />
        ) : (
          <div className="overflow-x-auto rounded-xl border border-slate-200 dark:border-slate-800">
            <table className="min-w-full divide-y divide-slate-200 text-sm dark:divide-slate-800">
              <thead className="bg-slate-50 dark:bg-slate-900/50">
                <tr>
                  {["Reference", "Title", "Category", "Amount", "Date"].map(
                    (header) => (
                      <th
                        key={header}
                        className="px-4 py-3 text-left font-medium text-slate-500"
                      >
                        {header}
                      </th>
                    ),
                  )}
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-200 bg-white dark:divide-slate-800 dark:bg-slate-950">
                {expenseItems.map((item) => (
                  <tr key={item.id}>
                    <td className="px-4 py-3">
                      {item.referenceNumber ?? item.id.slice(0, 8)}
                    </td>
                    <td className="px-4 py-3">{item.title}</td>
                    <td className="px-4 py-3">{item.category.name}</td>
                    <td className="px-4 py-3">{formatCurrency(item.amount)}</td>
                    <td className="px-4 py-3">{formatDate(item.expenseDate)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </section>
    </div>
  );
}
