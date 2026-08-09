import { useQuery } from "@tanstack/react-query";
import { apiGet } from "@/lib/api";
import type {
  CustomerAnalytics,
  EmployeePerformanceReport,
  ExecutiveDashboard,
  FinanceAnalytics,
  ForecastReport,
  MembershipAnalytics,
  PayrollAnalytics,
  ProductionAnalytics,
  ReportQueryParams,
  ReportSchedulerArchitecture,
  SalesReport,
  WalletAnalytics,
} from "@/types/reports";

export const REPORTS_QUERY_KEY = "reports";

function toQueryRecord(params?: ReportQueryParams) {
  return params as Record<string, unknown> | undefined;
}

export function useExecutiveDashboard(params?: ReportQueryParams) {
  return useQuery({
    queryKey: [REPORTS_QUERY_KEY, "dashboard", params],
    queryFn: () => apiGet<ExecutiveDashboard>("/reports/dashboard", toQueryRecord(params)),
  });
}

export function useSalesReport(params?: ReportQueryParams) {
  return useQuery({
    queryKey: [REPORTS_QUERY_KEY, "sales", params],
    queryFn: () => apiGet<SalesReport>("/reports/sales", toQueryRecord(params)),
  });
}

export function useCustomerAnalytics(params?: ReportQueryParams) {
  return useQuery({
    queryKey: [REPORTS_QUERY_KEY, "customers", params],
    queryFn: () => apiGet<CustomerAnalytics>("/reports/customers", toQueryRecord(params)),
  });
}

export function useProductionAnalytics(params?: ReportQueryParams) {
  return useQuery({
    queryKey: [REPORTS_QUERY_KEY, "production", params],
    queryFn: () => apiGet<ProductionAnalytics>("/reports/production", toQueryRecord(params)),
  });
}

export function useEmployeePerformance(params?: ReportQueryParams) {
  return useQuery({
    queryKey: [REPORTS_QUERY_KEY, "employees", params],
    queryFn: () => apiGet<EmployeePerformanceReport>("/reports/employees", toQueryRecord(params)),
  });
}

export function useFinanceAnalytics(params?: ReportQueryParams) {
  return useQuery({
    queryKey: [REPORTS_QUERY_KEY, "finance", params],
    queryFn: () => apiGet<FinanceAnalytics>("/reports/finance", toQueryRecord(params)),
  });
}

export function usePayrollAnalytics(params?: ReportQueryParams) {
  return useQuery({
    queryKey: [REPORTS_QUERY_KEY, "payroll", params],
    queryFn: () => apiGet<PayrollAnalytics>("/reports/payroll", toQueryRecord(params)),
  });
}

export function useWalletAnalytics(params?: ReportQueryParams) {
  return useQuery({
    queryKey: [REPORTS_QUERY_KEY, "wallet", params],
    queryFn: () => apiGet<WalletAnalytics>("/reports/wallet", toQueryRecord(params)),
  });
}

export function useMembershipAnalytics(params?: ReportQueryParams) {
  return useQuery({
    queryKey: [REPORTS_QUERY_KEY, "membership", params],
    queryFn: () => apiGet<MembershipAnalytics>("/reports/membership", toQueryRecord(params)),
  });
}

export function useForecastReport(params?: ReportQueryParams) {
  return useQuery({
    queryKey: [REPORTS_QUERY_KEY, "forecast", params],
    queryFn: () => apiGet<ForecastReport>("/reports/forecast", toQueryRecord(params)),
  });
}

export function useReportScheduler() {
  return useQuery({
    queryKey: [REPORTS_QUERY_KEY, "scheduler"],
    queryFn: () => apiGet<ReportSchedulerArchitecture>("/reports/scheduler"),
  });
}
