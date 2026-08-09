"use client";

import Link from "next/link";
import { useEffect, useState } from "react";
import {
  EmptyState,
  FinanceListSkeleton,
  QueryErrorState,
} from "@/components/finance/list-states";
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
} from "@/types/customer-service";

const PAGE_SIZES = [10, 25, 50] as const;
const CATEGORIES: Array<{ value: CustomerServiceCategory | ""; label: string }> =
  [
    { value: "", label: "All Categories" },
    { value: "ORDER_BARU", label: "Order Baru" },
    { value: "KOMPLAIN", label: "Komplain" },
    { value: "PERTANYAAN", label: "Pertanyaan" },
    { value: "PROMO", label: "Promo" },
    { value: "TRACKING_ORDER", label: "Tracking Order" },
    { value: "LAINNYA", label: "Lainnya" },
  ];

export default function CustomerServicePage() {
  const [searchInput, setSearchInput] = useState("");
  const [search, setSearch] = useState("");
  const [category, setCategory] = useState<CustomerServiceCategory | "">("");
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
  };

  const summaryQuery = useCustomerServiceSummary();
  const listQuery = useCustomerServiceTickets(params);

  const items = listQuery.data?.items ?? [];
  const meta = listQuery.data?.meta;
  const summary = summaryQuery.data;

  if (summaryQuery.isLoading && listQuery.isLoading) {
    return <FinanceListSkeleton />;
  }

  if (summaryQuery.isError || listQuery.isError) {
    return (
      <QueryErrorState
        title="Failed to load customer service"
        message={getErrorMessage(
          summaryQuery.error ?? listQuery.error,
          "Unable to fetch customer service tickets.",
        )}
        onRetry={() => {
          void summaryQuery.refetch();
          void listQuery.refetch();
        }}
      />
    );
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-semibold">Customer Service</h1>
        <p className="text-sm text-muted-foreground">
          Conversation list and ticket management.
        </p>
      </div>

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
      ) : null}

      <div className="flex flex-wrap gap-3">
        <Input
          className="max-w-sm"
          placeholder="Search customer, phone, or subject..."
          value={searchInput}
          onChange={(event) => setSearchInput(event.target.value)}
        />
        <select
          className="h-10 rounded-md border border-input bg-background px-3 text-sm"
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
      </div>

      {listQuery.isLoading ? (
        <FinanceListSkeleton />
      ) : items.length === 0 ? (
        <EmptyState
          title="No conversations"
          description="Customer service tickets will appear here."
        />
      ) : (
        <div className="overflow-x-auto rounded-lg border">
          <table className="min-w-full text-sm">
            <thead className="bg-muted/50 text-left">
              <tr>
                <th className="px-4 py-3">Customer</th>
                <th className="px-4 py-3">Phone</th>
                <th className="px-4 py-3">Category</th>
                <th className="px-4 py-3">Preview</th>
                <th className="px-4 py-3">Status</th>
                <th className="px-4 py-3">Updated</th>
                <th className="px-4 py-3">Action</th>
              </tr>
            </thead>
            <tbody>
              {items.map((item) => (
                <tr key={item.id} className="border-t">
                  <td className="px-4 py-3 font-medium">{item.customerName}</td>
                  <td className="px-4 py-3">{item.whatsappNumber}</td>
                  <td className="px-4 py-3">{item.category}</td>
                  <td className="px-4 py-3 max-w-xs truncate">
                    {item.messagePreview}
                  </td>
                  <td className="px-4 py-3">{item.status}</td>
                  <td className="px-4 py-3">{formatDate(item.messageTime)}</td>
                  <td className="px-4 py-3">
                    <Link
                      href={`/operations/customer-service/${item.id}`}
                      className="inline-flex h-8 items-center rounded-md border border-input px-3 text-sm hover:bg-muted"
                    >
                      View
                    </Link>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {meta ? (
        <div className="flex flex-wrap items-center justify-between gap-3">
          <p className="text-sm text-muted-foreground">
            Page {meta.page} of {meta.totalPages} ({meta.total} tickets)
          </p>
          <div className="flex items-center gap-2">
            <select
              className="h-9 rounded-md border border-input bg-background px-2 text-sm"
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
