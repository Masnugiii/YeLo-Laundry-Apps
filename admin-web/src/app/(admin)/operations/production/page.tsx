"use client";

import { useEffect, useState } from "react";
import { KanbanBoard } from "@/components/production/kanban-board";
import { ProductionKpiCards } from "@/components/production/kpi-cards";
import {
  EmptyState,
  ProductionListSkeleton,
  QueryErrorState,
} from "@/components/production/list-states";
import { ProductionTable } from "@/components/production/production-table";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { useEmployees } from "@/hooks/use-employees";
import {
  useProductionDashboard,
  useProductionOrders,
} from "@/hooks/use-production";
import { getErrorMessage } from "@/lib/errors";
import {
  PRIORITY_OPTIONS,
  PRODUCTION_STATUS_OPTIONS,
  STAGE_LABELS,
} from "@/lib/production-stages";
import type { ProductionListParams } from "@/types/production";

const PAGE_SIZES = [10, 25, 50, 100] as const;

export default function ProductionPage() {
  const [view, setView] = useState<"kanban" | "table">("kanban");
  const [searchInput, setSearchInput] = useState("");
  const [search, setSearch] = useState("");
  const [status, setStatus] = useState("");
  const [employeeId, setEmployeeId] = useState("");
  const [priority, setPriority] = useState("");
  const [service, setService] = useState("");
  const [date, setDate] = useState("");
  const [delayStatus, setDelayStatus] = useState("");
  const [page, setPage] = useState(1);
  const [limit, setLimit] = useState<(typeof PAGE_SIZES)[number]>(50);

  useEffect(() => {
    const timer = window.setTimeout(() => {
      setSearch(searchInput.trim());
      setPage(1);
    }, 300);
    return () => window.clearTimeout(timer);
  }, [searchInput]);

  const params: ProductionListParams = {
    page,
    limit,
    ...(search ? { search } : {}),
    ...(status ? { status: status as ProductionListParams["status"] } : {}),
    ...(employeeId ? { employeeId } : {}),
    ...(priority ? { priority: priority as ProductionListParams["priority"] } : {}),
    ...(service ? { service } : {}),
    ...(date ? { date } : {}),
    ...(delayStatus
      ? { delayStatus: delayStatus as ProductionListParams["delayStatus"] }
      : {}),
  };

  const dashboardQuery = useProductionDashboard();
  const ordersQuery = useProductionOrders(params);
  const employeesQuery = useEmployees({ page: 1, limit: 100, status: "ACTIVE" });

  const orders = ordersQuery.data?.items ?? [];
  const meta = ordersQuery.data?.meta;
  const hasFilters = Boolean(
    search || status || employeeId || priority || service || date || delayStatus,
  );

  if (dashboardQuery.isLoading || ordersQuery.isLoading) {
    return <ProductionListSkeleton />;
  }

  if (dashboardQuery.isError || ordersQuery.isError) {
    return (
      <QueryErrorState
        title="Failed to load production data"
        message={getErrorMessage(
          dashboardQuery.error ?? ordersQuery.error,
          "Unable to fetch production dashboard or orders.",
        )}
        onRetry={() => {
          void dashboardQuery.refetch();
          void ordersQuery.refetch();
        }}
      />
    );
  }

  return (
    <div className="space-y-6">
      {dashboardQuery.data ? <ProductionKpiCards data={dashboardQuery.data} /> : null}

      <div className="flex flex-wrap items-center justify-between gap-3">
        <div className="inline-flex rounded-lg border border-slate-200 p-1 dark:border-slate-800">
          <Button
            variant={view === "kanban" ? "default" : "ghost"}
            size="sm"
            onClick={() => setView("kanban")}
          >
            Kanban
          </Button>
          <Button
            variant={view === "table" ? "default" : "ghost"}
            size="sm"
            onClick={() => setView("table")}
          >
            Table
          </Button>
        </div>
        {dashboardQuery.data?.delayed ? (
          <p className="text-sm font-medium text-red-600">
            {dashboardQuery.data.delayed} order(s) exceed SLA
          </p>
        ) : null}
      </div>

      <div className="grid gap-3 xl:grid-cols-4">
        <Input
          className="xl:col-span-2"
          placeholder="Search order number, customer, or phone"
          value={searchInput}
          onChange={(event) => setSearchInput(event.target.value)}
        />
        <select
          className="h-10 rounded-lg border border-slate-200 bg-white px-3 text-sm dark:border-slate-700 dark:bg-slate-900"
          value={status}
          onChange={(event) => {
            setStatus(event.target.value);
            setPage(1);
          }}
        >
          <option value="">All stages</option>
          {PRODUCTION_STATUS_OPTIONS.map((item) => (
            <option key={item} value={item}>
              {STAGE_LABELS[item]}
            </option>
          ))}
        </select>
        <select
          className="h-10 rounded-lg border border-slate-200 bg-white px-3 text-sm dark:border-slate-700 dark:bg-slate-900"
          value={employeeId}
          onChange={(event) => {
            setEmployeeId(event.target.value);
            setPage(1);
          }}
        >
          <option value="">All employees</option>
          {(employeesQuery.data?.items ?? []).map((employee) => (
            <option key={employee.id} value={employee.id}>
              {employee.fullName}
            </option>
          ))}
        </select>
        <select
          className="h-10 rounded-lg border border-slate-200 bg-white px-3 text-sm dark:border-slate-700 dark:bg-slate-900"
          value={priority}
          onChange={(event) => {
            setPriority(event.target.value);
            setPage(1);
          }}
        >
          <option value="">All priorities</option>
          {PRIORITY_OPTIONS.map((item) => (
            <option key={item} value={item}>
              {item}
            </option>
          ))}
        </select>
        <Input
          placeholder="Filter by service"
          value={service}
          onChange={(event) => {
            setService(event.target.value);
            setPage(1);
          }}
        />
        <Input
          type="date"
          value={date}
          onChange={(event) => {
            setDate(event.target.value);
            setPage(1);
          }}
        />
        <select
          className="h-10 rounded-lg border border-slate-200 bg-white px-3 text-sm dark:border-slate-700 dark:bg-slate-900"
          value={delayStatus}
          onChange={(event) => {
            setDelayStatus(event.target.value);
            setPage(1);
          }}
        >
          <option value="">All SLA status</option>
          <option value="delayed">Delayed</option>
          <option value="on_track">On track</option>
        </select>
      </div>

      {orders.length === 0 ? (
        <EmptyState
          title="No production orders found"
          description={
            hasFilters
              ? "Try adjusting your search or filters."
              : "Production orders will appear here once laundry orders are received."
          }
        />
      ) : view === "kanban" ? (
        <KanbanBoard orders={orders} />
      ) : (
        <ProductionTable orders={orders} />
      )}

      {view === "table" && meta ? (
        <div className="flex flex-wrap items-center justify-between gap-3">
          <p className="text-sm text-slate-500">
            Page {meta.page} of {meta.totalPages} ({meta.total} orders)
          </p>
          <div className="flex flex-wrap items-center gap-2">
            <select
              className="h-9 rounded-lg border border-slate-200 bg-white px-3 text-sm dark:border-slate-700 dark:bg-slate-900"
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
