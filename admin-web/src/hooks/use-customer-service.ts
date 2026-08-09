import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { apiGet, apiPatch, apiPost } from "@/lib/api";
import type { Paginated } from "@/types/api";
import type {
  CreateCustomerServiceMessageInput,
  CustomerServiceListParams,
  CustomerServiceSummary,
  CustomerServiceTicket,
  CustomerServiceTicketDetail,
  UpdateCustomerServiceTicketInput,
} from "@/types/customer-service";

export const CUSTOMER_SERVICE_QUERY_KEY = "customer-service";

export function useCustomerServiceSummary() {
  return useQuery({
    queryKey: [CUSTOMER_SERVICE_QUERY_KEY, "summary"],
    queryFn: () => apiGet<CustomerServiceSummary>("/customer-service/summary"),
  });
}

export function useCustomerServiceTickets(params: CustomerServiceListParams) {
  return useQuery({
    queryKey: [CUSTOMER_SERVICE_QUERY_KEY, "tickets", params],
    queryFn: () =>
      apiGet<Paginated<CustomerServiceTicket>>(
        "/customer-service/tickets",
        params as Record<string, unknown>,
      ),
  });
}

export function useCustomerServiceTicket(id: string) {
  return useQuery({
    queryKey: [CUSTOMER_SERVICE_QUERY_KEY, "ticket", id],
    queryFn: () =>
      apiGet<CustomerServiceTicketDetail>(`/customer-service/tickets/${id}`),
    enabled: Boolean(id),
  });
}

export function useUpdateCustomerServiceTicket(id: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (input: UpdateCustomerServiceTicketInput) =>
      apiPatch<CustomerServiceTicketDetail>(
        `/customer-service/tickets/${id}`,
        input,
      ),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: [CUSTOMER_SERVICE_QUERY_KEY] });
    },
  });
}

export function useReplyCustomerServiceTicket(id: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (input: CreateCustomerServiceMessageInput) =>
      apiPost<CustomerServiceTicketDetail>(
        `/customer-service/tickets/${id}/messages`,
        input,
      ),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: [CUSTOMER_SERVICE_QUERY_KEY] });
    },
  });
}
