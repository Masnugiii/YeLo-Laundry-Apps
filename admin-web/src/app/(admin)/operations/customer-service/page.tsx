"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import { useEffect, useState } from "react";
import {
  CustomerServiceCategoryBadge,
  CustomerServiceStatusBadge,
  CustomerServiceUnreadBadge,
} from "@/components/customer-service/customer-service-badges";
import {
  CustomerServiceListSkeleton,
  EmptyState,
  QueryErrorState,
} from "@/components/customer-service/list-states";
import { Button } from "@/components/ui/button";
import { Card, CardTitle, CardValue } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import {
  useCustomerServiceSummary,
  useCustomerServiceTickets,
} from "@/hooks/use-customer-service";
import { getErrorMessage } from "@/lib/errors";
import { formatDate } from "@/lib/utils";
import type {
  CustomerServiceCategory,
  CustomerServiceListParams,
  CustomerServiceStatus,
} from "@/types/customer-service";

const PAGE_SIZES = [10, 25, 50] as const;
const CATEGORIES: Array<{ value: CustomerServiceCategory | ""; label: string }> =
  [
    { value: "", label: "All categories" },
    { value: "ORDER_BARU", label: "Order Baru" },
    { value: "KOMPLAIN", label: "Komplain" },
    { value: "PERTANYAAN", label: "Pertanyaan" },
    { value: "PROMO", label: "Promo" },
    { value: "TRACKING_ORDER", label: "Tracking Order" },
    { value: "LAINNYA", label: "Lainnya" },
  ];

const STATUSES: Array<{ value: CustomerServiceStatus | ""; label: string }> = [
  { value: "", label: "All statuses" },
  { value: "OPEN", label: "Open" },
  { value: "IN_PROGRESS", label: "In Progress" },
  { value: "WAITING_CUSTOMER", label: "Waiting Customer" },
  { value: "RESOLVED", label: "Resolved" },
  { value: "CLOSED", label: "Closed" },
];

const selectClassName =
  "h-10 rounded-lg border border-slate-200 bg-white px-3 text-sm outline-none ring-blue-500 focus:ring-2 dark:border-slate-700 dark:bg-slate-900";

export default function CustomerServicePage() {
  const router = useRouter();
  const [searchInput, setSearchInput] = useState("");
  const [search, setSearch] = useState("");
  const [category, setCategory] = useState<CustomerServiceCategory | "">("");
  const [status, setStatus] = useState<CustomerServiceStatus | "">("");
  const [page, setPage] = useState(1);
  const [limit, setLimit] = useState<(typeof PAGE_SIZES)[number]>(25);

  useEffect(() => {
    const timer = window.setTimeout(() => {
      setSearch(searchInput.trim());
      setPage(1);
    }, 300);
    return () => window.clearTimeout(timer);
  }, [searchInput]);

  const params: CustomerServiceListParams = {
    page,
    limit,
    ...(search ? { search } : {}),
    ...(category ? { category } : {}),
    ...(status ? { status } : {}),
  };

  const summaryQuery = useCustomerServiceSummary();
  const listQuery = useCustomerServiceTickets(params);

  const items = listQuery.data?.items ?? [];
  const meta = listQuery.data?.meta;
  const summary = summaryQuery.data;
  const hasFilters = Boolean(search || category || status);

  if (summaryQuery.isLoading && listQuery.isLoading) {
    return <CustomerServiceListSkeleton />;
  }

  return (
    <div className="space-y-4">
      {summary ? (
        <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
          <Card>
            <CardTitle>Unread</CardTitle>
            <CardValue>{summary.unreadMessages}</CardValue>
          </Card>
          <Card>
            <CardTitle>New Complaints</CardTitle>
            <CardValue>{summary.newComplaints}</CardValue>
          </Card>
          <Card>
            <CardTitle>Order Questions</CardTitle>
            <CardValue>{summary.orderQuestions}</CardValue>
          </Card>
          <Card>
            <CardTitle>Completed</CardTitle>
            <CardValue>{summary.completed}</CardValue>
          </Card>
        </div>
      ) : summaryQuery.isError ? (
        <QueryErrorState
          title="Failed to load summary"
          message={getErrorMessage(
            summaryQuery.error,
            "Unable to fetch customer service summary.",
          )}
          onRetry={() => void summaryQuery.refetch()}
        />
      ) : null}

      <div className="grid gap-3 md:grid-cols-4">
        <Input
          className="md:col-span-2"
          placeholder="Search customer, phone, or subject..."
          value={searchInput}
          onChange={(event) => setSearchInput(event.target.value)}
        />
        <select
          className={selectClassName}
          value={category}
          onChange={(event) => {
            setCategory(event.target.value as CustomerServiceCategory | "");
            setPage(1);
          }}
        >
          {CATEGORIES.map((item) => (
            <option key={item.label} value={item.value}>
              {item.label}
            </option>
          ))}
        </select>
        <select
          className={selectClassName}
          value={status}
          onChange={(event) => {
            setStatus(event.target.value as CustomerServiceStatus | "");
            setPage(1);
          }}
        >
          {STATUSES.map((item) => (
            <option key={item.label} value={item.value}>
              {item.label}
            </option>
          ))}
        </select>
      </div>

      {listQuery.isLoading ? (
        <CustomerServiceListSkeleton />
      ) : listQuery.isError ? (
        <QueryErrorState
          title="Failed to load tickets"
          message={getErrorMessage(
            listQuery.error,
            "Unable to fetch customer service tickets.",
          )}
          onRetry={() => void listQuery.refetch()}
        />
      ) : items.length === 0 ? (
        <EmptyState
          title="No conversations"
          description={
            hasFilters
              ? "No tickets match the current filters."
              : "Customer service tickets will appear here."
          }
        />
      ) : (
        <>
          <div className="hidden overflow-hidden rounded-xl border border-slate-200 bg-white dark:border-slate-800 dark:bg-slate-900 md:block">
            <table className="min-w-full text-sm">
              <thead className="bg-slate-50 text-left text-xs font-semibold uppercase tracking-wide text-slate-500 dark:bg-slate-900/60">
                <tr>
                  <th className="px-4 py-3">Customer</th>
                  <th className="px-4 py-3">Phone</th>
                  <th className="px-4 py-3">Category</th>
                  <th className="px-4 py-3">Preview</th>
                  <th className="px-4 py-3">Status</th>
                  <th className="px-4 py-3">Unread</th>
                  <th className="px-4 py-3">Updated</th>
                  <th className="px-4 py-3">Action</th>
                </tr>
              </thead>
              <tbody>
                {items.map((item) => (
                  <tr
                    key={item.id}
                    className="border-t border-slate-100 dark:border-slate-800"
                  >
                    <td className="px-4 py-3 font-medium">{item.customerName}</td>
                    <td className="px-4 py-3">{item.whatsappNumber}</td>
                    <td className="px-4 py-3">
                      <CustomerServiceCategoryBadge category={item.category} />
                    </td>
                    <td className="max-w-xs truncate px-4 py-3">
                      {item.messagePreview}
                    </td>
                    <td className="px-4 py-3">
                      <CustomerServiceStatusBadge status={item.status} />
                    </td>
                    <td className="px-4 py-3">
                      <CustomerServiceUnreadBadge isUnread={item.isUnread} />
                    </td>
                    <td className="px-4 py-3">{formatDate(item.messageTime)}</td>
                    <td className="px-4 py-3">
                      <Button
                        size="sm"
                        variant="outline"
                        onClick={() =>
                          router.push(`/operations/customer-service/${item.id}`)
                        }
                      >
                        View
                      </Button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          <div className="grid gap-3 md:hidden">
            {items.map((item) => (
              <Card key={item.id} className="p-4">
                <div className="flex items-start justify-between gap-3">
                  <div>
                    <p className="font-semibold">{item.customerName}</p>
                    <p className="text-sm text-slate-500">{item.whatsappNumber}</p>
                  </div>
                  <CustomerServiceUnreadBadge isUnread={item.isUnread} />
                </div>
                <div className="mt-3 flex flex-wrap gap-2">
                  <CustomerServiceCategoryBadge category={item.category} />
                  <CustomerServiceStatusBadge status={item.status} />
                </div>
                <p className="mt-3 line-clamp-2 text-sm text-slate-600 dark:text-slate-300">
                  {item.messagePreview}
                </p>
                <div className="mt-4 flex items-center justify-between">
                  <span className="text-xs text-slate-500">
                    {formatDate(item.messageTime)}
                  </span>
                  <Button
                    size="sm"
                    variant="outline"
                    onClick={() =>
                      router.push(`/operations/customer-service/${item.id}`)
                    }
                  >
                    View
                  </Button>
                </div>
              </Card>
            ))}
          </div>
        </>
      )}

      {meta ? (
        <div className="flex flex-wrap items-center justify-between gap-3">
          <p className="text-sm text-slate-500">
            Page {meta.page} of {meta.totalPages} ({meta.total} tickets)
          </p>
          <div className="flex items-center gap-2">
            <select
              className={selectClassName}
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
    </div>
  );
}
