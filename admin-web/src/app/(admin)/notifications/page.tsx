"use client";

import { ColumnDef } from "@tanstack/react-table";
import { ModuleListPage } from "@/components/module-list-page";

interface NotificationRow {
  id: string;
  title: string;
  message: string;
  type: string;
  isRead: boolean;
  createdAt: string;
}

const columns: ColumnDef<NotificationRow, unknown>[] = [
  { accessorKey: "title", header: "Title" },
  { accessorKey: "message", header: "Message" },
  { accessorKey: "type", header: "Type" },
  {
    accessorKey: "isRead",
    header: "Read",
    cell: ({ row }) => (row.original.isRead ? "Yes" : "No"),
  },
  { accessorKey: "createdAt", header: "Created" },
];

export default function NotificationsPage() {
  return (
    <ModuleListPage<NotificationRow>
      title="Notifications"
      endpoint="/notifications"
      exportFilename="notifications.csv"
      columns={columns}
    />
  );
}
