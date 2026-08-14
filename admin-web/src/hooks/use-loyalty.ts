import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { apiDelete, apiGet, apiPatch, apiPost } from "@/lib/api";
import type { Paginated } from "@/types/api";
import type {
  CreateRewardCatalogInput,
  CustomerLoyalty,
  LoyaltySettings,
  LoyaltyVoucher,
  MembershipSummary,
  RewardCatalogItem,
  RewardHistoryItem,
  RewardSummary,
  UpdateRewardCatalogInput,
  VoucherListParams,
  WalletDashboard,
  WalletHistoryParams,
  WalletSummary,
  WalletTransaction,
} from "@/types/loyalty";

export const LOYALTY_QUERY_KEY = "loyalty";

export function useWalletDashboard() {
  return useQuery({
    queryKey: [LOYALTY_QUERY_KEY, "wallet-dashboard"],
    queryFn: () => apiGet<WalletDashboard>("/wallet"),
  });
}

export function useCustomerWallet(customerId: string) {
  return useQuery({
    queryKey: [LOYALTY_QUERY_KEY, "wallet", customerId],
    queryFn: () =>
      apiGet<WalletSummary>("/wallet", { customerId }),
    enabled: Boolean(customerId),
  });
}

export function useWalletHistory(params: WalletHistoryParams) {
  return useQuery({
    queryKey: [LOYALTY_QUERY_KEY, "wallet-history", params],
    queryFn: () =>
      apiGet<Paginated<WalletTransaction>>(
        "/wallet/history",
        params as Record<string, unknown>,
      ),
  });
}

export function useRewardSummary(customerId: string) {
  return useQuery({
    queryKey: [LOYALTY_QUERY_KEY, "reward", customerId],
    queryFn: () =>
      apiGet<RewardSummary>("/reward", { customerId }),
    enabled: Boolean(customerId),
  });
}

export function useRewardHistory(params: {
  page?: number;
  limit?: number;
  customerId?: string;
}) {
  return useQuery({
    queryKey: [LOYALTY_QUERY_KEY, "reward-history", params],
    queryFn: () =>
      apiGet<Paginated<RewardHistoryItem>>(
        "/reward/history",
        params as Record<string, unknown>,
      ),
  });
}

export function useMembership(customerId: string) {
  return useQuery({
    queryKey: [LOYALTY_QUERY_KEY, "membership", customerId],
    queryFn: () =>
      apiGet<MembershipSummary>("/membership", { customerId }),
    enabled: Boolean(customerId),
  });
}

export function useCustomerLoyalty(customerId: string) {
  return useQuery({
    queryKey: [LOYALTY_QUERY_KEY, "customer", customerId],
    queryFn: () =>
      apiGet<CustomerLoyalty>(`/customers/${customerId}/loyalty`),
    enabled: Boolean(customerId),
  });
}

export function useLoyaltySettings() {
  return useQuery({
    queryKey: [LOYALTY_QUERY_KEY, "settings"],
    queryFn: () => apiGet<LoyaltySettings>("/loyalty/settings"),
  });
}

export function useVouchers(params: VoucherListParams) {
  return useQuery({
    queryKey: [LOYALTY_QUERY_KEY, "vouchers", params],
    queryFn: () =>
      apiGet<Paginated<LoyaltyVoucher>>(
        "/voucher",
        params as Record<string, unknown>,
      ),
  });
}

export function useUpdateLoyaltySettings() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (input: Partial<LoyaltySettings>) =>
      apiPatch<LoyaltySettings>("/loyalty/settings", input),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: [LOYALTY_QUERY_KEY] });
    },
  });
}

export function useWalletTopup() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (input: {
      customerId: string;
      amount: number;
      notes?: string;
    }) => apiPost("/wallet/topup", input),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: [LOYALTY_QUERY_KEY] });
    },
  });
}

export function useWalletAdjustment() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (input: {
      customerId: string;
      amount: number;
      direction: "INCREASE" | "DECREASE";
      notes?: string;
    }) => apiPost("/wallet/adjustment", input),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: [LOYALTY_QUERY_KEY] });
    },
  });
}

export function useCreateVoucher() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (input: Partial<LoyaltyVoucher> & {
      code: string;
      name: string;
      discountType: "PERCENTAGE" | "FIXED";
      discountValue?: number;
      discountPercent?: number;
      startDate: string;
      endDate: string;
    }) => apiPost<LoyaltyVoucher>("/voucher", input),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: [LOYALTY_QUERY_KEY, "vouchers"] });
    },
  });
}

export function useUpdateVoucher() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (params: {
      id: string;
      input: Partial<LoyaltyVoucher> & {
        discountPercent?: number;
        discountType?: "PERCENTAGE" | "FIXED";
      };
    }) => apiPatch<LoyaltyVoucher>(`/voucher/${params.id}`, params.input),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: [LOYALTY_QUERY_KEY, "vouchers"] });
    },
  });
}

export function useManualBonus() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (input: {
      customerId: string;
      point: number;
      description?: string;
    }) => apiPost("/reward/bonus", input),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: [LOYALTY_QUERY_KEY] });
    },
  });
}

export function useRewardCatalog(includeInactive = true) {
  return useQuery({
    queryKey: [LOYALTY_QUERY_KEY, "reward-catalog", includeInactive],
    queryFn: () =>
      apiGet<RewardCatalogItem[]>("/loyalty/rewards/catalog", {
        includeInactive: includeInactive ? "true" : "false",
      }),
  });
}

export function useCreateRewardCatalogItem() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (input: CreateRewardCatalogInput) =>
      apiPost<RewardCatalogItem>("/loyalty/rewards/catalog", input),
    onSuccess: () => {
      queryClient.invalidateQueries({
        queryKey: [LOYALTY_QUERY_KEY, "reward-catalog"],
      });
    },
  });
}

export function useUpdateRewardCatalogItem(itemId: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (input: UpdateRewardCatalogInput) =>
      apiPatch<RewardCatalogItem>(`/loyalty/rewards/catalog/${itemId}`, input),
    onSuccess: () => {
      queryClient.invalidateQueries({
        queryKey: [LOYALTY_QUERY_KEY, "reward-catalog"],
      });
    },
  });
}

export function useDeleteRewardCatalogItem() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (itemId: string) =>
      apiDelete<{ id: string; deleted: boolean }>(
        `/loyalty/rewards/catalog/${itemId}`,
      ),
    onSuccess: () => {
      queryClient.invalidateQueries({
        queryKey: [LOYALTY_QUERY_KEY, "reward-catalog"],
      });
    },
  });
}
