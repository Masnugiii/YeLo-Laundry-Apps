import { useQuery } from "@tanstack/react-query";

import { apiGet } from "@/lib/api";
import type { StorageDashboard, StorageLockerSummary } from "@/types/laci-laundry";

const LACI_QUERY_KEY = "laci-laundry";

export function useLaciLaundryDashboard() {
  return useQuery({
    queryKey: [LACI_QUERY_KEY, "dashboard"],
    queryFn: () => apiGet<StorageDashboard>("/storage/dashboard"),
  });
}

export function useLaciLaundryLockers() {
  return useQuery({
    queryKey: [LACI_QUERY_KEY, "lockers"],
    queryFn: () => apiGet<StorageLockerSummary[]>("/storage/lockers"),
  });
}

export function useLaciLaundrySearch(params: {
  q?: string;
  lockerCode?: string;
  status?: string;
}) {
  return useQuery({
    queryKey: [LACI_QUERY_KEY, "search", params],
    queryFn: () =>
      apiGet<{ items: StorageLockerSummary["boxes"]; meta: { total: number } }>(
        "/storage/boxes/search",
        params,
      ),
  });
}
