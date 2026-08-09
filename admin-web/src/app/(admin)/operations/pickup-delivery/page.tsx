"use client";

import { useQuery } from "@tanstack/react-query";
import { useState } from "react";
import {
  EmptyState,
  FinanceListSkeleton,
  QueryErrorState,
} from "@/components/finance/list-states";
import { Button } from "@/components/ui/button";
import { Card, CardTitle, CardValue } from "@/components/ui/card";
import { apiGet } from "@/lib/api";
import { getErrorMessage } from "@/lib/errors";
import { formatDate } from "@/lib/utils";
import type { Paginated } from "@/types/api";
import type {
  JobDetail,
  JobListParams,
  PickupDeliveryDashboard,
} from "@/types/pickup-delivery";

const DASHBOARD_LABELS: Record<string, string> = {
  pickupRequested: "Pickup Requested",
  driverAssigned: "Driver Assigned",
  onTheWay: "On The Way",
  readyForDelivery: "Ready for Delivery",
  deliveredToday: "Delivered Today",
  failedDelivery: "Failed Delivery",
  averageDeliveryTimeMinutes: "Avg Delivery Time (min)",
};

const PAGE_SIZE = 10;

function JobTable({ jobs, type }: { jobs: JobDetail[]; type: "Pickup" | "Delivery" }) {
  if (jobs.length === 0) {
    return (
      <EmptyState
        title={`No ${type.toLowerCase()} jobs found`}
        description={`${type} jobs appear when customers request ${type.toLowerCase()} service.`}
      />
    );
  }

  return (
    <div className="overflow-x-auto rounded-xl border border-slate-200 dark:border-slate-800">
      <table className="min-w-full divide-y divide-slate-200 text-sm dark:divide-slate-800">
        <thead className="bg-slate-50 dark:bg-slate-900/50">
          <tr>
            {["Order", "Customer", "Driver", "Status", "Scheduled", "Completed"].map(
              (header) => (
                <th
                  key={header}
                  className="px-4 py-3 text-left font-medium text-slate-500"
                >
                  {header}
                </th>
              ),
            )}
          </tr>
        </thead>
        <tbody className="divide-y divide-slate-200 bg-white dark:divide-slate-800 dark:bg-slate-950">
          {jobs.map((job) => (
            <tr key={job.id}>
              <td className="px-4 py-3">
                <div>{job.order.orderNumber}</div>
                <div className="text-xs text-slate-500">{job.order.queueNumber}</div>
              </td>
              <td className="px-4 py-3">
                <div>{job.order.customerName}</div>
                <div className="text-xs text-slate-500">{job.order.customerPhone}</div>
              </td>
              <td className="px-4 py-3">
                {job.driver ? job.driver.fullName : "Unassigned"}
              </td>
              <td className="px-4 py-3">{job.status}</td>
              <td className="px-4 py-3">
                {job.scheduledAt ? formatDate(job.scheduledAt) : "—"}
              </td>
              <td className="px-4 py-3">
                {job.completedAt ? formatDate(job.completedAt) : "—"}
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

export default function PickupDeliveryPage() {
  const [pickupPage, setPickupPage] = useState(1);
  const [deliveryPage, setDeliveryPage] = useState(1);

  const dashboardQuery = useQuery({
    queryKey: ["pickup-delivery-dashboard"],
    queryFn: () => apiGet<PickupDeliveryDashboard>("/pickup-delivery/dashboard"),
  });

  const pickupParams: JobListParams = { page: pickupPage, limit: PAGE_SIZE };
  const deliveryParams: JobListParams = { page: deliveryPage, limit: PAGE_SIZE };

  const pickupsQuery = useQuery({
    queryKey: ["pickups", pickupParams],
    queryFn: () =>
      apiGet<Paginated<JobDetail>>(
        "/pickups",
        pickupParams as Record<string, unknown>,
      ),
  });

  const deliveriesQuery = useQuery({
    queryKey: ["deliveries", deliveryParams],
    queryFn: () =>
      apiGet<Paginated<JobDetail>>(
        "/deliveries",
        deliveryParams as Record<string, unknown>,
      ),
  });

  if (dashboardQuery.isLoading) {
    return <FinanceListSkeleton />;
  }

  if (dashboardQuery.isError) {
    return (
      <QueryErrorState
        title="Failed to load pickup & delivery dashboard"
        message={getErrorMessage(
          dashboardQuery.error,
          "Unable to fetch pickup & delivery metrics.",
        )}
        onRetry={() => dashboardQuery.refetch()}
      />
    );
  }

  const pickups = pickupsQuery.data?.items ?? [];
  const pickupMeta = pickupsQuery.data?.meta;
  const deliveries = deliveriesQuery.data?.items ?? [];
  const deliveryMeta = deliveriesQuery.data?.meta;

  return (
    <div className="space-y-8">
      <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-3">
        {dashboardQuery.data
          ? Object.entries(dashboardQuery.data).map(([key, value]) => (
              <Card key={key}>
                <CardTitle>{DASHBOARD_LABELS[key] ?? key}</CardTitle>
                <CardValue>{String(value)}</CardValue>
              </Card>
            ))
          : null}
      </div>

      <section className="space-y-4">
        <h2 className="text-lg font-semibold">Pickup Jobs</h2>
        {pickupsQuery.isLoading ? (
          <FinanceListSkeleton />
        ) : pickupsQuery.isError ? (
          <QueryErrorState
            title="Failed to load pickup jobs"
            message={getErrorMessage(
              pickupsQuery.error,
              "Unable to fetch pickup jobs.",
            )}
            onRetry={() => pickupsQuery.refetch()}
          />
        ) : (
          <JobTable jobs={pickups} type="Pickup" />
        )}
        {pickupMeta ? (
          <div className="flex items-center justify-between gap-3">
            <p className="text-sm text-slate-500">
              Page {pickupMeta.page} of {pickupMeta.totalPages} ({pickupMeta.total}{" "}
              pickups)
            </p>
            <div className="flex gap-2">
              <Button
                variant="outline"
                size="sm"
                disabled={pickupPage <= 1}
                onClick={() => setPickupPage((current) => current - 1)}
              >
                Previous
              </Button>
              <Button
                variant="outline"
                size="sm"
                disabled={pickupPage >= pickupMeta.totalPages}
                onClick={() => setPickupPage((current) => current + 1)}
              >
                Next
              </Button>
            </div>
          </div>
        ) : null}
      </section>

      <section className="space-y-4">
        <h2 className="text-lg font-semibold">Delivery Jobs</h2>
        {deliveriesQuery.isLoading ? (
          <FinanceListSkeleton />
        ) : deliveriesQuery.isError ? (
          <QueryErrorState
            title="Failed to load delivery jobs"
            message={getErrorMessage(
              deliveriesQuery.error,
              "Unable to fetch delivery jobs.",
            )}
            onRetry={() => deliveriesQuery.refetch()}
          />
        ) : (
          <JobTable jobs={deliveries} type="Delivery" />
        )}
        {deliveryMeta ? (
          <div className="flex items-center justify-between gap-3">
            <p className="text-sm text-slate-500">
              Page {deliveryMeta.page} of {deliveryMeta.totalPages} (
              {deliveryMeta.total} deliveries)
            </p>
            <div className="flex gap-2">
              <Button
                variant="outline"
                size="sm"
                disabled={deliveryPage <= 1}
                onClick={() => setDeliveryPage((current) => current - 1)}
              >
                Previous
              </Button>
              <Button
                variant="outline"
                size="sm"
                disabled={deliveryPage >= deliveryMeta.totalPages}
                onClick={() => setDeliveryPage((current) => current + 1)}
              >
                Next
              </Button>
            </div>
          </div>
        ) : null}
      </section>
    </div>
  );
}
