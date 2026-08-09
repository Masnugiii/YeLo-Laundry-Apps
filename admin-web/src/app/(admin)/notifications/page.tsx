"use client";

import { useEffect, useState } from "react";
import {
  EmptyState,
  FinanceListSkeleton,
  QueryErrorState,
} from "@/components/finance/list-states";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import {
  useMarkAllNotificationsRead,
  useMarkNotificationRead,
  useNotifications,
  useUnreadNotificationCount,
} from "@/hooks/use-notifications";
import { getErrorMessage } from "@/lib/errors";
import { formatDate } from "@/lib/utils";
import type { NotificationListParams } from "@/types/notifications";

const PAGE_SIZES = [10, 25, 50] as const;

export default function NotificationsPage() {
  const [page, setPage] = useState(1);
  const [limit, setLimit] = useState<(typeof PAGE_SIZES)[number]>(25);
  const [readFilter, setReadFilter] = useState<"" | "read" | "unread">("");

  const params: NotificationListParams = {
    page,
    limit,
    ...(readFilter === "read"
      ? { isRead: true }
      : readFilter === "unread"
        ? { isRead: false }
        : {}),
  };

  const listQuery = useNotifications(params);
  const unreadQuery = useUnreadNotificationCount();
  const markReadMutation = useMarkNotificationRead();
  const markAllReadMutation = useMarkAllNotificationsRead();

  const items = listQuery.data?.items ?? [];
  const meta = listQuery.data?.meta;

  useEffect(() => {
    setPage(1);
  }, [readFilter]);

  if (listQuery.isLoading) {
    return <FinanceListSkeleton />;
  }

  if (listQuery.isError) {
    return (
      <QueryErrorState
        title="Failed to load notifications"
        message={getErrorMessage(listQuery.error, "Unable to fetch notifications.")}
        onRetry={() => void listQuery.refetch()}
      />
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <div>
          <h1 className="text-2xl font-semibold">Notifications</h1>
          <p className="text-sm text-muted-foreground">
            Unread: {unreadQuery.data?.count ?? 0}
          </p>
        </div>
        <Button
          variant="outline"
          disabled={markAllReadMutation.isPending}
          onClick={() => markAllReadMutation.mutate()}
        >
          Mark all read
        </Button>
      </div>

      <div className="flex flex-wrap gap-3">
        <select
          className="h-10 rounded-md border border-input bg-background px-3 text-sm"
          value={readFilter}
          onChange={(event) =>
            setReadFilter(event.target.value as "" | "read" | "unread")
          }
        >
          <option value="">All</option>
          <option value="unread">Unread</option>
          <option value="read">Read</option>
        </select>
      </div>

      {items.length === 0 ? (
        <EmptyState
          title="No notifications"
          description="Notifications from the system will appear here."
        />
      ) : (
        <div className="overflow-x-auto rounded-lg border">
          <table className="min-w-full text-sm">
            <thead className="bg-muted/50 text-left">
              <tr>
                <th className="px-4 py-3">Title</th>
                <th className="px-4 py-3">Message</th>
                <th className="px-4 py-3">Type</th>
                <th className="px-4 py-3">Read</th>
                <th className="px-4 py-3">Created</th>
                <th className="px-4 py-3">Action</th>
              </tr>
            </thead>
            <tbody>
              {items.map((item) => (
                <tr key={item.id} className="border-t">
                  <td className="px-4 py-3 font-medium">{item.title}</td>
                  <td className="px-4 py-3 max-w-md truncate">{item.message}</td>
                  <td className="px-4 py-3">{item.type}</td>
                  <td className="px-4 py-3">{item.isRead ? "Yes" : "No"}</td>
                  <td className="px-4 py-3">{formatDate(item.createdAt)}</td>
                  <td className="px-4 py-3">
                    {!item.isRead ? (
                      <Button
                        size="sm"
                        variant="outline"
                        disabled={markReadMutation.isPending}
                        onClick={() => markReadMutation.mutate(item.id)}
                      >
                        Mark read
                      </Button>
                    ) : (
                      <span className="text-muted-foreground">-</span>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {meta ? (
        <div className="flex flex-wrap items-center justify-between gap-3">
          <p className="text-sm text-muted-foreground">
            Page {meta.page} of {meta.totalPages} ({meta.total} notifications)
          </p>
          <div className="flex items-center gap-2">
            <select
              className="h-9 rounded-md border border-input bg-background px-2 text-sm"
              value={limit}
              onChange={(event) => {
                setLimit(Number(event.target.value) as (typeof PAGE_SIZES)[number]);
                setPage(1);
              }}
            >
              {PAGE_SIZES.map((size) => (
                <option key={size} value={size}>
                  {size} / page
                </option>
              ))}
            </select>
            <Button
              variant="outline"
              size="sm"
              disabled={page <= 1}
              onClick={() => setPage((current) => current - 1)}
            >
              Previous
            </Button>
            <Button
              variant="outline"
              size="sm"
              disabled={page >= meta.totalPages}
              onClick={() => setPage((current) => current + 1)}
            >
              Next
            </Button>
          </div>
        </div>
      ) : null}
    </div>
  );
}
