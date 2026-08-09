"use client";

import { BiLineChart, BiPieChart } from "@/components/bi/bi-charts";
import { ReportExportBar } from "@/components/bi/report-export-bar";
import { ReportKpiGrid } from "@/components/bi/report-kpi-grid";
import {
  ReportPageShell,
  useReportFilters,
} from "@/components/bi/report-page-shell";
import { Card } from "@/components/ui/card";
import { useMembershipAnalytics } from "@/hooks/use-reports";

export default function MembershipAnalyticsPage() {
  const filters = useReportFilters("this_month");
  const query = useMembershipAnalytics(filters.applied);
  const data = query.data;

  const exportRows =
    data?.distribution.map((d) => ({
      Tier: d.name,
      Members: d.value,
    })) ?? [];

  return (
    <ReportPageShell
      title="Membership Analytics"
      description="Membership tier distribution, growth, and upgrade history."
      filters={filters}
      query={query}
    >
      {data ? (
        <>
          <ReportExportBar
            filename="membership-analytics"
            title="Membership Analytics"
            rows={exportRows}
          />
          <ReportKpiGrid
            items={[
              { title: "Total Members", value: String(data.totalMembers) },
              {
                title: "Points Issued (Period)",
                value: String(data.pointsIssuedInPeriod),
              },
              {
                title: "Regular",
                value: String(
                  data.distribution.find((d) => d.name === "Regular")?.value ?? 0,
                ),
              },
              {
                title: "Platinum",
                value: String(
                  data.distribution.find((d) => d.name === "Platinum")?.value ?? 0,
                ),
              },
            ]}
          />
          <div className="grid gap-4 xl:grid-cols-2">
            <BiPieChart title="Membership Distribution" data={data.distribution} />
            <BiLineChart title="Points Growth" data={data.growth} />
          </div>
          <Card className="overflow-x-auto p-4">
            <h3 className="mb-4 font-semibold">Upgrade History</h3>
            <table className="min-w-full text-sm">
              <thead>
                <tr className="border-b text-left text-slate-500">
                  <th className="px-3 py-2">Level</th>
                  <th className="px-3 py-2">Upgraded At</th>
                  <th className="px-3 py-2">Lifetime Points</th>
                </tr>
              </thead>
              <tbody>
                {data.upgradeHistory.map((row, index) => (
                  <tr key={`${row.customerId}-${index}`} className="border-b">
                    <td className="px-3 py-2">{row.level}</td>
                    <td className="px-3 py-2">
                      {new Date(row.upgradedAt).toLocaleString()}
                    </td>
                    <td className="px-3 py-2">{row.lifetimePoints}</td>
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
