"use client";

import { useMemo, useState } from "react";
import {
  FinanceListSkeleton,
  QueryErrorState,
} from "@/components/finance/list-states";
import { ReportFilterBar } from "@/components/bi/report-filter-bar";
import { getErrorMessage } from "@/lib/errors";
import type { ReportPeriodPreset, ReportQueryParams } from "@/types/reports";

export function useReportFilters(defaultPeriod: ReportPeriodPreset = "this_month") {
  const [period, setPeriod] = useState<ReportPeriodPreset>(defaultPeriod);
  const [dateFrom, setDateFrom] = useState("");
  const [dateTo, setDateTo] = useState("");
  const [applied, setApplied] = useState<ReportQueryParams>({ period: defaultPeriod });

  const applyFilters = () => {
    setApplied({
      period,
      ...(period === "custom" && dateFrom ? { dateFrom } : {}),
      ...(period === "custom" && dateTo ? { dateTo } : {}),
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

export function ReportPageShell({
  title,
  description,
  filters,
  query,
  children,
}: {
  title: string;
  description: string;
  filters: ReturnType<typeof useReportFilters>;
  query: { isLoading: boolean; isError: boolean; error: unknown; refetch: () => void };
  children: React.ReactNode;
}) {
  const filterBar = useMemo(
    () => (
      <ReportFilterBar
        period={filters.period}
        dateFrom={filters.dateFrom}
        dateTo={filters.dateTo}
        onPeriodChange={filters.setPeriod}
        onDateFromChange={filters.setDateFrom}
        onDateToChange={filters.setDateTo}
        onApply={filters.applyFilters}
      />
    ),
    [filters],
  );

  if (query.isLoading) return <FinanceListSkeleton />;

  if (query.isError) {
    return (
      <div className="space-y-6">
        <div>
          <h2 className="text-xl font-semibold">{title}</h2>
          <p className="text-sm text-slate-500">{description}</p>
        </div>
        {filterBar}
        <QueryErrorState
          title={`Failed to load ${title}`}
          message={getErrorMessage(query.error, "Unable to load report data.")}
          onRetry={() => query.refetch()}
        />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div>
        <h2 className="text-xl font-semibold">{title}</h2>
        <p className="text-sm text-slate-500">{description}</p>
      </div>
      {filterBar}
      {children}
    </div>
  );
}
