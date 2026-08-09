"use client";

import { useEffect, useState } from "react";
import { AttendanceDetailDialog } from "@/components/attendance/attendance-detail-dialog";
import {
  EmptyState,
  FinanceListSkeleton,
  QueryErrorState,
} from "@/components/finance/list-states";
import { Button } from "@/components/ui/button";
import { Card, CardTitle, CardValue } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { useAttendance, useAttendanceDashboard } from "@/hooks/use-attendance";
import { useEmployees } from "@/hooks/use-employees";
import { getErrorMessage } from "@/lib/errors";
import { formatDate } from "@/lib/utils";
import type { AttendanceListParams, AttendanceRecord } from "@/types/attendance";

const PAGE_SIZES = [10, 25, 50] as const;
const ATTENDANCE_STATUSES = [
  "PRESENT",
  "LATE",
  "ABSENT",
  "LEAVE",
  "SICK",
  "HALF_DAY",
  "OFF",
];

const DASHBOARD_LABELS: Record<string, string> = {
  presentToday: "Present Today",
  lateToday: "Late Today",
  absentToday: "Absent Today",
  onLeave: "On Leave",
  averageWorkingHours: "Avg Working Hours",
  totalOvertimeMinutes: "Total Overtime (min)",
  attendancePercentage: "Attendance %",
};

export default function AttendancePage() {
  const [searchInput, setSearchInput] = useState("");
  const [search, setSearch] = useState("");
  const [employeeId, setEmployeeId] = useState("");
  const [status, setStatus] = useState("");
  const [dateFrom, setDateFrom] = useState("");
  const [dateTo, setDateTo] = useState("");
  const [page, setPage] = useState(1);
  const [limit, setLimit] = useState<(typeof PAGE_SIZES)[number]>(25);
  const [selectedRecord, setSelectedRecord] = useState<AttendanceRecord | null>(
    null,
  );

  useEffect(() => {
    const timer = window.setTimeout(() => {
      setSearch(searchInput.trim());
      setPage(1);
    }, 300);
    return () => window.clearTimeout(timer);
  }, [searchInput]);

  const params: AttendanceListParams = {
    page,
    limit,
    ...(search ? { search } : {}),
    ...(employeeId ? { employeeId } : {}),
    ...(status ? { status } : {}),
    ...(dateFrom ? { dateFrom } : {}),
    ...(dateTo ? { dateTo } : {}),
  };

  const dashboardQuery = useAttendanceDashboard();
  const listQuery = useAttendance(params);
  const employeesQuery = useEmployees({ page: 1, limit: 100, status: "ACTIVE" });

  const items = listQuery.data?.items ?? [];
  const meta = listQuery.data?.meta;

  if (dashboardQuery.isLoading && listQuery.isLoading) {
    return <FinanceListSkeleton />;
  }

  if (dashboardQuery.isError) {
    return (
      <QueryErrorState
        title="Failed to load attendance dashboard"
        message={getErrorMessage(
          dashboardQuery.error,
          "Unable to fetch attendance metrics.",
        )}
        onRetry={() => dashboardQuery.refetch()}
      />
    );
  }

  return (
    <div className="space-y-6">
      <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
        {dashboardQuery.data
          ? Object.entries(dashboardQuery.data).map(([key, value]) => (
              <Card key={key}>
                <CardTitle>{DASHBOARD_LABELS[key] ?? key}</CardTitle>
                <CardValue>
                  {key === "attendancePercentage"
                    ? `${value}%`
                    : key === "averageWorkingHours"
                      ? Number(value).toFixed(1)
                      : String(value)}
                </CardValue>
              </Card>
            ))
          : null}
      </div>

      <div className="grid gap-3 xl:grid-cols-4">
        <Input
          className="xl:col-span-2"
          placeholder="Search employee name or code"
          value={searchInput}
          onChange={(event) => setSearchInput(event.target.value)}
        />
        <select
          className="h-10 rounded-lg border border-slate-200 bg-white px-3 text-sm dark:border-slate-700 dark:bg-slate-900"
          value={employeeId}
          onChange={(event) => {
            setEmployeeId(event.target.value);
            setPage(1);
          }}
        >
          <option value="">All employees</option>
          {(employeesQuery.data?.items ?? []).map((employee) => (
            <option key={employee.id} value={employee.id}>
              {employee.fullName}
            </option>
          ))}
        </select>
        <select
          className="h-10 rounded-lg border border-slate-200 bg-white px-3 text-sm dark:border-slate-700 dark:bg-slate-900"
          value={status}
          onChange={(event) => {
            setStatus(event.target.value);
            setPage(1);
          }}
        >
          <option value="">All statuses</option>
          {ATTENDANCE_STATUSES.map((item) => (
            <option key={item} value={item}>
              {item}
            </option>
          ))}
        </select>
        <Input
          type="date"
          value={dateFrom}
          onChange={(event) => {
            setDateFrom(event.target.value);
            setPage(1);
          }}
        />
        <Input
          type="date"
          value={dateTo}
          onChange={(event) => {
            setDateTo(event.target.value);
            setPage(1);
          }}
        />
      </div>

      {listQuery.isLoading ? (
        <FinanceListSkeleton />
      ) : listQuery.isError ? (
        <QueryErrorState
          title="Failed to load attendance records"
          message={getErrorMessage(
            listQuery.error,
            "Unable to fetch attendance records.",
          )}
          onRetry={() => listQuery.refetch()}
        />
      ) : items.length === 0 ? (
        <EmptyState
          title="No attendance records found"
          description="Attendance records appear when employees check in and out."
        />
      ) : (
        <div className="overflow-x-auto rounded-xl border border-slate-200 dark:border-slate-800">
          <table className="min-w-full divide-y divide-slate-200 text-sm dark:divide-slate-800">
            <thead className="bg-slate-50 dark:bg-slate-900/50">
              <tr>
                {[
                  "Employee",
                  "Date",
                  "Check In",
                  "Check Out",
                  "Working Hours",
                  "Late (min)",
                  "Overtime (min)",
                  "Status",
                  "Action",
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
              {items.map((item) => (
                <tr key={item.id}>
                  <td className="px-4 py-3">
                    <div>{item.employee.fullName}</div>
                    <div className="text-xs text-slate-500">
                      {item.employee.employeeCode}
                    </div>
                  </td>
                  <td className="px-4 py-3">
                    {formatDate(item.attendanceDate).split(",")[0]}
                  </td>
                  <td className="px-4 py-3">
                    {item.checkIn ? formatDate(item.checkIn) : "—"}
                  </td>
                  <td className="px-4 py-3">
                    {item.checkOut ? formatDate(item.checkOut) : "—"}
                  </td>
                  <td className="px-4 py-3">{item.workingHours}h</td>
                  <td className="px-4 py-3">{item.lateMinutes}</td>
                  <td className="px-4 py-3">{item.overtimeMinutes}</td>
                  <td className="px-4 py-3">{item.displayStatus}</td>
                  <td className="px-4 py-3">
                    <Button
                      variant="outline"
                      size="sm"
                      onClick={() => setSelectedRecord(item)}
                    >
                      View
                    </Button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {meta ? (
        <div className="flex flex-wrap items-center justify-between gap-3">
          <p className="text-sm text-slate-500">
            Page {meta.page} of {meta.totalPages} ({meta.total} records)
          </p>
          <div className="flex flex-wrap items-center gap-2">
            <select
              className="h-9 rounded-lg border border-slate-200 bg-white px-3 text-sm dark:border-slate-700 dark:bg-slate-900"
              value={limit}
              onChange={(event) => {
                setLimit(Number(event.target.value) as (typeof PAGE_SIZES)[number]);
                setPage(1);
              }}
            >
              {PAGE_SIZES.map((size) => (
                <option key={size} value={size}>
                  {size} / page
                </option>
              ))}
            </select>
            <Button
              variant="outline"
              size="sm"
              disabled={page <= 1}
              onClick={() => setPage((current) => current - 1)}
            >
              Previous
            </Button>
            <Button
              variant="outline"
              size="sm"
              disabled={page >= meta.totalPages}
              onClick={() => setPage((current) => current + 1)}
            >
              Next
            </Button>
          </div>
        </div>
      ) : null}

      {selectedRecord ? (
        <AttendanceDetailDialog
          record={selectedRecord}
          onClose={() => setSelectedRecord(null)}
        />
      ) : null}
    </div>
  );
}
