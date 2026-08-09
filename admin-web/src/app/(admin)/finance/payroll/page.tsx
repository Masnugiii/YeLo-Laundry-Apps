"use client";

import Link from "next/link";
import { useState } from "react";
import {
  EmptyState,
  FinanceListSkeleton,
  QueryErrorState,
} from "@/components/finance/list-states";
import { PayrollKpiCards } from "@/components/payroll/kpi-cards";
import { PayrollStatusBadge } from "@/components/payroll/status-badge";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { ConfirmDialog } from "@/components/ui/confirm-dialog";
import { Input } from "@/components/ui/input";
import { useToast } from "@/components/ui/toast";
import { useEmployees } from "@/hooks/use-employees";
import {
  useApprovePayroll,
  useCalculatePayroll,
  usePayrollDashboard,
  usePayrollRecords,
} from "@/hooks/use-payroll";
import { isOwnerRole } from "@/lib/auth";
import { getErrorMessage } from "@/lib/errors";
import {
  exportRowsCsv,
  exportRowsExcel,
  printFinanceReport,
} from "@/lib/finance-export";
import { formatCurrency, formatDate } from "@/lib/utils";
import type { PayrollListItem, PayrollListParams, PayrollRecordStatus } from "@/types/payroll";

const PAGE_SIZES = [10, 25, 50, 100] as const;
const STATUS_OPTIONS: PayrollRecordStatus[] = ["DRAFT", "CALCULATED", "APPROVED", "PAID"];

export default function PayrollPage() {
  const toast = useToast();
  const [employeeId, setEmployeeId] = useState("");
  const [role, setRole] = useState("");
  const [status, setStatus] = useState("");
  const [periodStart, setPeriodStart] = useState("");
  const [periodEnd, setPeriodEnd] = useState("");
  const [calcStart, setCalcStart] = useState("");
  const [calcEnd, setCalcEnd] = useState("");
  const [page, setPage] = useState(1);
  const [limit, setLimit] = useState<(typeof PAGE_SIZES)[number]>(25);
  const [selectedIds, setSelectedIds] = useState<string[]>([]);
  const [approveOpen, setApproveOpen] = useState(false);

  const dashboardQuery = usePayrollDashboard();
  const employeesQuery = useEmployees({ page: 1, limit: 100, status: "ACTIVE" });
  const calculateMutation = useCalculatePayroll();
  const approveMutation = useApprovePayroll();

  const currentPeriod = dashboardQuery.data?.currentPeriod;
  const effectiveCalcStart = calcStart || currentPeriod?.start || "";
  const effectiveCalcEnd = calcEnd || currentPeriod?.end || "";

  const params: PayrollListParams = {
    page,
    limit,
    ...(employeeId ? { employeeId } : {}),
    ...(role ? { role } : {}),
    ...(status ? { status: status as PayrollRecordStatus } : {}),
    ...(periodStart ? { periodStart } : {}),
    ...(periodEnd ? { periodEnd } : {}),
  };

  const recordsQuery = usePayrollRecords(params);
  const items = recordsQuery.data?.items ?? [];
  const meta = recordsQuery.data?.meta;
  const canApprove = isOwnerRole();

  function toggleSelect(id: string) {
    setSelectedIds((current) =>
      current.includes(id) ? current.filter((value) => value !== id) : [...current, id],
    );
  }

  function toggleSelectAll() {
    const calculatedIds = items
      .filter((item) => item.status === "CALCULATED")
      .map((item) => item.id);
    if (selectedIds.length === calculatedIds.length && calculatedIds.length > 0) {
      setSelectedIds([]);
    } else {
      setSelectedIds(calculatedIds);
    }
  }

  async function handleCalculate() {
    if (!effectiveCalcStart || !effectiveCalcEnd) return;
    try {
      const result = await calculateMutation.mutateAsync({
        periodStart: effectiveCalcStart,
        periodEnd: effectiveCalcEnd,
      });
      toast.success(`Payroll calculated for ${result.length} employee(s).`);
      setSelectedIds([]);
    } catch (error) {
      toast.error(getErrorMessage(error, "Failed to calculate payroll."));
    }
  }

  async function handleApprove() {
    if (!selectedIds.length) return;
    try {
      await approveMutation.mutateAsync({ payrollIds: selectedIds });
      toast.success("Payroll approved successfully.");
      setSelectedIds([]);
      setApproveOpen(false);
    } catch (error) {
      toast.error(getErrorMessage(error, "Failed to approve payroll."));
    }
  }

  function toExportRows(data: PayrollListItem[]) {
    return data.map((item) => ({
      "Payroll Number": item.payrollNumber,
      Employee: item.employeeName,
      "Employee Code": item.employeeCode,
      Role: item.role,
      "Period Start": formatDate(item.periodStart),
      "Period End": formatDate(item.periodEnd),
      "Production Kg": item.productionKg,
      "Production Items": item.productionItems,
      "Attendance Days": item.attendanceDays,
      Bonus: item.bonus,
      Deduction: item.deduction,
      "Gross Salary": item.grossSalary,
      "Net Salary": item.netSalary,
      Status: item.status,
    }));
  }

  if (dashboardQuery.isLoading || recordsQuery.isLoading) {
    return <FinanceListSkeleton />;
  }

  if (dashboardQuery.isError || recordsQuery.isError) {
    return (
      <QueryErrorState
        title="Failed to load payroll"
        message={getErrorMessage(
          dashboardQuery.error ?? recordsQuery.error,
          "Unable to load payroll data.",
        )}
        onRetry={() => {
          dashboardQuery.refetch();
          recordsQuery.refetch();
        }}
      />
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <div>
          <h2 className="text-xl font-semibold">Payroll Dashboard</h2>
          <p className="text-sm text-slate-500">
            Calculate, approve, and pay employee salaries from real production and attendance data.
          </p>
        </div>
        <Link href="/finance/payroll/settings">
          <Button variant="outline">Salary Rules</Button>
        </Link>
      </div>

      {dashboardQuery.data ? <PayrollKpiCards data={dashboardQuery.data} /> : null}

      <Card className="space-y-4 p-6">
        <h3 className="font-semibold">Calculate Payroll</h3>
        <div className="flex flex-wrap items-end gap-3">
          <label className="space-y-1 text-sm">
            <span>Period Start</span>
            <Input
              type="date"
              value={effectiveCalcStart}
              onChange={(e) => setCalcStart(e.target.value)}
            />
          </label>
          <label className="space-y-1 text-sm">
            <span>Period End</span>
            <Input
              type="date"
              value={effectiveCalcEnd}
              onChange={(e) => setCalcEnd(e.target.value)}
            />
          </label>
          <Button
            onClick={handleCalculate}
            disabled={!effectiveCalcStart || !effectiveCalcEnd || calculateMutation.isPending}
          >
            {calculateMutation.isPending ? "Calculating..." : "Calculate Payroll"}
          </Button>
        </div>
      </Card>

      <Card className="space-y-4 p-6">
        <div className="flex flex-wrap items-center justify-between gap-3">
          <h3 className="font-semibold">Payroll Records</h3>
          <div className="flex flex-wrap gap-2">
            {canApprove ? (
              <Button
                variant="outline"
                disabled={!selectedIds.length}
                onClick={() => setApproveOpen(true)}
              >
                Approve Selected ({selectedIds.length})
              </Button>
            ) : null}
            <Button
              variant="outline"
              disabled={!items.length}
              onClick={() => exportRowsCsv("payroll.csv", toExportRows(items))}
            >
              Export CSV
            </Button>
            <Button
              variant="outline"
              disabled={!items.length}
              onClick={() => exportRowsExcel("payroll.xlsx", toExportRows(items))}
            >
              Export Excel
            </Button>
            <Button
              variant="outline"
              disabled={!items.length}
              onClick={() => printFinanceReport("Payroll Report", toExportRows(items))}
            >
              Print / PDF
            </Button>
          </div>
        </div>

        <div className="grid gap-3 md:grid-cols-2 xl:grid-cols-5">
          <select
            className="h-10 rounded-md border border-slate-200 bg-white px-3 text-sm dark:border-slate-800 dark:bg-slate-950"
            value={employeeId}
            onChange={(e) => {
              setEmployeeId(e.target.value);
              setPage(1);
            }}
          >
            <option value="">All Employees</option>
            {(employeesQuery.data?.items ?? []).map((employee) => (
              <option key={employee.id} value={employee.id}>
                {employee.fullName}
              </option>
            ))}
          </select>
          <Input
            placeholder="Filter by role"
            value={role}
            onChange={(e) => {
              setRole(e.target.value);
              setPage(1);
            }}
          />
          <select
            className="h-10 rounded-md border border-slate-200 bg-white px-3 text-sm dark:border-slate-800 dark:bg-slate-950"
            value={status}
            onChange={(e) => {
              setStatus(e.target.value);
              setPage(1);
            }}
          >
            <option value="">All Status</option>
            {STATUS_OPTIONS.map((option) => (
              <option key={option} value={option}>
                {option}
              </option>
            ))}
          </select>
          <Input
            type="date"
            value={periodStart}
            onChange={(e) => {
              setPeriodStart(e.target.value);
              setPage(1);
            }}
          />
          <Input
            type="date"
            value={periodEnd}
            onChange={(e) => {
              setPeriodEnd(e.target.value);
              setPage(1);
            }}
          />
        </div>

        {!items.length ? (
          <EmptyState
            title="No payroll records"
            description="Calculate payroll for a period to generate records from production and attendance data."
          />
        ) : (
          <div className="overflow-x-auto">
            <table className="min-w-full text-sm">
              <thead>
                <tr className="border-b text-left text-slate-500">
                  {canApprove ? (
                    <th className="px-3 py-2">
                      <input
                        type="checkbox"
                        checked={
                          selectedIds.length > 0 &&
                          selectedIds.length ===
                            items.filter((item) => item.status === "CALCULATED").length
                        }
                        onChange={toggleSelectAll}
                      />
                    </th>
                  ) : null}
                  <th className="px-3 py-2">Payroll Number</th>
                  <th className="px-3 py-2">Employee</th>
                  <th className="px-3 py-2">Code</th>
                  <th className="px-3 py-2">Role</th>
                  <th className="px-3 py-2">Period</th>
                  <th className="px-3 py-2">Prod Kg</th>
                  <th className="px-3 py-2">Prod Items</th>
                  <th className="px-3 py-2">Attendance</th>
                  <th className="px-3 py-2">Bonus</th>
                  <th className="px-3 py-2">Deduction</th>
                  <th className="px-3 py-2">Gross</th>
                  <th className="px-3 py-2">Net</th>
                  <th className="px-3 py-2">Status</th>
                  <th className="px-3 py-2">Action</th>
                </tr>
              </thead>
              <tbody>
                {items.map((item) => (
                  <tr key={item.id} className="border-b">
                    {canApprove ? (
                      <td className="px-3 py-2">
                        {item.status === "CALCULATED" ? (
                          <input
                            type="checkbox"
                            checked={selectedIds.includes(item.id)}
                            onChange={() => toggleSelect(item.id)}
                          />
                        ) : null}
                      </td>
                    ) : null}
                    <td className="px-3 py-2 font-medium">{item.payrollNumber}</td>
                    <td className="px-3 py-2">{item.employeeName}</td>
                    <td className="px-3 py-2">{item.employeeCode}</td>
                    <td className="px-3 py-2">{item.role}</td>
                    <td className="px-3 py-2">
                      {formatDate(item.periodStart)} – {formatDate(item.periodEnd)}
                    </td>
                    <td className="px-3 py-2">{item.productionKg}</td>
                    <td className="px-3 py-2">{item.productionItems}</td>
                    <td className="px-3 py-2">{item.attendanceDays}</td>
                    <td className="px-3 py-2">{formatCurrency(item.bonus)}</td>
                    <td className="px-3 py-2">{formatCurrency(item.deduction)}</td>
                    <td className="px-3 py-2">{formatCurrency(item.grossSalary)}</td>
                    <td className="px-3 py-2">{formatCurrency(item.netSalary)}</td>
                    <td className="px-3 py-2">
                      <PayrollStatusBadge status={item.status} />
                    </td>
                    <td className="px-3 py-2">
                      <Link href={`/finance/payroll/${item.id}`}>
                        <Button variant="outline" size="sm">
                          Detail
                        </Button>
                      </Link>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}

        {meta && meta.totalPages > 1 ? (
          <div className="flex flex-wrap items-center justify-between gap-3">
            <p className="text-sm text-slate-500">
              Page {meta.page} of {meta.totalPages} · {meta.total} records
            </p>
            <div className="flex items-center gap-2">
              <select
                className="h-9 rounded-md border border-slate-200 bg-white px-2 text-sm dark:border-slate-800 dark:bg-slate-950"
                value={limit}
                onChange={(e) => {
                  setLimit(Number(e.target.value) as (typeof PAGE_SIZES)[number]);
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
                disabled={page <= 1}
                onClick={() => setPage((current) => current - 1)}
              >
                Previous
              </Button>
              <Button
                variant="outline"
                disabled={page >= meta.totalPages}
                onClick={() => setPage((current) => current + 1)}
              >
                Next
              </Button>
            </div>
          </div>
        ) : null}
      </Card>

      <ConfirmDialog
        open={approveOpen}
        title="Approve Payroll"
        description={`Approve ${selectedIds.length} payroll record(s)? Only OWNER can approve payroll.`}
        confirmLabel="Approve"
        loading={approveMutation.isPending}
        onCancel={() => setApproveOpen(false)}
        onConfirm={handleApprove}
      />
    </div>
  );
}
