"use client";

import Link from "next/link";
import { useEffect, useState } from "react";
import {
  DeliveryStatusBadge,
  LaundryStatusBadge,
  PaymentStatusBadge,
  PickupStatusBadge,
} from "@/components/orders/order-badges";
import {
  EmptyState,
  OrderListSkeleton,
  QueryErrorState,
} from "@/components/orders/list-states";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { downloadOrdersExport, useOrders } from "@/hooks/use-orders";
import { getErrorMessage } from "@/lib/errors";
import { exportOrdersExcel } from "@/lib/order-export";
import {
  DELIVERY_STATUSES,
  ORDER_STATUSES,
  PAYMENT_STATUSES,
  PICKUP_STATUSES,
} from "@/lib/order-labels";
import { formatCurrency, formatDate } from "@/lib/utils";
import type { OrderListParams } from "@/types/order";

const PAGE_SIZES = [10, 25, 50, 100] as const;

export default function OrdersPage() {
  const [searchInput, setSearchInput] = useState("");
  const [search, setSearch] = useState("");
  const [status, setStatus] = useState("");
  const [paymentStatus, setPaymentStatus] = useState("");
  const [pickupStatus, setPickupStatus] = useState("");
  const [deliveryStatus, setDeliveryStatus] = useState("");
  const [dateFrom, setDateFrom] = useState("");
  const [dateTo, setDateTo] = useState("");
  const [employeeId, setEmployeeId] = useState("");
  const [page, setPage] = useState(1);
  const [limit, setLimit] = useState<(typeof PAGE_SIZES)[number]>(25);

  useEffect(() => {
    const timer = window.setTimeout(() => {
      setSearch(searchInput.trim());
      setPage(1);
    }, 300);
    return () => window.clearTimeout(timer);
  }, [searchInput]);

  const params: OrderListParams = {
    page,
    limit,
    ...(search ? { search } : {}),
    ...(status ? { status } : {}),
    ...(paymentStatus ? { paymentStatus } : {}),
    ...(pickupStatus ? { pickupStatus } : {}),
    ...(deliveryStatus ? { deliveryStatus } : {}),
    ...(dateFrom ? { dateFrom } : {}),
    ...(dateTo ? { dateTo } : {}),
    ...(employeeId ? { employeeId } : {}),
  };

  const { data, isLoading, isError, error, refetch } = useOrders(params);
  const orders = data?.items ?? [];
  const meta = data?.meta;
  const hasFilters = Boolean(
    search || status || paymentStatus || pickupStatus || deliveryStatus || dateFrom || dateTo || employeeId,
  );

  if (isLoading) return <OrderListSkeleton />;

  if (isError) {
    return (
      <QueryErrorState
        title="Failed to load orders"
        message={getErrorMessage(error, "Unable to fetch orders.")}
        onRetry={() => refetch()}
      />
    );
  }

  return (
    <div className="space-y-4">
      <div className="grid gap-3 xl:grid-cols-4">
        <Input
          className="xl:col-span-2"
          placeholder="Search order, invoice, customer name, or phone"
          value={searchInput}
          onChange={(event) => setSearchInput(event.target.value)}
        />
        <select
          className="h-10 rounded-lg border border-slate-200 bg-white px-3 text-sm dark:border-slate-700 dark:bg-slate-900"
          value={status}
          onChange={(event) => {
            setStatus(event.target.value);
            setPage(1);
          }}
        >
          <option value="">All laundry statuses</option>
          {ORDER_STATUSES.map((item) => (
            <option key={item} value={item}>
              {item.replaceAll("_", " ")}
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
          <option value="">All payment statuses</option>
          {PAYMENT_STATUSES.map((item) => (
            <option key={item} value={item}>
              {item}
            </option>
          ))}
        </select>
        <select
          className="h-10 rounded-lg border border-slate-200 bg-white px-3 text-sm dark:border-slate-700 dark:bg-slate-900"
          value={pickupStatus}
          onChange={(event) => {
            setPickupStatus(event.target.value);
            setPage(1);
          }}
        >
          <option value="">All pickup statuses</option>
          {PICKUP_STATUSES.map((item) => (
            <option key={item} value={item}>
              {item.replaceAll("_", " ")}
            </option>
          ))}
        </select>
        <select
          className="h-10 rounded-lg border border-slate-200 bg-white px-3 text-sm dark:border-slate-700 dark:bg-slate-900"
          value={deliveryStatus}
          onChange={(event) => {
            setDeliveryStatus(event.target.value);
            setPage(1);
          }}
        >
          <option value="">All delivery statuses</option>
          {DELIVERY_STATUSES.map((item) => (
            <option key={item} value={item}>
              {item.replaceAll("_", " ")}
            </option>
          ))}
        </select>
        <Input type="date" value={dateFrom} onChange={(event) => { setDateFrom(event.target.value); setPage(1); }} />
        <Input type="date" value={dateTo} onChange={(event) => { setDateTo(event.target.value); setPage(1); }} />
        <Input
          placeholder="Employee ID filter"
          value={employeeId}
          onChange={(event) => {
            setEmployeeId(event.target.value);
            setPage(1);
          }}
        />
      </div>

      <div className="flex flex-wrap gap-2">
        <Button variant="outline" onClick={() => downloadOrdersExport(params)}>
          Export CSV
        </Button>
        <Button variant="outline" onClick={() => exportOrdersExcel(orders)}>
          Export Excel
        </Button>
      </div>

      {orders.length === 0 ? (
        <EmptyState
          title="No orders found"
          description={
            hasFilters
              ? "Try adjusting your search or filters."
              : "Orders will appear here once created."
          }
        />
      ) : (
        <>
          <div className="overflow-x-auto rounded-xl border border-slate-200 bg-white dark:border-slate-800 dark:bg-slate-900">
            <table className="min-w-full text-sm">
              <thead className="bg-slate-50 dark:bg-slate-900">
                <tr>
                  {[
                    "Order Number",
                    "Customer",
                    "Phone",
                    "Order Date",
                    "Service",
                    "Weight",
                    "Items",
                    "Subtotal",
                    "Discount",
                    "Tax",
                    "Grand Total",
                    "Payment",
                    "Laundry",
                    "Pickup",
                    "Delivery",
                    "Assigned",
                    "Created By",
                    "Action",
                  ].map((header) => (
                    <th key={header} className="px-3 py-3 text-left font-medium text-slate-500">
                      {header}
                    </th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {orders.map((order) => (
                  <tr key={order.id} className="border-t border-slate-100 dark:border-slate-800">
                    <td className="px-3 py-3 font-medium">{order.orderNumber}</td>
                    <td className="px-3 py-3">{order.customerName}</td>
                    <td className="px-3 py-3">{order.customerPhone}</td>
                    <td className="px-3 py-3">{formatDate(order.orderDate)}</td>
                    <td className="px-3 py-3">{order.serviceSummary}</td>
                    <td className="px-3 py-3">{order.totalWeight || "-"}</td>
                    <td className="px-3 py-3">{order.itemCount}</td>
                    <td className="px-3 py-3">{formatCurrency(order.subtotal)}</td>
                    <td className="px-3 py-3">{formatCurrency(order.discount)}</td>
                    <td className="px-3 py-3">{formatCurrency(order.tax)}</td>
                    <td className="px-3 py-3">{formatCurrency(order.grandTotal)}</td>
                    <td className="px-3 py-3">
                      <PaymentStatusBadge status={order.paymentStatus} />
                    </td>
                    <td className="px-3 py-3">
                      <LaundryStatusBadge status={order.orderStatus} />
                    </td>
                    <td className="px-3 py-3">
                      <PickupStatusBadge status={order.pickupStatus} />
                    </td>
                    <td className="px-3 py-3">
                      <DeliveryStatusBadge status={order.deliveryStatus} />
                    </td>
                    <td className="px-3 py-3">
                      {order.assignedEmployee?.fullName ?? "-"}
                    </td>
                    <td className="px-3 py-3">{order.createdBy.fullName}</td>
                    <td className="px-3 py-3">
                      <Link href={`/operations/orders/${order.id}`}>
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
                <Button variant="outline" size="sm" disabled={page <= 1} onClick={() => setPage((current) => current - 1)}>
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
