"use client";

import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import type { ReportPeriodPreset } from "@/types/reports";

const PRESETS: { value: ReportPeriodPreset; label: string }[] = [
  { value: "today", label: "Today" },
  { value: "yesterday", label: "Yesterday" },
  { value: "last_7_days", label: "Last 7 Days" },
  { value: "last_30_days", label: "Last 30 Days" },
  { value: "this_month", label: "This Month" },
  { value: "last_month", label: "Last Month" },
  { value: "custom", label: "Custom" },
];

export function ReportFilterBar({
  period,
  dateFrom,
  dateTo,
  onPeriodChange,
  onDateFromChange,
  onDateToChange,
  onApply,
}: {
  period: ReportPeriodPreset;
  dateFrom: string;
  dateTo: string;
  onPeriodChange: (period: ReportPeriodPreset) => void;
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
          onChange={(e) => onPeriodChange(e.target.value as ReportPeriodPreset)}
        >
          {PRESETS.map((preset) => (
            <option key={preset.value} value={preset.value}>
              {preset.label}
            </option>
          ))}
        </select>
      </div>
      {period === "custom" ? (
        <>
          <div className="space-y-1">
            <label className="text-xs font-medium text-slate-500">From</label>
            <Input type="date" value={dateFrom} onChange={(e) => onDateFromChange(e.target.value)} />
          </div>
          <div className="space-y-1">
            <label className="text-xs font-medium text-slate-500">To</label>
            <Input type="date" value={dateTo} onChange={(e) => onDateToChange(e.target.value)} />
          </div>
        </>
      ) : null}
      <Button onClick={onApply}>Apply</Button>
    </div>
  );
}
