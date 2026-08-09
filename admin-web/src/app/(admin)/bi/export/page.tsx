"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import { useEffect } from "react";
import { ReportExportBar } from "@/components/bi/report-export-bar";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import {
  useCustomerAnalytics,
  useExecutiveDashboard,
  useFinanceAnalytics,
  useReportScheduler,
  useSalesReport,
} from "@/hooks/use-reports";
import { isOwnerRole } from "@/lib/auth";

const REPORT_LINKS = [
  { title: "Executive Dashboard", href: "/bi/executive" },
  { title: "Sales Report", href: "/bi/sales" },
  { title: "Customer Analytics", href: "/bi/customers" },
  { title: "Production Analytics", href: "/bi/production" },
  { title: "Employee Performance", href: "/bi/employees" },
  { title: "Finance Analytics", href: "/bi/finance" },
  { title: "Payroll Analytics", href: "/bi/payroll" },
  { title: "Wallet Analytics", href: "/bi/wallet" },
  { title: "Membership Analytics", href: "/bi/membership" },
];

export default function ExportCenterPage() {
  const router = useRouter();
  const executive = useExecutiveDashboard({ period: "this_month" });
  const sales = useSalesReport({ period: "this_month" });
  const customers = useCustomerAnalytics({ period: "this_month" });
  const finance = useFinanceAnalytics({ period: "this_month" });
  const scheduler = useReportScheduler();

  useEffect(() => {
    if (!isOwnerRole()) {
      router.replace("/bi/executive");
    }
  }, [router]);

  if (!isOwnerRole()) return null;

  const combinedRows = [
    ...(executive.data
      ? [{ Report: "Executive", Metric: "Monthly Revenue", Value: executive.data.revenueMonth }]
      : []),
    ...(sales.data
      ? [{ Report: "Sales", Metric: "Total Revenue", Value: sales.data.summary.totalRevenue }]
      : []),
    ...(customers.data
      ? [{ Report: "Customers", Metric: "New Customers", Value: customers.data.newCustomers }]
      : []),
    ...(finance.data
      ? [{ Report: "Finance", Metric: "Net Profit", Value: finance.data.netProfit }]
      : []),
  ];

  return (
    <div className="space-y-6">
      <div>
        <h2 className="text-xl font-semibold">Export Center</h2>
        <p className="text-sm text-slate-500">
          Export consolidated report snapshots. Owner access only.
        </p>
      </div>

      <ReportExportBar
        filename="bi-export-center"
        title="Business Intelligence Export"
        rows={combinedRows}
      />

      <Card className="p-6">
        <h3 className="mb-4 font-semibold">Available Reports</h3>
        <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
          {REPORT_LINKS.map((report) => (
            <Link key={report.href} href={report.href}>
              <Button variant="outline" className="w-full justify-start">
                {report.title}
              </Button>
            </Link>
          ))}
        </div>
      </Card>

      {scheduler.data ? (
        <Card className="space-y-3 p-6">
          <h3 className="font-semibold">Report Scheduler (Architecture)</h3>
          <p className="text-sm text-slate-500">{scheduler.data.note}</p>
          <ul className="list-disc space-y-1 pl-5 text-sm">
            {scheduler.data.jobs.map((job) => (
              <li key={job.code}>
                {job.frequency} — {job.report} ({job.enabled ? "enabled" : "disabled"})
              </li>
            ))}
          </ul>
        </Card>
      ) : null}
    </div>
  );
}
