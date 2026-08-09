"use client";

import {
  Bar,
  BarChart,
  CartesianGrid,
  Cell,
  Legend,
  Line,
  LineChart,
  Pie,
  PieChart,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";
import { Card } from "@/components/ui/card";
import { formatCurrency } from "@/lib/utils";
import type { FinanceDashboard } from "@/types/finance";

const COLORS = ["#2563eb", "#16a34a", "#f59e0b", "#8b5cf6", "#ef4444", "#06b6d4"];

export function FinanceCharts({ data }: { data: FinanceDashboard }) {
  const revenueTrend = data.trends.map((point) => ({
    label: point.label,
    revenue: point.revenue,
    expenses: point.expenses,
    netProfit: point.netProfit,
    orders: point.orderCount,
  }));

  const paymentDistribution = data.paymentMethodBreakdown.map((item) => ({
    name: item.label,
    value: item.amount,
  }));

  return (
    <div className="grid gap-4 xl:grid-cols-2">
      <Card className="p-4">
        <h3 className="mb-4 text-lg font-semibold">Revenue Trend</h3>
        <div className="h-72">
          <ResponsiveContainer width="100%" height="100%">
            <LineChart data={revenueTrend}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="label" />
              <YAxis />
              <Tooltip formatter={(value) => formatCurrency(Number(value ?? 0))} />
              <Legend />
              <Line type="monotone" dataKey="revenue" stroke="#2563eb" />
            </LineChart>
          </ResponsiveContainer>
        </div>
      </Card>

      <Card className="p-4">
        <h3 className="mb-4 text-lg font-semibold">Expense Trend</h3>
        <div className="h-72">
          <ResponsiveContainer width="100%" height="100%">
            <LineChart data={revenueTrend}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="label" />
              <YAxis />
              <Tooltip formatter={(value) => formatCurrency(Number(value ?? 0))} />
              <Legend />
              <Line type="monotone" dataKey="expenses" stroke="#ef4444" />
            </LineChart>
          </ResponsiveContainer>
        </div>
      </Card>

      <Card className="p-4">
        <h3 className="mb-4 text-lg font-semibold">Net Profit Trend</h3>
        <div className="h-72">
          <ResponsiveContainer width="100%" height="100%">
            <BarChart data={revenueTrend}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="label" />
              <YAxis />
              <Tooltip formatter={(value) => formatCurrency(Number(value ?? 0))} />
              <Legend />
              <Bar dataKey="netProfit" fill="#16a34a" />
            </BarChart>
          </ResponsiveContainer>
        </div>
      </Card>

      <Card className="p-4">
        <h3 className="mb-4 text-lg font-semibold">Payment Method Distribution</h3>
        <div className="h-72">
          <ResponsiveContainer width="100%" height="100%">
            <PieChart>
              <Pie
                data={paymentDistribution}
                dataKey="value"
                nameKey="name"
                cx="50%"
                cy="50%"
                outerRadius={90}
                label
              >
                {paymentDistribution.map((entry, index) => (
                  <Cell key={entry.name} fill={COLORS[index % COLORS.length]} />
                ))}
              </Pie>
              <Tooltip formatter={(value) => formatCurrency(Number(value ?? 0))} />
            </PieChart>
          </ResponsiveContainer>
        </div>
      </Card>

      <Card className="p-4 xl:col-span-2">
        <h3 className="mb-4 text-lg font-semibold">Daily Orders</h3>
        <div className="h-72">
          <ResponsiveContainer width="100%" height="100%">
            <BarChart data={revenueTrend}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="label" />
              <YAxis />
              <Tooltip />
              <Legend />
              <Bar dataKey="orders" fill="#8b5cf6" />
            </BarChart>
          </ResponsiveContainer>
        </div>
      </Card>
    </div>
  );
}
