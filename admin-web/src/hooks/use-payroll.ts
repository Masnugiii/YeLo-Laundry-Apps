import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { apiGet, apiPatch, apiPost } from "@/lib/api";
import type { Paginated } from "@/types/api";
import type {
  PayrollDashboard,
  PayrollDetail,
  PayrollListItem,
  PayrollListParams,
  PayrollSettings,
} from "@/types/payroll";

export const PAYROLL_QUERY_KEY = "payroll";

export function usePayrollDashboard() {
  return useQuery({
    queryKey: [PAYROLL_QUERY_KEY, "dashboard"],
    queryFn: () => apiGet<PayrollDashboard>("/payroll/dashboard"),
  });
}

export function usePayrollSettings() {
  return useQuery({
    queryKey: [PAYROLL_QUERY_KEY, "settings"],
    queryFn: () => apiGet<PayrollSettings>("/payroll/settings"),
  });
}

export function usePayrollRecords(params: PayrollListParams) {
  return useQuery({
    queryKey: [PAYROLL_QUERY_KEY, "list", params],
    queryFn: () =>
      apiGet<Paginated<PayrollListItem>>(
        "/payroll",
        params as Record<string, unknown>,
      ),
  });
}

export function usePayrollRecord(id: string) {
  return useQuery({
    queryKey: [PAYROLL_QUERY_KEY, "detail", id],
    queryFn: () => apiGet<PayrollDetail>(`/payroll/${id}`),
    enabled: Boolean(id),
  });
}

export function useUpdatePayrollSettings() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (input: Partial<PayrollSettings>) =>
      apiPatch<PayrollSettings>("/payroll/settings", input),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: [PAYROLL_QUERY_KEY] });
    },
  });
}

export function useCalculatePayroll() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (input: { periodStart: string; periodEnd: string }) =>
      apiPost<PayrollListItem[]>("/payroll/calculate", {
        periodStart: input.periodStart,
        periodEnd: input.periodEnd,
      }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: [PAYROLL_QUERY_KEY] });
    },
  });
}

export function useApprovePayroll() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (input: { payrollIds: string[]; notes?: string }) =>
      apiPost<PayrollListItem[]>("/payroll/approve", input),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: [PAYROLL_QUERY_KEY] });
    },
  });
}

export function usePayPayroll() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (input: {
      payrollId: string;
      method: "CASH" | "TRANSFER" | "WALLET";
      amount: number;
      referenceNumber?: string;
      notes?: string;
    }) => apiPost<PayrollDetail>("/payroll/pay", input),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: [PAYROLL_QUERY_KEY] });
    },
  });
}
