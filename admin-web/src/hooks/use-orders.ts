import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { api, apiDelete, apiGet, apiPost } from "@/lib/api";
import type { Paginated } from "@/types/api";
import type { Customer } from "@/types/customer";
import type {
  OrderDetail,
  OrderListItem,
  OrderListParams,
  OrderPayment,
  RefundPaymentInput,
} from "@/types/order";

export const ORDERS_QUERY_KEY = "orders";

export function ordersQueryKey(params: OrderListParams = {}) {
  return [ORDERS_QUERY_KEY, params] as const;
}

export function orderDetailQueryKey(id: string) {
  return [ORDERS_QUERY_KEY, "detail", id] as const;
}

export function useOrders(params: OrderListParams) {
  return useQuery({
    queryKey: ordersQueryKey(params),
    queryFn: () =>
      apiGet<Paginated<OrderListItem>>("/orders", params as Record<string, unknown>),
  });
}

export function useOrder(id: string) {
  return useQuery({
    queryKey: orderDetailQueryKey(id),
    queryFn: () => apiGet<OrderDetail>(`/orders/${id}`),
    enabled: Boolean(id),
  });
}

export function useOrderCustomer(customerId: string) {
  return useQuery({
    queryKey: [ORDERS_QUERY_KEY, "customer", customerId],
    queryFn: () => apiGet<Customer>(`/customers/${customerId}`),
    enabled: Boolean(customerId),
  });
}

export function useOrderPayments(orderId: string) {
  return useQuery({
    queryKey: [ORDERS_QUERY_KEY, "payments", orderId],
    queryFn: () =>
      apiGet<Paginated<OrderPayment>>("/payments", {
        orderId,
        page: 1,
        limit: 50,
      }),
    enabled: Boolean(orderId),
  });
}

export function useCancelOrder(id: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (reason: string) => apiDelete<OrderDetail>(`/orders/${id}`, { reason }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: [ORDERS_QUERY_KEY] });
    },
  });
}

export function useRefundPayment(orderId: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({
      paymentId,
      input,
    }: {
      paymentId: string;
      input: RefundPaymentInput;
    }) => apiPost<OrderPayment>(`/payments/${paymentId}/refund`, input),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: [ORDERS_QUERY_KEY] });
      queryClient.invalidateQueries({ queryKey: [ORDERS_QUERY_KEY, "payments", orderId] });
    },
  });
}

export async function downloadOrdersExport(params: OrderListParams) {
  const response = await api.get("/orders/export", {
    params,
    responseType: "blob",
  });
  const blob = new Blob([response.data], { type: "text/csv;charset=utf-8;" });
  const url = URL.createObjectURL(blob);
  const link = document.createElement("a");
  link.href = url;
  link.download = "orders.csv";
  link.click();
  URL.revokeObjectURL(url);
}
