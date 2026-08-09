import type { ProductionActionKind, ProductionStatus } from "@/types/production";

export interface KanbanColumn {
  id: string;
  title: string;
  stages: ProductionStatus[];
}

export const KANBAN_COLUMNS: KanbanColumn[] = [
  { id: "receiving", title: "Receiving", stages: ["RECEIVED"] },
  { id: "sorting", title: "Sorting", stages: ["WAITING_WASH"] },
  { id: "washing", title: "Washing", stages: ["WASHING"] },
  { id: "drying", title: "Drying", stages: ["WAITING_DRY", "DRYING"] },
  { id: "ironing", title: "Ironing", stages: ["WAITING_IRON", "IRONING"] },
  { id: "qualityCheck", title: "Quality Check", stages: ["QUALITY_CHECK"] },
  { id: "packing", title: "Packing", stages: ["QUALITY_CHECK"] },
  { id: "readyPickup", title: "Ready Pickup", stages: ["READY"] },
  { id: "completed", title: "Completed", stages: ["COMPLETED"] },
];

export const TIMELINE_STAGES: ProductionStatus[] = [
  "RECEIVED",
  "WAITING_WASH",
  "WASHING",
  "WAITING_DRY",
  "DRYING",
  "WAITING_IRON",
  "IRONING",
  "QUALITY_CHECK",
  "READY",
  "COMPLETED",
];

export const STAGE_LABELS: Record<ProductionStatus, string> = {
  RECEIVED: "Receiving",
  WAITING_WASH: "Sorting",
  WASHING: "Washing",
  WAITING_DRY: "Waiting Dry",
  DRYING: "Drying",
  WAITING_IRON: "Waiting Iron",
  IRONING: "Ironing",
  QUALITY_CHECK: "Quality Check",
  READY: "Ready Pickup",
  COMPLETED: "Completed",
};

export const PRIORITY_OPTIONS = ["NORMAL", "EXPRESS", "VIP"] as const;

export const PRODUCTION_STATUS_OPTIONS: ProductionStatus[] = [
  "RECEIVED",
  "WAITING_WASH",
  "WASHING",
  "WAITING_DRY",
  "DRYING",
  "WAITING_IRON",
  "IRONING",
  "QUALITY_CHECK",
  "READY",
  "COMPLETED",
];

export function getKanbanColumnId(status: ProductionStatus): string {
  switch (status) {
    case "RECEIVED":
      return "receiving";
    case "WAITING_WASH":
      return "sorting";
    case "WASHING":
      return "washing";
    case "WAITING_DRY":
    case "DRYING":
      return "drying";
    case "WAITING_IRON":
    case "IRONING":
      return "ironing";
    case "QUALITY_CHECK":
      return "qualityCheck";
    case "READY":
      return "readyPickup";
    case "COMPLETED":
      return "completed";
    default:
      return "receiving";
  }
}

export function getColumnForStatus(status: ProductionStatus): KanbanColumn {
  const columnId = getKanbanColumnId(status);
  return KANBAN_COLUMNS.find((column) => column.id === columnId) ?? KANBAN_COLUMNS[0];
}

export function getNextColumn(columnId: string): KanbanColumn | null {
  const index = KANBAN_COLUMNS.findIndex((column) => column.id === columnId);
  if (index < 0 || index >= KANBAN_COLUMNS.length - 1) return null;
  return KANBAN_COLUMNS[index + 1];
}

export function getProductionAction(
  status: ProductionStatus,
): ProductionActionKind | null {
  switch (status) {
    case "WAITING_WASH":
      return "start-washing";
    case "WASHING":
      return "finish-washing";
    case "WAITING_DRY":
      return "start-drying";
    case "DRYING":
      return "finish-drying";
    case "WAITING_IRON":
      return "start-ironing";
    case "IRONING":
      return "finish-ironing";
    case "QUALITY_CHECK":
      return "quality-check";
    case "READY":
      return "ready";
    default:
      return null;
  }
}

export function formatRemainingTime(minutes: number | null): string {
  if (minutes === null) return "-";
  const abs = Math.abs(minutes);
  const hours = Math.floor(abs / 60);
  const mins = abs % 60;
  const label = hours > 0 ? `${hours}h ${mins}m` : `${mins}m`;
  return minutes < 0 ? `Overdue ${label}` : `${label} left`;
}

export function computeProductionMetrics(history: Array<{
  startedAt: string;
  finishedAt: string | null;
  durationMinutes: number | null;
}>, receivedAt: string) {
  const processingTimeMinutes = history.reduce(
    (sum, event) => sum + (event.durationMinutes ?? 0),
    0,
  );

  let waitingTimeMinutes = 0;
  const sorted = [...history].sort(
    (a, b) => new Date(a.startedAt).getTime() - new Date(b.startedAt).getTime(),
  );

  for (let index = 1; index < sorted.length; index += 1) {
    const previous = sorted[index - 1];
    const current = sorted[index];
    if (previous.finishedAt) {
      const gap =
        (new Date(current.startedAt).getTime() -
          new Date(previous.finishedAt).getTime()) /
        60000;
      if (gap > 0) waitingTimeMinutes += Math.round(gap);
    }
  }

  const totalDurationMinutes = Math.round(
    (Date.now() - new Date(receivedAt).getTime()) / 60000,
  );

  return {
    productionTimeMinutes: processingTimeMinutes,
    waitingTimeMinutes,
    processingTimeMinutes,
    totalDurationMinutes,
  };
}
