"use client";

import { useEffect, useState } from "react";
import {
  EmptyState,
  FinanceListSkeleton,
  QueryErrorState,
} from "@/components/finance/list-states";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { useEmployees } from "@/hooks/use-employees";
import { useRevenue } from "@/hooks/use-finance";
import { getErrorMessage } from "@/lib/errors";
import {
  exportRowsCsv,
  exportRowsExcel,
  printFinanceReport,
} from "@/lib/finance-export";
import { formatCurrency, formatDate } from "@/lib/utils";
import type { RevenueListParams } from "@/types/finance";

const PAGE_SIZES = [10, 25, 50, 100] as const;
const PAYMENT_METHODS = [
  "CASH",
  "QRIS",
  "BANK_TRANSFER",
  "DEBIT_CARD",
  "CREDIT_CARD",
  "EWALLET",
  "CUSTOMER_WALLET",
];
const PAYMENT_STATUSES = ["PENDING", "PAID", "FAILED", "REFUNDED", "CANCELLED"];

export default function RevenuePage() {
  const [searchInput, setSearchInput] = useState("");
  const [search, setSearch] = useState("");
  const [paymentMethod, setPaymentMethod] = useState("");
  const [paymentStatus, setPaymentStatus] = useState("");
  const [employeeId, setEmployeeId] = useState("");
  const [dateFrom, setDateFrom] = useState("");
  const [dateTo, setDateTo] = useState("");
  const [page, setPage] = useState(1);
  const [limit, setLimit] = useState<(typeof PAGE_SIZES)[number]>(25);

  useEffect(() => {
    const timer = window.setTimeout(() => {
      setSearch(searchInput.trim());
      setPage(1);
    }, 300);
    return () => window.clearTimeout(timer);
  }, [searchInput]);

  const params: RevenueListParams = {
    page,
    limit,
    ...(search ? { search } : {}),
    ...(paymentMethod ? { paymentMethod } : {}),
    ...(paymentStatus ? { paymentStatus } : {}),
    ...(employeeId ? { employeeId } : {}),
    ...(dateFrom ? { dateFrom } : {}),
    ...(dateTo ? { dateTo } : {}),
  };

  const { data, isLoading, isError, error, refetch } = useRevenue(params);
  const employeesQuery = useEmployees({ page: 1, limit: 100, status: "ACTIVE" });
  const items = data?.items ?? [];
  const meta = data?.meta;

  const exportRows = items.map((item) => ({
    Invoice: item.invoice,
    "Order Number": item.orderNumber,
    Customer: item.customerName,
    "Payment Method": item.paymentMethod,
    Amount: item.amount,
    "Paid Date": formatDate(item.paidDate),
    Cashier: item.cashier,
    Status: item.status,
  }));

  if (isLoading) return <FinanceListSkeleton />;

  if (isError) {
    return (
      <QueryErrorState
        title="Failed to load revenue"
        message={getErrorMessage(error, "Unable to fetch revenue records.")}
        onRetry={() => refetch()}
      />
    );
  }

  return (
    <div className="space-y-4">
      <div className="flex flex-wrap gap-2">
        <Button variant="outline" onClick={() => exportRowsCsv("revenue.csv", exportRows)}>
          Export CSV
        </Button>
        <Button variant="outline" onClick={() => exportRowsExcel("revenue.xlsx", exportRows)}>
          Export Excel
        </Button>
        <Button variant="outline" onClick={() => printFinanceReport("Revenue Report", exportRows)}>
          Print / PDF
        </Button>
      </div>

      <div className="grid gap-3 xl:grid-cols-4">
        <Input
          className="xl:col-span-2"
          placeholder="Search invoice, order, customer, or phone"
          value={searchInput}
          onChange={(event) => setSearchInput(event.target.value)}
        />
        <select
          className="h-10 rounded-lg border border-slate-200 bg-white px-3 text-sm dark:border-slate-700 dark:bg-slate-900"
          value={paymentMethod}
          onChange={(event) => {
            setPaymentMethod(event.target.value);
            setPage(1);
          }}
        >
          <option value="">All payment methods</option>
          {PAYMENT_METHODS.map((method) => (
            <option key={method} value={method}>
              {method}
            </option>
          ))}
        </select>
        <select
          className="h-10 rounded-lg border border-slate-200 bg-white px-3 text-sm dark:border-slate-700 dark:bg-slate-900"
          value={paymentStatus}
          onChange={(event) => {
            setPaymentStatus(event.target.value);
            setPage(1);
          }}
        >
          <option value="">All statuses</option>
          {PAYMENT_STATUSES.map((status) => (
            <option key={status} value={status}>
              {status}
            </option>
          ))}
        </select>
        <select
          className="h-10 rounded-lg border border-slate-200 bg-white px-3 text-sm dark:border-slate-700 dark:bg-slate-900"
          value={employeeId}
          onChange={(event) => {
            setEmployeeId(event.target.value);
            setPage(1);
          }}
        >
          <option value="">All cashiers</option>
          {(employeesQuery.data?.items ?? []).map((employee) => (
            <option key={employee.id} value={employee.id}>
              {employee.fullName}
            </option>
          ))}
        </select>
        <Input type="date" value={dateFrom} onChange={(e) => { setDateFrom(e.target.value); setPage(1); }} />
        <Input type="date" value={dateTo} onChange={(e) => { setDateTo(e.target.value); setPage(1); }} />
      </div>

      {items.length === 0 ? (
        <EmptyState
          title="No revenue records found"
          description="Revenue appears when payments are recorded against orders."
        />
      ) : (
        <div className="overflow-x-auto rounded-xl border border-slate-200 dark:border-slate-800">
          <table className="min-w-full divide-y divide-slate-200 text-sm dark:divide-slate-800">
            <thead className="bg-slate-50 dark:bg-slate-900/50">
              <tr>
                {["Invoice", "Order Number", "Customer", "Payment Method", "Amount", "Paid Date", "Cashier", "Status"].map((header) => (
                  <th key={header} className="px-4 py-3 text-left font-medium text-slate-500">{header}</th>
                ))}
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-200 bg-white dark:divide-slate-800 dark:bg-slate-950">
              {items.map((item) => (
                <tr key={item.id}>
                  <td className="px-4 py-3">{item.invoice}</td>
                  <td className="px-4 py-3">{item.orderNumber}</td>
                  <td className="px-4 py-3">
                    <div>{item.customerName}</div>
                    <div className="text-xs text-slate-500">{item.customerPhone}</div>
                  </td>
                  <td className="px-4 py-3">{item.paymentMethod}</td>
                  <td className="px-4 py-3">{formatCurrency(item.amount)}</td>
                  <td className="px-4 py-3">{formatDate(item.paidDate)}</td>
                  <td className="px-4 py-3">{item.cashier}</td>
                  <td className="px-4 py-3">{item.status}</td>
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
                <option key={size} value={size}>{size} / page</option>
              ))}
            </select>
            <Button variant="outline" size="sm" disabled={page <= 1} onClick={() => setPage((p) => p - 1)}>Previous</Button>
            <Button variant="outline" size="sm" disabled={page >= meta.totalPages} onClick={() => setPage((p) => p + 1)}>Next</Button>
          </div>
        </div>
      ) : null}
    </div>
  );
}
