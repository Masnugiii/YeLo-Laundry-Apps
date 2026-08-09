"use client";

import { BiLineChart, BiPieChart } from "@/components/bi/bi-charts";
import { ReportExportBar } from "@/components/bi/report-export-bar";
import { ReportKpiGrid } from "@/components/bi/report-kpi-grid";
import {
  ReportPageShell,
  useReportFilters,
} from "@/components/bi/report-page-shell";
import { Card } from "@/components/ui/card";
import { useCustomerAnalytics } from "@/hooks/use-reports";
import { formatCurrency } from "@/lib/utils";

export default function CustomerAnalyticsPage() {
  const filters = useReportFilters("this_month");
  const query = useCustomerAnalytics(filters.applied);
  const data = query.data;

  const exportRows =
    data?.topCustomers.map((c) => ({
      Customer: c.customerName,
      Code: c.customerCode,
      CLV: c.lifetimeValue,
      Visits: c.visits,
      "Avg Spending": c.averageSpending,
    })) ?? [];

  return (
    <ReportPageShell
      title="Customer Analytics"
      description="Customer acquisition, retention, lifetime value, and membership distribution."
      filters={filters}
      query={query}
    >
      {data ? (
        <>
          <ReportExportBar
            filename="customer-analytics"
            title="Customer Analytics"
            rows={exportRows}
          />
          <ReportKpiGrid
            items={[
              { title: "New Customers", value: String(data.newCustomers) },
              { title: "Returning Customers", value: String(data.returningCustomers) },
              { title: "Inactive Customers", value: String(data.inactiveCustomers) },
              { title: "Active Customers", value: String(data.activeCustomers) },
              { title: "Average Visits", value: String(data.averageVisits) },
              {
                title: "Average Spending",
                value: formatCurrency(data.averageSpending),
              },
            ]}
          />
          <div className="grid gap-4 xl:grid-cols-2">
            <BiLineChart title="New Customer Trend" data={data.customerTrend} />
            <BiPieChart title="Membership Distribution" data={data.membershipDistribution} />
          </div>
          <Card className="overflow-x-auto p-4">
            <h3 className="mb-4 font-semibold">Top Customers</h3>
            <table className="min-w-full text-sm">
              <thead>
                <tr className="border-b text-left text-slate-500">
                  <th className="px-3 py-2">Customer</th>
                  <th className="px-3 py-2">Code</th>
                  <th className="px-3 py-2">CLV</th>
                  <th className="px-3 py-2">Visits</th>
                  <th className="px-3 py-2">Avg Spending</th>
                </tr>
              </thead>
              <tbody>
                {data.topCustomers.map((customer) => (
                  <tr key={customer.customerId} className="border-b">
                    <td className="px-3 py-2">{customer.customerName}</td>
                    <td className="px-3 py-2">{customer.customerCode}</td>
                    <td className="px-3 py-2">{formatCurrency(customer.lifetimeValue)}</td>
                    <td className="px-3 py-2">{customer.visits}</td>
                    <td className="px-3 py-2">{formatCurrency(customer.averageSpending)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </Card>
        </>
      ) : null}
    </ReportPageShell>
  );
}
