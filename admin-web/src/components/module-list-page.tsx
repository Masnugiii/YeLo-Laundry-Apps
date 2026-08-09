"use client";

import { useQuery } from "@tanstack/react-query";
import { ColumnDef } from "@tanstack/react-table";
import { DataTable } from "@/components/data-table";
import { apiGet } from "@/lib/api";
import type { Paginated } from "@/types/api";

interface ModuleListPageProps<T> {
  title: string;
  endpoint: string;
  exportFilename: string;
  columns: ColumnDef<T, unknown>[];
}

export function ModuleListPage<T>({
  endpoint,
  exportFilename,
  columns,
}: ModuleListPageProps<T>) {
  const { data, isLoading } = useQuery({
    queryKey: [endpoint],
    queryFn: () => apiGet<Paginated<T>>(endpoint, { page: 1, limit: 50 }),
  });

  return (
    <DataTable
      columns={columns}
      data={data?.items ?? []}
      exportFilename={exportFilename}
      loading={isLoading}
    />
  );
}
