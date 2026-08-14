import { useQuery } from "@tanstack/react-query";
import { apiGet } from "@/lib/api";
import type { OrderReceiptDelivery } from "@/types/order-receipt";
import { ORDERS_QUERY_KEY } from "./use-orders";

export function orderReceiptsQueryKey(orderId: string) {
  return [ORDERS_QUERY_KEY, "receipts", orderId] as const;
}

export function useOrderReceiptDeliveries(orderId: string) {
  return useQuery({
    queryKey: orderReceiptsQueryKey(orderId),
    queryFn: () => apiGet<OrderReceiptDelivery[]>(`/orders/${orderId}/receipts`),
    enabled: Boolean(orderId),
  });
}
