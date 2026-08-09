"use client";

import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import type { FinancePeriod, FinanceReportParams } from "@/types/finance";

const PERIODS: { value: FinancePeriod; label: string }[] = [
  { value: "daily", label: "Today" },
  { value: "weekly", label: "This Week" },
  { value: "monthly", label: "This Month" },
  { value: "yearly", label: "This Year" },
];

export function useFinanceReportFilters(
  defaultPeriod: FinancePeriod = "monthly",
) {
  const [period, setPeriod] = useState<FinancePeriod>(defaultPeriod);
  const [dateFrom, setDateFrom] = useState("");
  const [dateTo, setDateTo] = useState("");
  const [applied, setApplied] = useState<FinanceReportParams>({
    period: defaultPeriod,
  });

  const applyFilters = () => {
    setApplied({
      period,
      ...(dateFrom ? { dateFrom } : {}),
      ...(dateTo ? { dateTo } : {}),
    });
  };

  return {
    period,
    setPeriod,
    dateFrom,
    setDateFrom,
    dateTo,
    setDateTo,
    applied,
    applyFilters,
  };
}

export function FinanceReportFilterBar({
  period,
  dateFrom,
  dateTo,
  onPeriodChange,
  onDateFromChange,
  onDateToChange,
  onApply,
}: {
  period: FinancePeriod;
  dateFrom: string;
  dateTo: string;
  onPeriodChange: (period: FinancePeriod) => void;
  onDateFromChange: (value: string) => void;
  onDateToChange: (value: string) => void;
  onApply: () => void;
}) {
  return (
    <div className="flex flex-wrap items-end gap-3 rounded-lg border border-slate-200 bg-white p-4 dark:border-slate-800 dark:bg-slate-950">
      <div className="space-y-1">
        <label className="text-xs font-medium text-slate-500">Period</label>
        <select
          className="h-10 rounded-md border border-slate-200 bg-white px-3 text-sm dark:border-slate-800 dark:bg-slate-950"
          value={period}
          onChange={(event) =>
            onPeriodChange(event.target.value as FinancePeriod)
          }
        >
          {PERIODS.map((item) => (
            <option key={item.value} value={item.value}>
              {item.label}
            </option>
          ))}
        </select>
      </div>
      <div className="space-y-1">
        <label className="text-xs font-medium text-slate-500">From</label>
        <Input
          type="date"
          value={dateFrom}
          onChange={(event) => onDateFromChange(event.target.value)}
        />
      </div>
      <div className="space-y-1">
        <label className="text-xs font-medium text-slate-500">To</label>
        <Input
          type="date"
          value={dateTo}
          onChange={(event) => onDateToChange(event.target.value)}
        />
      </div>
      <Button onClick={onApply}>Apply</Button>
    </div>
  );
}
