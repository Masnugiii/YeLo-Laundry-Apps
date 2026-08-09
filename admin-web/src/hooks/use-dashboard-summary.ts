import { useQuery } from "@tanstack/react-query";
import { apiGet } from "@/lib/api";
import type { DashboardSummary } from "@/types/api";

export const DASHBOARD_SUMMARY_QUERY_KEY = ["dashboard-summary"] as const;

export function useDashboardSummary() {
  return useQuery({
    queryKey: DASHBOARD_SUMMARY_QUERY_KEY,
    queryFn: () => apiGet<DashboardSummary>("/dashboard/summary"),
  });
}
