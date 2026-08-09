import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { apiGet, apiPost } from "@/lib/api";
import type { Paginated } from "@/types/api";
import type {
  NotificationItem,
  NotificationListParams,
  NotificationUnreadCount,
} from "@/types/notifications";

export const NOTIFICATIONS_QUERY_KEY = "notifications";

export function useNotifications(params: NotificationListParams) {
  return useQuery({
    queryKey: [NOTIFICATIONS_QUERY_KEY, "list", params],
    queryFn: () =>
      apiGet<Paginated<NotificationItem>>(
        "/notifications",
        params as Record<string, unknown>,
      ),
  });
}

export function useUnreadNotificationCount() {
  return useQuery({
    queryKey: [NOTIFICATIONS_QUERY_KEY, "unread-count"],
    queryFn: () => apiGet<NotificationUnreadCount>("/notifications/unread-count"),
  });
}

export function useMarkNotificationRead() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => apiPost<NotificationItem>(`/notifications/${id}/read`),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: [NOTIFICATIONS_QUERY_KEY] });
    },
  });
}

export function useMarkAllNotificationsRead() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: () => apiPost<{ updated: number }>("/notifications/read-all"),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: [NOTIFICATIONS_QUERY_KEY] });
    },
  });
}
