"use client";

import Link from "next/link";
import { useState } from "react";
import {
  EmptyState,
  FinanceListSkeleton,
  QueryErrorState,
} from "@/components/finance/list-states";
import { Button } from "@/components/ui/button";
import { Card, CardTitle, CardValue } from "@/components/ui/card";
import { ConfirmDialog } from "@/components/ui/confirm-dialog";
import { Input } from "@/components/ui/input";
import { useToast } from "@/components/ui/toast";
import {
  useWalletDashboard,
  useWalletHistory,
  useWalletTopup,
} from "@/hooks/use-loyalty";
import { useCustomers } from "@/hooks/use-customers";
import { isOwnerRole } from "@/lib/auth";
import { getErrorMessage } from "@/lib/errors";
import {
  exportRowsCsv,
  exportRowsExcel,
  printFinanceReport,
} from "@/lib/finance-export";
import { formatCurrency, formatDate } from "@/lib/utils";

export default function CustomerWalletPage() {
  const toast = useToast();
  const [customerId, setCustomerId] = useState("");
  const [page, setPage] = useState(1);
  const [topupOpen, setTopupOpen] = useState(false);
  const [topupAmount, setTopupAmount] = useState(0);
  const [topupNotes, setTopupNotes] = useState("");

  const dashboardQuery = useWalletDashboard();
  const historyQuery = useWalletHistory({ page, limit: 25, customerId: customerId || undefined });
  const customersQuery = useCustomers({ page: 1, limit: 100, isActive: true });
  const topupMutation = useWalletTopup();

  const items = historyQuery.data?.items ?? [];
  const meta = historyQuery.data?.meta;
  const canAdjust = isOwnerRole();

  async function handleTopup() {
    if (!customerId || topupAmount <= 0) return;
    try {
      await topupMutation.mutateAsync({
        customerId,
        amount: topupAmount,
        notes: topupNotes || undefined,
      });
      toast.success("Wallet top-up successful.");
      setTopupOpen(false);
      setTopupAmount(0);
      setTopupNotes("");
    } catch (error) {
      toast.error(getErrorMessage(error, "Failed to top up wallet."));
    }
  }

  function toExportRows() {
    return items.map((item) => ({
      Date: formatDate(item.createdAt),
      Reference: item.referenceNumber ?? "-",
      Type: item.type,
      Description: item.notes ?? "-",
      Amount: item.amount,
      "Balance After": item.balanceAfter ?? "-",
      "Created By": item.createdByEmployee?.fullName ?? "-",
    }));
  }

  if (dashboardQuery.isLoading || historyQuery.isLoading) {
    return <FinanceListSkeleton />;
  }

  if (dashboardQuery.isError || historyQuery.isError) {
    return (
      <QueryErrorState
        title="Failed to load wallet"
        message={getErrorMessage(
          dashboardQuery.error ?? historyQuery.error,
          "Unable to load wallet data.",
        )}
        onRetry={() => {
          dashboardQuery.refetch();
          historyQuery.refetch();
        }}
      />
    );
  }

  const dashboard = dashboardQuery.data;

  return (
    <div className="space-y-6">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <div>
          <h2 className="text-xl font-semibold">Yelo Wallet</h2>
          <p className="text-sm text-slate-500">
            Customer prepaid wallet balances, top-ups, and transaction history.
          </p>
        </div>
        <div className="flex gap-2">
          <Link href="/settings/loyalty">
            <Button variant="outline">Loyalty Settings</Button>
          </Link>
          <Button onClick={() => setTopupOpen(true)} disabled={!customerId}>
            Top Up
          </Button>
        </div>
      </div>

      {dashboard ? (
        <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-5">
          {[
            { title: "Active Wallets", value: String(dashboard.walletCount) },
            { title: "Current Balance", value: formatCurrency(dashboard.currentBalance) },
            { title: "Total Top Up", value: formatCurrency(dashboard.totalTopup) },
            { title: "Total Spending", value: formatCurrency(dashboard.totalSpending) },
            { title: "Total Refund", value: formatCurrency(dashboard.totalRefund) },
          ].map((metric) => (
            <Card key={metric.title}>
              <CardTitle>{metric.title}</CardTitle>
              <CardValue className="text-lg">{metric.value}</CardValue>
            </Card>
          ))}
        </div>
      ) : null}

      <Card className="space-y-4 p-6">
        <div className="flex flex-wrap items-center justify-between gap-3">
          <h3 className="font-semibold">Wallet History</h3>
          <div className="flex flex-wrap gap-2">
            <Button
              variant="outline"
              disabled={!items.length}
              onClick={() => exportRowsCsv("wallet-history.csv", toExportRows())}
            >
              CSV
            </Button>
            <Button
              variant="outline"
              disabled={!items.length}
              onClick={() => exportRowsExcel("wallet-history.xlsx", toExportRows())}
            >
              Excel
            </Button>
            <Button
              variant="outline"
              disabled={!items.length}
              onClick={() => printFinanceReport("Wallet History", toExportRows())}
            >
              Print / PDF
            </Button>
          </div>
        </div>

        <select
          className="h-10 w-full max-w-md rounded-md border border-slate-200 bg-white px-3 text-sm dark:border-slate-800 dark:bg-slate-950"
          value={customerId}
          onChange={(e) => {
            setCustomerId(e.target.value);
            setPage(1);
          }}
        >
          <option value="">All Customers</option>
          {(customersQuery.data?.items ?? []).map((customer) => (
            <option key={customer.id} value={customer.id}>
              {customer.fullName} ({customer.customerCode})
            </option>
          ))}
        </select>

        {!items.length ? (
          <EmptyState
            title="No wallet transactions"
            description="Top up a customer wallet or complete orders paid with wallet to see history."
          />
        ) : (
          <div className="overflow-x-auto">
            <table className="min-w-full text-sm">
              <thead>
                <tr className="border-b text-left text-slate-500">
                  <th className="px-3 py-2">Date</th>
                  <th className="px-3 py-2">Reference</th>
                  <th className="px-3 py-2">Type</th>
                  <th className="px-3 py-2">Description</th>
                  <th className="px-3 py-2">Amount</th>
                  <th className="px-3 py-2">Balance After</th>
                  <th className="px-3 py-2">Created By</th>
                </tr>
              </thead>
              <tbody>
                {items.map((item) => (
                  <tr key={item.id} className="border-b">
                    <td className="px-3 py-2">{formatDate(item.createdAt)}</td>
                    <td className="px-3 py-2">{item.referenceNumber ?? "-"}</td>
                    <td className="px-3 py-2">{item.type}</td>
                    <td className="px-3 py-2">{item.notes ?? "-"}</td>
                    <td className="px-3 py-2">{formatCurrency(item.amount)}</td>
                    <td className="px-3 py-2">
                      {item.balanceAfter !== null
                        ? formatCurrency(item.balanceAfter)
                        : "-"}
                    </td>
                    <td className="px-3 py-2">
                      {item.createdByEmployee?.fullName ?? "-"}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}

        {meta && meta.totalPages > 1 ? (
          <div className="flex items-center justify-between">
            <p className="text-sm text-slate-500">
              Page {meta.page} of {meta.totalPages}
            </p>
            <div className="flex gap-2">
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
        open={topupOpen}
        title="Top Up Wallet"
        description="Credit the selected customer wallet. Cashflow income will be recorded."
        confirmLabel="Top Up"
        loading={topupMutation.isPending}
        onCancel={() => setTopupOpen(false)}
        onConfirm={handleTopup}
      />

      {topupOpen ? (
        <Card className="space-y-3 p-6">
          <h3 className="font-semibold">Top Up Details</h3>
          <Input
            type="number"
            placeholder="Amount"
            value={topupAmount || ""}
            onChange={(e) => setTopupAmount(Number(e.target.value))}
          />
          <Input
            placeholder="Notes"
            value={topupNotes}
            onChange={(e) => setTopupNotes(e.target.value)}
          />
          {!canAdjust ? (
            <p className="text-xs text-slate-500">
              Manual balance adjustment is available for OWNER only.
            </p>
          ) : null}
        </Card>
      ) : null}
    </div>
  );
}
