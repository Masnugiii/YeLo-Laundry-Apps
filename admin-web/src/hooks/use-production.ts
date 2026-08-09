import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { apiGet, apiPost } from "@/lib/api";
import type { Paginated } from "@/types/api";
import type {
  ProductionActionInput,
  ProductionActionKind,
  ProductionDashboard,
  ProductionDetail,
  ProductionListItem,
  ProductionListParams,
  QualityCheckInput,
} from "@/types/production";

export const PRODUCTION_QUERY_KEY = "production";

export function productionDashboardQueryKey() {
  return [PRODUCTION_QUERY_KEY, "dashboard"] as const;
}

export function productionListQueryKey(params: ProductionListParams = {}) {
  return [PRODUCTION_QUERY_KEY, "list", params] as const;
}

export function productionDetailQueryKey(orderId: string) {
  return [PRODUCTION_QUERY_KEY, "detail", orderId] as const;
}

export function useProductionDashboard() {
  return useQuery({
    queryKey: productionDashboardQueryKey(),
    queryFn: () => apiGet<ProductionDashboard>("/laundry/dashboard"),
  });
}

export function useProductionOrders(params: ProductionListParams) {
  return useQuery({
    queryKey: productionListQueryKey(params),
    queryFn: () =>
      apiGet<Paginated<ProductionListItem>>(
        "/laundry/orders",
        params as Record<string, unknown>,
      ),
  });
}

export function useProductionOrder(orderId: string) {
  return useQuery({
    queryKey: productionDetailQueryKey(orderId),
    queryFn: () => apiGet<ProductionDetail>(`/laundry/orders/${orderId}`),
    enabled: Boolean(orderId),
  });
}

function invalidateProduction(queryClient: ReturnType<typeof useQueryClient>) {
  queryClient.invalidateQueries({ queryKey: [PRODUCTION_QUERY_KEY] });
}

export function useProductionAction(orderId: string) {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({
      action,
      input,
    }: {
      action: ProductionActionKind;
      input?: ProductionActionInput;
    }) => runProductionAction(orderId, action, input),
    onSuccess: () => invalidateProduction(queryClient),
  });
}

export function useProductionStageMutation() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({
      orderId,
      action,
      input,
    }: {
      orderId: string;
      action: ProductionActionKind;
      input?: ProductionActionInput;
    }) => runProductionAction(orderId, action, input),
    onSuccess: () => invalidateProduction(queryClient),
  });
}

async function runProductionAction(
  orderId: string,
  action: ProductionActionKind,
  input?: ProductionActionInput,
) {
  if (action === "quality-check") {
    throw new Error("Use useQualityCheck for quality check actions");
  }

  const pathMap: Record<
    Exclude<ProductionActionKind, "quality-check">,
    string
  > = {
    "start-washing": "start-washing",
    "finish-washing": "finish-washing",
    "start-drying": "start-drying",
    "finish-drying": "finish-drying",
    "start-ironing": "start-ironing",
    "finish-ironing": "finish-ironing",
    ready: "ready",
  };

  return apiPost<ProductionDetail>(
    `/laundry/orders/${orderId}/${pathMap[action]}`,
    input ?? {},
  );
}

export function useQualityCheck(orderId: string) {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (input: QualityCheckInput) =>
      apiPost<ProductionDetail>(
        `/laundry/orders/${orderId}/quality-check`,
        input,
      ),
    onSuccess: () => invalidateProduction(queryClient),
  });
}
