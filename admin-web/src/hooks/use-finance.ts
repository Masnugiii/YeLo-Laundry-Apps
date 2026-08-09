import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { apiDelete, apiGet, apiPatch, apiPost } from "@/lib/api";
import type { Paginated } from "@/types/api";
import type {
  CashFlowReport,
  CreateExpenseInput,
  Expense,
  ExpenseCategory,
  ExpenseListParams,
  FinanceDashboard,
  FinanceReportParams,
  PaymentHistorySummary,
  ProfitLossReport,
  RevenueListItem,
  RevenueListParams,
  UpdateExpenseInput,
} from "@/types/finance";

export const FINANCE_QUERY_KEY = "finance";

export function useFinanceDashboard() {
  return useQuery({
    queryKey: [FINANCE_QUERY_KEY, "dashboard"],
    queryFn: () => apiGet<FinanceDashboard>("/finance/dashboard"),
  });
}

export function useRevenue(params: RevenueListParams) {
  return useQuery({
    queryKey: [FINANCE_QUERY_KEY, "revenue", params],
    queryFn: () =>
      apiGet<Paginated<RevenueListItem>>(
        "/finance/revenue",
        params as Record<string, unknown>,
      ),
  });
}

export function useExpenses(params: ExpenseListParams) {
  return useQuery({
    queryKey: [FINANCE_QUERY_KEY, "expenses", params],
    queryFn: () =>
      apiGet<Paginated<Expense>>("/expenses", params as Record<string, unknown>),
  });
}

export function useExpenseCategories() {
  return useQuery({
    queryKey: [FINANCE_QUERY_KEY, "expense-categories"],
    queryFn: () => apiGet<ExpenseCategory[]>("/expenses/categories"),
  });
}

export function useCreateExpense() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (input: CreateExpenseInput) => apiPost<Expense>("/expenses", input),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: [FINANCE_QUERY_KEY] });
    },
  });
}

export function useUpdateExpense(id: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (input: UpdateExpenseInput) =>
      apiPatch<Expense>(`/expenses/${id}`, input),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: [FINANCE_QUERY_KEY] });
    },
  });
}

export function useDeleteExpense() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => apiDelete<Expense>(`/expenses/${id}`),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: [FINANCE_QUERY_KEY] });
    },
  });
}

export function useProfitLoss(params: FinanceReportParams) {
  return useQuery({
    queryKey: [FINANCE_QUERY_KEY, "profit-loss", params],
    queryFn: () =>
      apiGet<ProfitLossReport>(
        "/finance/profit-loss",
        params as Record<string, unknown>,
      ),
  });
}

export function useCashFlow(params: FinanceReportParams) {
  return useQuery({
    queryKey: [FINANCE_QUERY_KEY, "cash-flow", params],
    queryFn: () =>
      apiGet<CashFlowReport>(
        "/finance/cash-flow",
        params as Record<string, unknown>,
      ),
  });
}

export function usePaymentHistory(params: FinanceReportParams) {
  return useQuery({
    queryKey: [FINANCE_QUERY_KEY, "payment-history", params],
    queryFn: () =>
      apiGet<PaymentHistorySummary>(
        "/finance/payment-history",
        params as Record<string, unknown>,
      ),
  });
}
