"use client";

import Link from "next/link";
import { useMemo, useState } from "react";
import { DelayBadge, PriorityBadge } from "@/components/production/production-badges";
import { Card } from "@/components/ui/card";
import { useToast } from "@/components/ui/toast";
import { useProductionStageMutation } from "@/hooks/use-production";
import { getErrorMessage } from "@/lib/errors";
import {
  formatRemainingTime,
  getColumnForStatus,
  getKanbanColumnId,
  getNextColumn,
  getProductionAction,
  KANBAN_COLUMNS,
} from "@/lib/production-stages";
import { formatDate } from "@/lib/utils";
import type { ProductionListItem } from "@/types/production";

interface KanbanBoardProps {
  orders: ProductionListItem[];
}

export function KanbanBoard({ orders }: KanbanBoardProps) {
  const toast = useToast();
  const [draggingId, setDraggingId] = useState<string | null>(null);
  const [activeDropColumn, setActiveDropColumn] = useState<string | null>(null);
  const stageMutation = useProductionStageMutation();

  const grouped = useMemo(() => {
    const map = new Map<string, ProductionListItem[]>();
    for (const column of KANBAN_COLUMNS) {
      map.set(column.id, []);
    }

    for (const order of orders) {
      const columnId = getKanbanColumnId(order.productionStatus);
      map.set(columnId, [...(map.get(columnId) ?? []), order]);
    }

    return map;
  }, [orders]);

  async function handleDrop(targetColumnId: string, order: ProductionListItem) {
    const currentColumn = getColumnForStatus(order.productionStatus);
    const nextColumn = getNextColumn(currentColumn.id);

    if (!nextColumn || nextColumn.id !== targetColumnId) {
      toast.error("Orders can only move to the next production stage.");
      return;
    }

    const action = getProductionAction(order.productionStatus);
    if (!action || action === "quality-check") {
      toast.error("Open order detail to complete quality check.");
      return;
    }

    try {
      await stageMutation.mutateAsync({
        orderId: order.orderId,
        action,
        input: {},
      });
      if (action === "ready") {
        toast.success(`Order ${order.orderNumber} is ready for pickup.`);
      } else {
        toast.success(`Order ${order.orderNumber} moved to ${nextColumn.title}.`);
      }
    } catch (error) {
      toast.error(getErrorMessage(error, "Failed to update production stage."));
    }
  }

  return (
    <div className="flex gap-4 overflow-x-auto pb-2">
      {KANBAN_COLUMNS.map((column) => {
        const columnOrders = grouped.get(column.id) ?? [];

        return (
          <div
            key={column.id}
            className="min-w-[280px] flex-1"
            onDragOver={(event) => {
              event.preventDefault();
              setActiveDropColumn(column.id);
            }}
            onDragLeave={() => setActiveDropColumn(null)}
            onDrop={(event) => {
              event.preventDefault();
              setActiveDropColumn(null);
              const orderId = event.dataTransfer.getData("text/order-id");
              const order = orders.find((item) => item.orderId === orderId);
              if (order) void handleDrop(column.id, order);
              setDraggingId(null);
            }}
          >
            <div className="mb-3 flex items-center justify-between">
              <h3 className="text-sm font-semibold text-slate-700 dark:text-slate-200">
                {column.title}
              </h3>
              <span className="rounded-full bg-slate-100 px-2 py-0.5 text-xs font-medium text-slate-600 dark:bg-slate-800 dark:text-slate-300">
                {columnOrders.length}
              </span>
            </div>
            <div
              className={`min-h-[420px] space-y-3 rounded-xl border border-dashed p-3 ${
                activeDropColumn === column.id
                  ? "border-blue-400 bg-blue-50/50 dark:bg-blue-950/20"
                  : "border-slate-200 dark:border-slate-800"
              }`}
            >
              {columnOrders.length === 0 ? (
                <p className="py-8 text-center text-xs text-slate-400">No orders</p>
              ) : (
                columnOrders.map((order) => (
                  <Card
                    key={order.orderId}
                    draggable
                    onDragStart={(event) => {
                      event.dataTransfer.setData("text/order-id", order.orderId);
                      setDraggingId(order.orderId);
                    }}
                    onDragEnd={() => setDraggingId(null)}
                    className={`cursor-grab p-4 active:cursor-grabbing ${
                      draggingId === order.orderId ? "opacity-60" : ""
                    }`}
                  >
                    <div className="flex items-start justify-between gap-2">
                      <Link
                        href={`/operations/production/${order.orderId}`}
                        className="text-sm font-semibold text-blue-600 hover:underline"
                        onClick={(event) => event.stopPropagation()}
                      >
                        {order.orderNumber}
                      </Link>
                      <PriorityBadge priority={order.priority} />
                    </div>
                    <p className="mt-2 text-sm text-slate-700 dark:text-slate-200">
                      {order.customerName}
                    </p>
                    <p className="text-xs text-slate-500">{order.serviceSummary}</p>
                    <div className="mt-3 grid grid-cols-2 gap-2 text-xs text-slate-500">
                      <span>{order.totalWeight} kg</span>
                      <span>{order.totalPieces} pcs</span>
                      <span className="col-span-2">
                        Due:{" "}
                        {order.estimatedFinishDate
                          ? formatDate(order.estimatedFinishDate)
                          : "-"}
                      </span>
                      <span className="col-span-2">
                        {formatRemainingTime(order.remainingMinutes)}
                      </span>
                    </div>
                    <div className="mt-3 flex flex-wrap gap-2">
                      <DelayBadge
                        isDelayed={order.isDelayed}
                        remainingMinutes={order.remainingMinutes}
                      />
                    </div>
                    <p className="mt-3 text-xs text-slate-500">
                      {order.assignedEmployee?.fullName ?? "Unassigned"}
                    </p>
                  </Card>
                ))
              )}
            </div>
          </div>
        );
      })}
    </div>
  );
}
