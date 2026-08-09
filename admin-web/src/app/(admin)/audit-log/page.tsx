"use client";

import { ColumnDef } from "@tanstack/react-table";
import { DataTable } from "@/components/data-table";
import { useQuery } from "@tanstack/react-query";
import { apiGet } from "@/lib/api";
import type { Paginated } from "@/types/api";
import { formatDate } from "@/lib/utils";

interface AuditRow {
  id: string;
  employeeName: string | null;
  module: string;
  action: string;
  description: string | null;
  createdAt: string;
}

const columns: ColumnDef<AuditRow, unknown>[] = [
  { accessorKey: "module", header: "Module" },
  { accessorKey: "action", header: "Action" },
  { accessorKey: "employeeName", header: "Employee" },
  { accessorKey: "description", header: "Description" },
  {
    accessorKey: "createdAt",
    header: "Time",
    cell: ({ row }) => formatDate(row.original.createdAt),
  },
];

export default function AuditLogPage() {
  const { data, isLoading } = useQuery({
    queryKey: ["audit-logs"],
    queryFn: () => apiGet<Paginated<AuditRow>>("/admin/audit-logs", { page: 1, limit: 100 }),
  });

  return (
    <DataTable
      columns={columns}
      data={data?.items ?? []}
      exportFilename="audit-logs.csv"
      loading={isLoading}
    />
  );
}
