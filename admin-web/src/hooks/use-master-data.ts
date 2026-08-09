import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { apiDelete, apiGet, apiPatch, apiPost } from "@/lib/api";
import type {
  CatalogService,
  CreateExpenseCategoryInput,
  CreateServiceInput,
  CreateServicePriceInput,
  ExpenseCategory,
  NumberingSequence,
  PaymentMethod,
  ServicePrice,
  UpdateExpenseCategoryInput,
  UpdateNumberingInput,
  UpdatePaymentMethodInput,
  UpdateServiceInput,
} from "@/types/master-data";

export const MASTER_DATA_QUERY_KEY = "master-data";

export function useCatalogServices(includeInactive = true) {
  return useQuery({
    queryKey: [MASTER_DATA_QUERY_KEY, "services", includeInactive],
    queryFn: () =>
      apiGet<CatalogService[]>("/catalog/services", {
        includeInactive: includeInactive ? "true" : "false",
      }),
  });
}

export function useServicePrices(serviceId?: string) {
  return useQuery({
    queryKey: [MASTER_DATA_QUERY_KEY, "prices", serviceId],
    queryFn: () =>
      apiGet<ServicePrice[]>("/catalog/prices", serviceId ? { serviceId } : undefined),
  });
}

export function useCreateService() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (input: CreateServiceInput) =>
      apiPost<CatalogService>("/catalog/services", input),
    onSuccess: () =>
      queryClient.invalidateQueries({ queryKey: [MASTER_DATA_QUERY_KEY, "services"] }),
  });
}

export function useUpdateService(serviceId: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (input: UpdateServiceInput) =>
      apiPatch<CatalogService>(`/catalog/services/${serviceId}`, input),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: [MASTER_DATA_QUERY_KEY, "services"] });
      queryClient.invalidateQueries({ queryKey: [MASTER_DATA_QUERY_KEY, "prices"] });
    },
  });
}

export function useCreateServicePrice() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (input: CreateServicePriceInput) =>
      apiPost<ServicePrice>("/catalog/prices", input),
    onSuccess: () =>
      queryClient.invalidateQueries({ queryKey: [MASTER_DATA_QUERY_KEY, "prices"] }),
  });
}

export function useUpdateServicePrice(priceId: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (input: Partial<CreateServicePriceInput> & { isActive?: boolean }) =>
      apiPatch<ServicePrice>(`/catalog/prices/${priceId}`, input),
    onSuccess: () =>
      queryClient.invalidateQueries({ queryKey: [MASTER_DATA_QUERY_KEY, "prices"] }),
  });
}

export function useNumberingConfigurations() {
  return useQuery({
    queryKey: [MASTER_DATA_QUERY_KEY, "numbering"],
    queryFn: () => apiGet<NumberingSequence[]>("/numbering"),
  });
}

export function useUpdateNumbering(type: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (input: UpdateNumberingInput) =>
      apiPatch<NumberingSequence>(`/numbering/${type}`, input),
    onSuccess: () =>
      queryClient.invalidateQueries({ queryKey: [MASTER_DATA_QUERY_KEY, "numbering"] }),
  });
}

export function usePaymentMethods(includeInactive = true) {
  return useQuery({
    queryKey: [MASTER_DATA_QUERY_KEY, "payment-methods", includeInactive],
    queryFn: () =>
      apiGet<PaymentMethod[]>("/payment-methods", {
        includeInactive: includeInactive ? "true" : "false",
      }),
  });
}

export function useUpdatePaymentMethod(methodId: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (input: UpdatePaymentMethodInput) =>
      apiPatch<PaymentMethod>(`/payment-methods/${methodId}`, input),
    onSuccess: () =>
      queryClient.invalidateQueries({
        queryKey: [MASTER_DATA_QUERY_KEY, "payment-methods"],
      }),
  });
}

export function useExpenseCategories(includeInactive = true) {
  return useQuery({
    queryKey: [MASTER_DATA_QUERY_KEY, "expense-categories", includeInactive],
    queryFn: () =>
      apiGet<ExpenseCategory[]>("/expense-categories", {
        includeInactive: includeInactive ? "true" : "false",
      }),
  });
}

export function useCreateExpenseCategory() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (input: CreateExpenseCategoryInput) =>
      apiPost<ExpenseCategory>("/expense-categories", input),
    onSuccess: () =>
      queryClient.invalidateQueries({
        queryKey: [MASTER_DATA_QUERY_KEY, "expense-categories"],
      }),
  });
}

export function useUpdateExpenseCategory(categoryId: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (input: UpdateExpenseCategoryInput) =>
      apiPatch<ExpenseCategory>(`/expense-categories/${categoryId}`, input),
    onSuccess: () =>
      queryClient.invalidateQueries({
        queryKey: [MASTER_DATA_QUERY_KEY, "expense-categories"],
      }),
  });
}

export function useDeleteExpenseCategory() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (categoryId: string) =>
      apiDelete<ExpenseCategory>(`/expense-categories/${categoryId}`),
    onSuccess: () =>
      queryClient.invalidateQueries({
        queryKey: [MASTER_DATA_QUERY_KEY, "expense-categories"],
      }),
  });
}
