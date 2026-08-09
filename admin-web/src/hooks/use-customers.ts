import {
  useMutation,
  useQuery,
  useQueryClient,
  type QueryKey,
} from "@tanstack/react-query";
import { api, apiDelete, apiGet, apiPatch, apiPost } from "@/lib/api";
import type { Paginated } from "@/types/api";
import type {
  CreateCustomerInput,
  Customer,
  CustomerBusinessSummary,
  CustomerImportResult,
  CustomerListParams,
  CustomerNote,
  DuplicateImportStrategy,
  ImportCustomerRow,
  OrderListItem,
  PaymentListItem,
  UpdateCustomerInput,
} from "@/types/customer";

export const CUSTOMERS_QUERY_KEY = "customers";

export function customersQueryKey(params: CustomerListParams = {}) {
  return [CUSTOMERS_QUERY_KEY, params] as const;
}

export function customerDetailQueryKey(id: string) {
  return [CUSTOMERS_QUERY_KEY, "detail", id] as const;
}

function patchCustomerCaches(
  queryClient: ReturnType<typeof useQueryClient>,
  customerId: string,
  patch: Partial<Customer>,
) {
  queryClient.setQueryData<Customer>(customerDetailQueryKey(customerId), (current) =>
    current ? { ...current, ...patch, updatedAt: new Date().toISOString() } : current,
  );

  queryClient.setQueriesData<Paginated<Customer>>(
    { queryKey: [CUSTOMERS_QUERY_KEY] },
    (current) => {
      if (!current) return current;
      return {
        ...current,
        items: current.items.map((customer) =>
          customer.id === customerId
            ? { ...customer, ...patch, updatedAt: new Date().toISOString() }
            : customer,
        ),
      };
    },
  );
}

export function useCustomers(params: CustomerListParams) {
  return useQuery({
    queryKey: customersQueryKey(params),
    queryFn: () =>
      apiGet<Paginated<Customer>>("/customers", params as Record<string, unknown>),
  });
}

export function useCustomer(id: string) {
  return useQuery({
    queryKey: customerDetailQueryKey(id),
    queryFn: () => apiGet<Customer>(`/customers/${id}`),
    enabled: Boolean(id),
  });
}

export function useCustomerSummary(id: string) {
  return useQuery({
    queryKey: [CUSTOMERS_QUERY_KEY, "summary", id],
    queryFn: () => apiGet<CustomerBusinessSummary>(`/customers/${id}/summary`),
    enabled: Boolean(id),
  });
}

export function useCustomerOrders(id: string) {
  return useQuery({
    queryKey: [CUSTOMERS_QUERY_KEY, "orders", id],
    queryFn: () =>
      apiGet<Paginated<OrderListItem>>("/orders", {
        customerId: id,
        page: 1,
        limit: 50,
      }),
    enabled: Boolean(id),
  });
}

export function useCustomerPayments(id: string) {
  return useQuery({
    queryKey: [CUSTOMERS_QUERY_KEY, "payments", id],
    queryFn: () =>
      apiGet<Paginated<PaymentListItem>>("/payments", {
        customerId: id,
        page: 1,
        limit: 50,
      }),
    enabled: Boolean(id),
  });
}

export function useCustomerNotes(id: string) {
  return useQuery({
    queryKey: [CUSTOMERS_QUERY_KEY, "notes", id],
    queryFn: () =>
      apiGet<Paginated<CustomerNote>>(`/customers/${id}/notes`, {
        page: 1,
        limit: 50,
      }),
    enabled: Boolean(id),
  });
}

export function useCreateCustomer() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (input: CreateCustomerInput) => {
      const customer = await apiPost<Customer>("/customers", {
        fullName: input.fullName,
        phone: input.phone,
        email: input.email,
        gender: input.gender,
        birthDate: input.birthDate,
        isActive: input.isActive ?? true,
      });

      if (input.address?.trim()) {
        await apiPost(`/customers/${customer.id}/addresses`, {
          recipientName: input.fullName,
          phone: input.phone,
          address: input.address.trim(),
          province: "N/A",
          city: "N/A",
          district: "N/A",
          isDefault: true,
        });
      }

      if (input.notes?.trim()) {
        await apiPost(`/customers/${customer.id}/notes`, {
          title: "Owner Note",
          note: input.notes.trim(),
          category: "OTHER",
        });
      }

      return customer;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: [CUSTOMERS_QUERY_KEY] });
    },
  });
}

export function useUpdateCustomer(id: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (input: UpdateCustomerInput) =>
      apiPatch<Customer>(`/customers/${id}`, input),
    onMutate: async (input) => {
      await queryClient.cancelQueries({ queryKey: customerDetailQueryKey(id) });
      const previousDetail = queryClient.getQueryData<Customer>(customerDetailQueryKey(id));
      const previousLists = queryClient.getQueriesData<Paginated<Customer>>({
        queryKey: [CUSTOMERS_QUERY_KEY],
      });
      patchCustomerCaches(queryClient, id, input as Partial<Customer>);
      return { previousDetail, previousLists };
    },
    onError: (_error, _input, context) => {
      if (context?.previousDetail) {
        queryClient.setQueryData(customerDetailQueryKey(id), context.previousDetail);
      }
      context?.previousLists.forEach(([key, data]) => {
        queryClient.setQueryData(key as QueryKey, data);
      });
    },
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: [CUSTOMERS_QUERY_KEY] });
    },
  });
}

export function useSetCustomerStatus(id: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (isActive: boolean) =>
      apiPatch<Customer>(`/customers/${id}/status`, { isActive }),
    onMutate: async (isActive) => {
      await queryClient.cancelQueries({ queryKey: customerDetailQueryKey(id) });
      const previousDetail = queryClient.getQueryData<Customer>(customerDetailQueryKey(id));
      const previousLists = queryClient.getQueriesData<Paginated<Customer>>({
        queryKey: [CUSTOMERS_QUERY_KEY],
      });
      patchCustomerCaches(queryClient, id, { isActive });
      return { previousDetail, previousLists };
    },
    onError: (_error, _input, context) => {
      if (context?.previousDetail) {
        queryClient.setQueryData(customerDetailQueryKey(id), context.previousDetail);
      }
      context?.previousLists.forEach(([key, data]) => {
        queryClient.setQueryData(key as QueryKey, data);
      });
    },
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: [CUSTOMERS_QUERY_KEY] });
    },
  });
}

export function useDeactivateCustomer(id: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: () => apiDelete<null>(`/customers/${id}`),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: [CUSTOMERS_QUERY_KEY] });
    },
  });
}

export function useImportCustomers() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (input: {
      duplicateStrategy: DuplicateImportStrategy;
      rows: ImportCustomerRow[];
    }) => apiPost<CustomerImportResult>("/customers/import", input),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: [CUSTOMERS_QUERY_KEY] });
    },
  });
}

export async function downloadCustomersExport(params: CustomerListParams) {
  const response = await api.get("/customers/export", {
    params,
    responseType: "blob",
  });
  const blob = new Blob([response.data], { type: "text/csv;charset=utf-8;" });
  const url = URL.createObjectURL(blob);
  const link = document.createElement("a");
  link.href = url;
  link.download = "customers.csv";
  link.click();
  URL.revokeObjectURL(url);
}
