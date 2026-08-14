"use client";

import { useEffect, useState } from "react";
import {
  NotificationPriorityBadge,
  NotificationReadBadge,
  NotificationTypeBadge,
} from "@/components/notifications/notification-badges";
import {
  EmptyState,
  NotificationListSkeleton,
  QueryErrorState,
} from "@/components/notifications/list-states";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
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
const selectClassName =
  "h-10 rounded-lg border border-slate-200 bg-white px-3 text-sm outline-none ring-blue-500 focus:ring-2 dark:border-slate-700 dark:bg-slate-900";

export default function NotificationsPage() {
  const [page, setPage] = useState(1);
  const [limit, setLimit] = useState<(typeof PAGE_SIZES)[number]>(25);
  const [readFilter, setReadFilter] = useState<"" | "read" | "unread">("");
  const [typeFilter, setTypeFilter] = useState("");

  const params: NotificationListParams = {
    page,
    limit,
    ...(readFilter === "read"
      ? { isRead: true }
      : readFilter === "unread"
        ? { isRead: false }
        : {}),
    ...(typeFilter ? { type: typeFilter } : {}),
  };

  const listQuery = useNotifications(params);
  const unreadQuery = useUnreadNotificationCount();
  const markReadMutation = useMarkNotificationRead();
  const markAllReadMutation = useMarkAllNotificationsRead();

  const items = listQuery.data?.items ?? [];
  const meta = listQuery.data?.meta;
  const hasFilters = Boolean(readFilter || typeFilter);

  useEffect(() => {
    setPage(1);
  }, [readFilter, typeFilter]);

  if (listQuery.isLoading) {
    return <NotificationListSkeleton />;
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
    <div className="space-y-4">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <p className="text-sm text-slate-500">
          {unreadQuery.isError
            ? "Unread count unavailable"
            : `Unread: ${unreadQuery.data?.count ?? 0}`}
        </p>
        <Button
          variant="outline"
          disabled={markAllReadMutation.isPending}
          onClick={() => markAllReadMutation.mutate()}
        >
          Mark all read
        </Button>
      </div>

      <div className="grid gap-3 md:grid-cols-3">
        <select
          className={selectClassName}
          value={readFilter}
          onChange={(event) =>
            setReadFilter(event.target.value as "" | "read" | "unread")
          }
        >
          <option value="">All read states</option>
          <option value="unread">Unread</option>
          <option value="read">Read</option>
        </select>
        <select
          className={selectClassName}
          value={typeFilter}
          onChange={(event) => setTypeFilter(event.target.value)}
        >
          <option value="">All types</option>
          <option value="ORDER">Order</option>
          <option value="PAYMENT">Payment</option>
          <option value="SYSTEM">System</option>
          <option value="CUSTOMER">Customer</option>
          <option value="ATTENDANCE">Attendance</option>
        </select>
      </div>

      {items.length === 0 ? (
        <EmptyState
          title="No notifications"
          description={
            hasFilters
              ? "No notifications match the current filters."
              : "Notifications from the system will appear here."
          }
        />
      ) : (
        <>
          <div className="hidden overflow-hidden rounded-xl border border-slate-200 bg-white dark:border-slate-800 dark:bg-slate-900 md:block">
            <table className="min-w-full text-sm">
              <thead className="bg-slate-50 text-left text-xs font-semibold uppercase tracking-wide text-slate-500 dark:bg-slate-900/60">
                <tr>
                  <th className="px-4 py-3">Title</th>
                  <th className="px-4 py-3">Message</th>
                  <th className="px-4 py-3">Type</th>
                  <th className="px-4 py-3">Priority</th>
                  <th className="px-4 py-3">Read</th>
                  <th className="px-4 py-3">Created</th>
                  <th className="px-4 py-3">Action</th>
                </tr>
              </thead>
              <tbody>
                {items.map((item) => (
                  <tr
                    key={item.id}
                    className="border-t border-slate-100 dark:border-slate-800"
                  >
                    <td className="px-4 py-3 font-medium">{item.title}</td>
                    <td className="max-w-md truncate px-4 py-3">{item.message}</td>
                    <td className="px-4 py-3">
                      <NotificationTypeBadge type={item.type} />
                    </td>
                    <td className="px-4 py-3">
                      <NotificationPriorityBadge priority={item.priority} />
                    </td>
                    <td className="px-4 py-3">
                      <NotificationReadBadge isRead={item.isRead} />
                    </td>
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
                        <span className="text-slate-400">-</span>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          <div className="grid gap-3 md:hidden">
            {items.map((item) => (
              <Card key={item.id} className="p-4">
                <div className="flex items-start justify-between gap-3">
                  <p className="font-semibold">{item.title}</p>
                  <NotificationReadBadge isRead={item.isRead} />
                </div>
                <p className="mt-2 text-sm text-slate-600 dark:text-slate-300">
                  {item.message}
                </p>
                <div className="mt-3 flex flex-wrap gap-2">
                  <NotificationTypeBadge type={item.type} />
                  <NotificationPriorityBadge priority={item.priority} />
                </div>
                <div className="mt-4 flex items-center justify-between">
                  <span className="text-xs text-slate-500">
                    {formatDate(item.createdAt)}
                  </span>
                  {!item.isRead ? (
                    <Button
                      size="sm"
                      variant="outline"
                      disabled={markReadMutation.isPending}
                      onClick={() => markReadMutation.mutate(item.id)}
                    >
                      Mark read
                    </Button>
                  ) : null}
                </div>
              </Card>
            ))}
          </div>
        </>
      )}

      {meta ? (
        <div className="flex flex-wrap items-center justify-between gap-3">
          <p className="text-sm text-slate-500">
            Page {meta.page} of {meta.totalPages} ({meta.total} notifications)
          </p>
          <div className="flex items-center gap-2">
            <select
              className={selectClassName}
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
