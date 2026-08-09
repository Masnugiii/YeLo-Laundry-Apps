"use client";

import { useState } from "react";
import {
  FinanceListSkeleton,
  QueryErrorState,
} from "@/components/finance/list-states";
import { Button } from "@/components/ui/button";
import { Card, CardTitle, CardValue } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { useProfitLoss } from "@/hooks/use-finance";
import { getErrorMessage } from "@/lib/errors";
import {
  exportRowsCsv,
  exportRowsExcel,
  printFinanceReport,
} from "@/lib/finance-export";
import { formatCurrency } from "@/lib/utils";
import type { FinancePeriod } from "@/types/finance";

const PERIODS: FinancePeriod[] = ["daily", "weekly", "monthly", "yearly"];

export default function ProfitLossPage() {
  const [period, setPeriod] = useState<FinancePeriod>("monthly");
  const [dateFrom, setDateFrom] = useState("");
  const [dateTo, setDateTo] = useState("");

  const { data, isLoading, isError, error, refetch } = useProfitLoss({
    period,
    ...(dateFrom ? { dateFrom } : {}),
    ...(dateTo ? { dateTo } : {}),
  });

  if (isLoading) return <FinanceListSkeleton />;

  if (isError || !data) {
    return (
      <QueryErrorState
        title="Failed to load profit & loss"
        message={getErrorMessage(error, "Unable to fetch profit and loss report.")}
        onRetry={() => refetch()}
      />
    );
  }

  const summaryCards = [
    { title: "Revenue", value: data.summary.revenue },
    { title: "Expenses", value: data.summary.expenses },
    { title: "Payroll", value: data.summary.payroll },
    { title: "Gross Profit", value: data.summary.grossProfit },
    { title: "Operating Profit", value: data.summary.operatingProfit },
    { title: "Net Profit", value: data.summary.netProfit },
  ];

  const exportRows = data.periods.map((item) => ({
    Period: item.label,
    Revenue: item.revenue,
    Expenses: item.expenses,
    Payroll: item.payroll,
    "Net Profit": item.netProfit,
  }));

  return (
    <div className="space-y-6">
      <div className="flex flex-wrap gap-2">
        <Button variant="outline" onClick={() => exportRowsCsv("profit-loss.csv", exportRows)}>Export CSV</Button>
        <Button variant="outline" onClick={() => exportRowsExcel("profit-loss.xlsx", exportRows)}>Export Excel</Button>
        <Button variant="outline" onClick={() => printFinanceReport("Profit & Loss Report", exportRows)}>Print / PDF</Button>
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

      <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-3">
        {summaryCards.map((card) => (
          <Card key={card.title}>
            <CardTitle>{card.title}</CardTitle>
            <CardValue>{formatCurrency(card.value)}</CardValue>
          </Card>
        ))}
      </div>

      <div className="overflow-x-auto rounded-xl border border-slate-200 dark:border-slate-800">
        <table className="min-w-full divide-y divide-slate-200 text-sm dark:divide-slate-800">
          <thead className="bg-slate-50 dark:bg-slate-900/50">
            <tr>
              {["Period", "Revenue", "Expenses", "Payroll", "Net Profit"].map((header) => (
                <th key={header} className="px-4 py-3 text-left font-medium text-slate-500">{header}</th>
              ))}
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-200 bg-white dark:divide-slate-800 dark:bg-slate-950">
            {data.periods.map((item) => (
              <tr key={item.date}>
                <td className="px-4 py-3">{item.label}</td>
                <td className="px-4 py-3">{formatCurrency(item.revenue)}</td>
                <td className="px-4 py-3">{formatCurrency(item.expenses)}</td>
                <td className="px-4 py-3">{formatCurrency(item.payroll)}</td>
                <td className="px-4 py-3">{formatCurrency(item.netProfit)}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
