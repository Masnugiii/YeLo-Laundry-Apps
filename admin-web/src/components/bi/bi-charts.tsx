"use client";

import {
  Area,
  AreaChart,
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

const COLORS = ["#2563eb", "#16a34a", "#f59e0b", "#8b5cf6", "#ef4444", "#06b6d4"];

export function BiLineChart({
  title,
  data,
  dataKey = "value",
  currency = false,
}: {
  title: string;
  data: Array<{ label: string; date?: string; value: number }>;
  dataKey?: string;
  currency?: boolean;
}) {
  return (
    <Card className="p-4">
      <h3 className="mb-4 text-lg font-semibold">{title}</h3>
      <div className="h-72">
        <ResponsiveContainer width="100%" height="100%">
          <LineChart data={data}>
            <CartesianGrid strokeDasharray="3 3" />
            <XAxis dataKey="label" />
            <YAxis />
            <Tooltip formatter={(v) => (currency ? formatCurrency(Number(v ?? 0)) : v)} />
            <Line type="monotone" dataKey={dataKey} stroke="#2563eb" strokeWidth={2} />
          </LineChart>
        </ResponsiveContainer>
      </div>
    </Card>
  );
}

export function BiBarChart({
  title,
  data,
  dataKey = "value",
  currency = false,
}: {
  title: string;
  data: Array<{ label: string; value: number }>;
  dataKey?: string;
  currency?: boolean;
}) {
  return (
    <Card className="p-4">
      <h3 className="mb-4 text-lg font-semibold">{title}</h3>
      <div className="h-72">
        <ResponsiveContainer width="100%" height="100%">
          <BarChart data={data}>
            <CartesianGrid strokeDasharray="3 3" />
            <XAxis dataKey="label" />
            <YAxis />
            <Tooltip formatter={(v) => (currency ? formatCurrency(Number(v ?? 0)) : v)} />
            <Bar dataKey={dataKey} fill="#2563eb" radius={[4, 4, 0, 0]} />
          </BarChart>
        </ResponsiveContainer>
      </div>
    </Card>
  );
}

export function BiAreaChart({
  title,
  data,
  lines,
}: {
  title: string;
  data: Array<{ label: string; date?: string; [key: string]: string | number | undefined }>;
  lines: Array<{ key: string; color: string; label: string }>;
}) {
  return (
    <Card className="p-4">
      <h3 className="mb-4 text-lg font-semibold">{title}</h3>
      <div className="h-72">
        <ResponsiveContainer width="100%" height="100%">
          <AreaChart data={data}>
            <CartesianGrid strokeDasharray="3 3" />
            <XAxis dataKey="label" />
            <YAxis />
            <Tooltip />
            <Legend />
            {lines.map((line) => (
              <Area
                key={line.key}
                type="monotone"
                dataKey={line.key}
                stroke={line.color}
                fill={line.color}
                fillOpacity={0.15}
                name={line.label}
              />
            ))}
          </AreaChart>
        </ResponsiveContainer>
      </div>
    </Card>
  );
}

export function BiPieChart({
  title,
  data,
  currency = false,
}: {
  title: string;
  data: Array<{ name: string; value: number }>;
  currency?: boolean;
}) {
  return (
    <Card className="p-4">
      <h3 className="mb-4 text-lg font-semibold">{title}</h3>
      <div className="h-72">
        <ResponsiveContainer width="100%" height="100%">
          <PieChart>
            <Pie data={data} dataKey="value" nameKey="name" cx="50%" cy="50%" outerRadius={100} label>
              {data.map((_, index) => (
                <Cell key={index} fill={COLORS[index % COLORS.length]} />
              ))}
            </Pie>
            <Tooltip formatter={(v) => (currency ? formatCurrency(Number(v ?? 0)) : v)} />
            <Legend />
          </PieChart>
        </ResponsiveContainer>
      </div>
    </Card>
  );
}
