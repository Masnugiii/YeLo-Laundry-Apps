"use client";

import { useQuery } from "@tanstack/react-query";
import {
  CartesianGrid,
  Line,
  LineChart,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";
import { Card, CardTitle } from "@/components/ui/card";
import { apiGet } from "@/lib/api";

export default function AnalyticsPage() {
  const { data: finance } = useQuery({
    queryKey: ["finance-dashboard"],
    queryFn: () => apiGet<Record<string, number>>("/finance/dashboard"),
  });

  const { data: orders } = useQuery({
    queryKey: ["order-statistics"],
    queryFn: () => apiGet<Record<string, number>>("/orders/statistics"),
  });

  const chartData = finance
    ? [
        { name: "Today", revenue: finance.revenueToday ?? 0 },
        { name: "Week", revenue: finance.revenueThisWeek ?? 0 },
        { name: "Month", revenue: finance.revenueThisMonth ?? 0 },
      ]
    : [];

  return (
    <div className="space-y-6">
      <Card>
        <CardTitle>Revenue Trend</CardTitle>
        <div className="mt-4 h-80">
          <ResponsiveContainer width="100%" height="100%">
            <LineChart data={chartData}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="name" />
              <YAxis />
              <Tooltip />
              <Line type="monotone" dataKey="revenue" stroke="#2563eb" strokeWidth={2} />
            </LineChart>
          </ResponsiveContainer>
        </div>
      </Card>
      <div className="grid gap-4 md:grid-cols-2">
        <Card>
          <CardTitle>Finance Metrics</CardTitle>
          <pre className="mt-3 overflow-auto text-xs">{JSON.stringify(finance, null, 2)}</pre>
        </Card>
        <Card>
          <CardTitle>Order Metrics</CardTitle>
          <pre className="mt-3 overflow-auto text-xs">{JSON.stringify(orders, null, 2)}</pre>
        </Card>
      </div>
    </div>
  );
}
