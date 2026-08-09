"use client";

import {
  Bar,
  BarChart,
  CartesianGrid,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";
import { Card, CardTitle, CardValue } from "@/components/ui/card";
import { Skeleton } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { useDashboardSummary } from "@/hooks/use-dashboard-summary";
import { formatCurrency } from "@/lib/utils";
import type { DashboardSummary } from "@/types/api";

const METRIC_COUNT = 12;

type MetricConfig = {
  title: string;
  format: (summary: DashboardSummary) => string;
};

const METRICS: MetricConfig[] = [
  { title: "Revenue Today", format: (s) => formatCurrency(s.revenueToday) },
  {
    title: "Revenue This Month",
    format: (s) => formatCurrency(s.revenueThisMonth),
  },
  { title: "Net Profit", format: (s) => formatCurrency(s.netProfit) },
  { title: "Expenses", format: (s) => formatCurrency(s.expenses) },
  { title: "Payroll", format: (s) => formatCurrency(s.payroll) },
  { title: "Customers", format: (s) => String(s.customers) },
  { title: "Employees", format: (s) => String(s.employees) },
  { title: "Orders", format: (s) => String(s.orders) },
  {
    title: "Laundry In Progress",
    format: (s) => String(s.laundryInProgress),
  },
  { title: "Ready Pickup", format: (s) => String(s.readyPickup) },
  { title: "Delivery Today", format: (s) => String(s.deliveryToday) },
  {
    title: "Attendance Today",
    format: (s) => String(s.attendanceToday),
  },
];

function DashboardSkeleton() {
  return (
    <div className="space-y-6">
      <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
        {Array.from({ length: METRIC_COUNT }).map((_, index) => (
          <Card key={index}>
            <Skeleton className="h-4 w-28" />
            <Skeleton className="mt-3 h-8 w-24" />
          </Card>
        ))}
      </div>
      <Card>
        <Skeleton className="h-4 w-40" />
        <Skeleton className="mt-4 h-80 w-full" />
      </Card>
    </div>
  );
}

function DashboardError({
  message,
  onRetry,
}: {
  message: string;
  onRetry: () => void;
}) {
  return (
    <Card className="flex flex-col items-center justify-center gap-4 py-16 text-center">
      <div>
        <CardTitle className="text-base text-slate-900 dark:text-slate-100">
          Failed to load dashboard
        </CardTitle>
        <p className="mt-2 text-sm text-slate-500">{message}</p>
      </div>
      <Button onClick={onRetry}>Try again</Button>
    </Card>
  );
}

export default function DashboardPage() {
  const { data, isLoading, isError, error, refetch, isFetching } =
    useDashboardSummary();

  if (isLoading) {
    return <DashboardSkeleton />;
  }

  if (isError || !data) {
    const message =
      error instanceof Error
        ? error.message
        : "Unable to fetch dashboard summary from the server.";
    return <DashboardError message={message} onRetry={() => refetch()} />;
  }

  const chartData = [
    { name: "Revenue", value: data.revenueThisMonth },
    { name: "Expenses", value: data.expenses },
    { name: "Payroll", value: data.payroll },
    { name: "Net Profit", value: data.netProfit },
  ];

  return (
    <div className="space-y-6">
      {isFetching ? (
        <p className="text-sm text-slate-500">Refreshing dashboard...</p>
      ) : null}
      <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
        {METRICS.map((metric) => (
          <Card key={metric.title}>
            <CardTitle>{metric.title}</CardTitle>
            <CardValue>{metric.format(data)}</CardValue>
          </Card>
        ))}
      </div>
      <Card>
        <CardTitle>Financial Overview</CardTitle>
        <div className="mt-4 h-80">
          <ResponsiveContainer width="100%" height="100%">
            <BarChart data={chartData}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="name" />
              <YAxis />
              <Tooltip
                formatter={(value) =>
                  formatCurrency(typeof value === "number" ? value : Number(value ?? 0))
                }
              />
              <Bar dataKey="value" fill="#2563eb" radius={[6, 6, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </div>
      </Card>
    </div>
  );
}
