"use client";

import { BiBarChart, BiLineChart } from "@/components/bi/bi-charts";
import { ReportExportBar } from "@/components/bi/report-export-bar";
import { ReportKpiGrid } from "@/components/bi/report-kpi-grid";
import {
  ReportPageShell,
  useReportFilters,
} from "@/components/bi/report-page-shell";
import { useExecutiveDashboard } from "@/hooks/use-reports";
import { formatCurrency } from "@/lib/utils";

export default function ExecutiveDashboardPage() {
  const filters = useReportFilters("this_month");
  const query = useExecutiveDashboard(filters.applied);
  const data = query.data;

  const exportRows = data
    ? [
        { Metric: "Today's Revenue", Value: data.revenueToday },
        { Metric: "Weekly Revenue", Value: data.revenueWeek },
        { Metric: "Monthly Revenue", Value: data.revenueMonth },
        { Metric: "Net Profit", Value: data.netProfit },
        { Metric: "Total Orders", Value: data.totalOrders },
        { Metric: "Completed Orders", Value: data.completedOrders },
        { Metric: "Pending Orders", Value: data.pendingOrders },
        { Metric: "Cancelled Orders", Value: data.cancelledOrders },
        { Metric: "Average Order Value", Value: data.averageOrderValue },
        { Metric: "Laundry Kg Today", Value: data.laundryKgToday },
        { Metric: "Laundry Kg Month", Value: data.laundryKgMonth },
        { Metric: "Pickup Today", Value: data.pickupToday },
        { Metric: "Delivery Today", Value: data.deliveryToday },
        { Metric: "Attendance Today", Value: data.attendanceToday },
        { Metric: "Payroll This Period", Value: data.payrollThisPeriod },
        { Metric: "Wallet Balance", Value: data.walletBalance },
        { Metric: "Reward Points Issued", Value: data.rewardPointsIssued },
        { Metric: "New Customers", Value: data.newCustomers },
        { Metric: "Returning Customers", Value: data.returningCustomers },
      ]
    : [];

  return (
    <ReportPageShell
      title="Executive Dashboard"
      description="Consolidated business KPIs across orders, finance, production, and loyalty."
      filters={filters}
      query={query}
    >
      {data ? (
        <>
          <ReportExportBar
            filename="executive-dashboard"
            title="Executive Dashboard"
            rows={exportRows}
          />
          <ReportKpiGrid
            items={[
              { title: "Today's Revenue", value: formatCurrency(data.revenueToday) },
              { title: "Weekly Revenue", value: formatCurrency(data.revenueWeek) },
              { title: "Monthly Revenue", value: formatCurrency(data.revenueMonth) },
              { title: "Net Profit", value: formatCurrency(data.netProfit) },
              { title: "Total Orders", value: String(data.totalOrders) },
              { title: "Completed Orders", value: String(data.completedOrders) },
              { title: "Pending Orders", value: String(data.pendingOrders) },
              { title: "Cancelled Orders", value: String(data.cancelledOrders) },
              { title: "Average Order Value", value: formatCurrency(data.averageOrderValue) },
              { title: "Laundry Kg Today", value: `${data.laundryKgToday} kg` },
              { title: "Laundry Kg Month", value: `${data.laundryKgMonth} kg` },
              { title: "Pickup Today", value: String(data.pickupToday) },
              { title: "Delivery Today", value: String(data.deliveryToday) },
              { title: "Attendance Today", value: String(data.attendanceToday) },
              { title: "Payroll This Period", value: formatCurrency(data.payrollThisPeriod) },
              { title: "Wallet Balance", value: formatCurrency(data.walletBalance) },
              { title: "Reward Points Issued", value: String(data.rewardPointsIssued) },
              { title: "New Customers", value: String(data.newCustomers) },
              { title: "Returning Customers", value: String(data.returningCustomers) },
            ]}
          />
          <div className="grid gap-4 xl:grid-cols-2">
            <BiBarChart
              title="Order Status Overview"
              data={[
                { label: "Completed", value: data.completedOrders },
                { label: "Pending", value: data.pendingOrders },
                { label: "Cancelled", value: data.cancelledOrders },
              ]}
            />
            <BiLineChart
              title="Revenue Snapshot"
              data={[
                { label: "Today", value: data.revenueToday },
                { label: "Week", value: data.revenueWeek },
                { label: "Month", value: data.revenueMonth },
              ]}
              currency
            />
          </div>
        </>
      ) : null}
    </ReportPageShell>
  );
}
