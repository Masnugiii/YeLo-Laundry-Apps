"use client";

import Link from "next/link";
import { useEffect, useState } from "react";
import {
  CustomerMemberBadge,
  CustomerStatusBadge,
} from "@/components/customers/customer-badges";
import {
  CustomerListSkeleton,
  EmptyState,
  QueryErrorState,
} from "@/components/customers/list-states";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import {
  downloadCustomersExport,
  useCustomers,
} from "@/hooks/use-customers";
import { getErrorMessage } from "@/lib/errors";
import { exportCustomersExcel } from "@/lib/customer-import";
import { formatCurrency, formatDate } from "@/lib/utils";
import type { CustomerListParams } from "@/types/customer";

const PAGE_SIZES = [10, 25, 50, 100] as const;

export default function CustomersPage() {
  const [searchInput, setSearchInput] = useState("");
  const [search, setSearch] = useState("");
  const [status, setStatus] = useState<"" | "active" | "inactive">("");
  const [member, setMember] = useState<"" | "member" | "regular">("");
  const [dateFrom, setDateFrom] = useState("");
  const [dateTo, setDateTo] = useState("");
  const [sortBy, setSortBy] =
    useState<CustomerListParams["sortBy"]>("createdAt");
  const [sortOrder, setSortOrder] =
    useState<CustomerListParams["sortOrder"]>("desc");
  const [page, setPage] = useState(1);
  const [limit, setLimit] = useState<(typeof PAGE_SIZES)[number]>(25);

  useEffect(() => {
    const timer = window.setTimeout(() => {
      setSearch(searchInput.trim());
      setPage(1);
    }, 300);
    return () => window.clearTimeout(timer);
  }, [searchInput]);

  const params: CustomerListParams = {
    page,
    limit,
    sortBy,
    sortOrder,
    ...(search ? { search } : {}),
    ...(status === "active" ? { isActive: true } : {}),
    ...(status === "inactive" ? { isActive: false } : {}),
    ...(member === "member" ? { isMember: true } : {}),
    ...(member === "regular" ? { isMember: false } : {}),
    ...(dateFrom ? { dateFrom } : {}),
    ...(dateTo ? { dateTo } : {}),
  };

  const { data, isLoading, isError, error, refetch } = useCustomers(params);
  const customers = data?.items ?? [];
  const meta = data?.meta;
  const hasFilters = Boolean(search || status || member || dateFrom || dateTo);

  async function handleExportCsv() {
    await downloadCustomersExport(params);
  }

  function handleExportExcel() {
    exportCustomersExcel(
      customers.map((customer) => ({
        "Customer Code": customer.customerCode,
        "Full Name": customer.fullName,
        Phone: customer.phone,
        Email: customer.email ?? "",
        "Member Status": customer.memberStatus,
        "Total Orders": customer.totalOrders,
        "Total Spending": customer.totalSpending,
        "Last Order": customer.lastOrderAt ?? "",
        Status: customer.isActive ? "ACTIVE" : "INACTIVE",
        "Created Date": customer.createdAt,
      })),
    );
  }

  if (isLoading) return <CustomerListSkeleton />;

  if (isError) {
    return (
      <QueryErrorState
        title="Failed to load customers"
        message={getErrorMessage(error, "Unable to fetch customers.")}
        onRetry={() => refetch()}
      />
    );
  }

  return (
    <div className="space-y-4">
      <div className="flex flex-col gap-3 xl:flex-row xl:items-center xl:justify-between">
        <div className="grid flex-1 gap-3 md:grid-cols-2 xl:grid-cols-3">
          <Input
            placeholder="Search code, name, phone, or email"
            value={searchInput}
            onChange={(event) => setSearchInput(event.target.value)}
          />
          <select
            className="h-10 rounded-lg border border-slate-200 bg-white px-3 text-sm dark:border-slate-700 dark:bg-slate-900"
            value={status}
            onChange={(event) => {
              setStatus(event.target.value as "" | "active" | "inactive");
              setPage(1);
            }}
          >
            <option value="">All statuses</option>
            <option value="active">Active</option>
            <option value="inactive">Inactive</option>
          </select>
          <select
            className="h-10 rounded-lg border border-slate-200 bg-white px-3 text-sm dark:border-slate-700 dark:bg-slate-900"
            value={member}
            onChange={(event) => {
              setMember(event.target.value as "" | "member" | "regular");
              setPage(1);
            }}
          >
            <option value="">All members</option>
            <option value="member">Member</option>
            <option value="regular">Regular</option>
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
          <select
            className="h-10 rounded-lg border border-slate-200 bg-white px-3 text-sm dark:border-slate-700 dark:bg-slate-900"
            value={`${sortBy}:${sortOrder}`}
            onChange={(event) => {
              const [nextSortBy, nextSortOrder] = event.target.value.split(":");
              setSortBy(nextSortBy as CustomerListParams["sortBy"]);
              setSortOrder(nextSortOrder as CustomerListParams["sortOrder"]);
            }}
          >
            <option value="createdAt:desc">Newest first</option>
            <option value="createdAt:asc">Oldest first</option>
            <option value="fullName:asc">Name A-Z</option>
            <option value="fullName:desc">Name Z-A</option>
            <option value="customerCode:asc">Code A-Z</option>
          </select>
        </div>
        <div className="flex flex-wrap gap-2">
          <Link href="/operations/customers/import">
            <Button variant="outline">Import Excel</Button>
          </Link>
          <Button variant="outline" onClick={handleExportCsv}>
            Export CSV
          </Button>
          <Button variant="outline" onClick={handleExportExcel}>
            Export Excel
          </Button>
          <Link href="/operations/customers/new">
            <Button>Add Customer</Button>
          </Link>
        </div>
      </div>

      {customers.length === 0 ? (
        <EmptyState
          title="No customers found"
          description={
            hasFilters
              ? "Try adjusting your search or filters."
              : "Start by adding your first customer."
          }
          action={
            !hasFilters ? (
              <Link href="/operations/customers/new">
                <Button>Add Customer</Button>
              </Link>
            ) : undefined
          }
        />
      ) : (
        <>
          <div className="overflow-x-auto rounded-xl border border-slate-200 bg-white dark:border-slate-800 dark:bg-slate-900">
            <table className="min-w-full text-sm">
              <thead className="bg-slate-50 dark:bg-slate-900">
                <tr>
                  {[
                    "Customer Code",
                    "Full Name",
                    "Phone",
                    "Email",
                    "Member Status",
                    "Total Orders",
                    "Total Spending",
                    "Last Order",
                    "Created Date",
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
              <tbody>
                {customers.map((customer) => (
                  <tr
                    key={customer.id}
                    className="border-t border-slate-100 dark:border-slate-800"
                  >
                    <td className="px-4 py-3 font-medium">{customer.customerCode}</td>
                    <td className="px-4 py-3">{customer.fullName}</td>
                    <td className="px-4 py-3">{customer.phone}</td>
                    <td className="px-4 py-3">{customer.email ?? "-"}</td>
                    <td className="px-4 py-3">
                      <CustomerMemberBadge memberStatus={customer.memberStatus} />
                    </td>
                    <td className="px-4 py-3">{customer.totalOrders}</td>
                    <td className="px-4 py-3">
                      {formatCurrency(customer.totalSpending)}
                    </td>
                    <td className="px-4 py-3 text-slate-500">
                      {customer.lastOrderAt ? formatDate(customer.lastOrderAt) : "-"}
                    </td>
                    <td className="px-4 py-3 text-slate-500">
                      {formatDate(customer.createdAt)}
                    </td>
                    <td className="px-4 py-3">
                      <CustomerStatusBadge isActive={customer.isActive} />
                    </td>
                    <td className="px-4 py-3">
                      <Link href={`/operations/customers/${customer.id}`}>
                        <Button variant="outline" size="sm">
                          View
                        </Button>
                      </Link>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          {meta ? (
            <div className="flex flex-col gap-3 lg:flex-row lg:items-center lg:justify-between">
              <p className="text-sm text-slate-500">
                Showing {(meta.page - 1) * meta.limit + 1}-
                {Math.min(meta.page * meta.limit, meta.total)} of {meta.total}
              </p>
              <div className="flex flex-wrap items-center gap-2">
                <select
                  className="h-8 rounded-lg border border-slate-200 bg-white px-2 text-sm dark:border-slate-700 dark:bg-slate-900"
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
                <span className="text-sm text-slate-500">
                  Page {meta.page} of {meta.totalPages}
                </span>
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
        </>
      )}
    </div>
  );
}
