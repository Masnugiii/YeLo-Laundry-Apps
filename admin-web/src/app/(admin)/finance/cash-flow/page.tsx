"use client";

import { useState } from "react";
import {
  EmptyState,
  FinanceListSkeleton,
  QueryErrorState,
} from "@/components/finance/list-states";
import { Button } from "@/components/ui/button";
import { Card, CardTitle, CardValue } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { useCashFlow } from "@/hooks/use-finance";
import { getErrorMessage } from "@/lib/errors";
import {
  exportRowsCsv,
  exportRowsExcel,
  printFinanceReport,
} from "@/lib/finance-export";
import { formatCurrency, formatDate } from "@/lib/utils";
import type { FinancePeriod } from "@/types/finance";

const PERIODS: FinancePeriod[] = ["daily", "weekly", "monthly", "yearly"];

export default function CashFlowPage() {
  const [period, setPeriod] = useState<FinancePeriod>("monthly");
  const [dateFrom, setDateFrom] = useState("");
  const [dateTo, setDateTo] = useState("");

  const { data, isLoading, isError, error, refetch } = useCashFlow({
    period,
    ...(dateFrom ? { dateFrom } : {}),
    ...(dateTo ? { dateTo } : {}),
  });

  if (isLoading) return <FinanceListSkeleton />;

  if (isError || !data) {
    return (
      <QueryErrorState
        title="Failed to load cash flow"
        message={getErrorMessage(error, "Unable to fetch cash flow report.")}
        onRetry={() => refetch()}
      />
    );
  }

  const exportRows = data.entries.map((entry) => ({
    Type: entry.type,
    Reference: entry.referenceType,
    Amount: entry.amount,
    Description: entry.description ?? "",
    Date: formatDate(entry.transactionDate),
    "Running Balance": entry.runningBalance,
  }));

  return (
    <div className="space-y-6">
      <div className="flex flex-wrap gap-2">
        <Button variant="outline" onClick={() => exportRowsCsv("cash-flow.csv", exportRows)}>Export CSV</Button>
        <Button variant="outline" onClick={() => exportRowsExcel("cash-flow.xlsx", exportRows)}>Export Excel</Button>
        <Button variant="outline" onClick={() => printFinanceReport("Cash Flow Report", exportRows)}>Print / PDF</Button>
      </div>

      <div className="grid gap-3 md:grid-cols-4">
        <select
          className="h-10 rounded-lg border border-slate-200 bg-white px-3 text-sm dark:border-slate-700 dark:bg-slate-900"
          value={period}
          onChange={(event) => setPeriod(event.target.value as FinancePeriod)}
        >
          {PERIODS.map((item) => (
            <option key={item} value={item}>{item}</option>
          ))}
        </select>
        <Input type="date" value={dateFrom} onChange={(e) => setDateFrom(e.target.value)} />
        <Input type="date" value={dateTo} onChange={(e) => setDateTo(e.target.value)} />
      </div>

      <div className="grid gap-4 md:grid-cols-3">
        <Card>
          <CardTitle>Money In</CardTitle>
          <CardValue>{formatCurrency(data.moneyIn)}</CardValue>
        </Card>
        <Card>
          <CardTitle>Money Out</CardTitle>
          <CardValue>{formatCurrency(data.moneyOut)}</CardValue>
        </Card>
        <Card>
          <CardTitle>Ending Balance</CardTitle>
          <CardValue>{formatCurrency(data.endingBalance)}</CardValue>
        </Card>
      </div>

      {data.entries.length === 0 ? (
        <EmptyState title="No cash flow entries" description="Cash flow entries appear when payments and expenses are recorded." />
      ) : (
        <div className="overflow-x-auto rounded-xl border border-slate-200 dark:border-slate-800">
          <table className="min-w-full divide-y divide-slate-200 text-sm dark:divide-slate-800">
            <thead className="bg-slate-50 dark:bg-slate-900/50">
              <tr>
                {["Type", "Reference", "Amount", "Description", "Date", "Running Balance"].map((header) => (
                  <th key={header} className="px-4 py-3 text-left font-medium text-slate-500">{header}</th>
                ))}
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-200 bg-white dark:divide-slate-800 dark:bg-slate-950">
              {data.entries.map((entry) => (
                <tr key={entry.id}>
                  <td className="px-4 py-3">{entry.type}</td>
                  <td className="px-4 py-3">{entry.referenceType}</td>
                  <td className="px-4 py-3">{formatCurrency(entry.amount)}</td>
                  <td className="px-4 py-3">{entry.description ?? "-"}</td>
                  <td className="px-4 py-3">{formatDate(entry.transactionDate)}</td>
                  <td className="px-4 py-3">{formatCurrency(entry.runningBalance)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
