export type ProductionStatus =
  | "RECEIVED"
  | "WAITING_WASH"
  | "WASHING"
  | "WAITING_DRY"
  | "DRYING"
  | "WAITING_IRON"
  | "IRONING"
  | "QUALITY_CHECK"
  | "READY"
  | "COMPLETED";

export type ProductionPriority = "NORMAL" | "EXPRESS" | "VIP";

export interface ProductionEmployee {
  id: string;
  fullName: string;
  employeeCode: string;
}

export interface ProductionListItem {
  orderId: string;
  orderNumber: string;
  queueNumber: string;
  customerName: string;
  customerPhone: string;
  orderStatus: string;
  productionStatus: ProductionStatus;
  priority: ProductionPriority;
  serviceSummary: string;
  totalWeight: number;
  totalPieces: number;
  receivedAt: string;
  updatedAt: string;
  stageStartedAt: string | null;
  estimatedFinishDate: string | null;
  isDelayed: boolean;
  remainingMinutes: number | null;
  assignedEmployee: ProductionEmployee | null;
}

export interface ProductionStageEvent {
  stage: ProductionStatus;
  employeeId: string;
  startedAt: string;
  finishedAt: string | null;
  durationMinutes: number | null;
  notes: string | null;
}

export interface QualityCheckRecord {
  passed: boolean;
  checkedAt: string;
  checkedByEmployeeId: string;
  notes: string | null;
  reason: string | null;
  reworkStage: ProductionStatus | null;
}

export interface ProductionDetail extends ProductionListItem {
  items: Array<{
    id: string;
    serviceCode: string;
    serviceName: string;
    quantity: number;
    weight: number | null;
    subtotal: number;
  }>;
  productionHistory: ProductionStageEvent[];
  qualityChecks: QualityCheckRecord[];
  orderTimelines: Array<{
    id: string;
    title: string;
    description: string | null;
    employee: ProductionEmployee | null;
    createdAt: string;
  }>;
  statusHistory: Array<{
    id: string;
    previousStatus: string | null;
    currentStatus: string;
    notes: string | null;
    changedBy: ProductionEmployee | null;
    changedAt: string;
  }>;
}

export interface ProductionDashboard {
  receiving: number;
  sorting: number;
  waitingWashing: number;
  currentlyWashing: number;
  waitingDrying: number;
  currentlyDrying: number;
  waitingIroning: number;
  currentlyIroning: number;
  qualityCheck: number;
  packing: number;
  readyForPickup: number;
  completedToday: number;
  delayed: number;
  averageProductionTimeMinutes: number;
}

export interface ProductionListParams {
  page?: number;
  limit?: number;
  search?: string;
  status?: ProductionStatus;
  employeeId?: string;
  priority?: ProductionPriority;
  service?: string;
  date?: string;
  dateFrom?: string;
  dateTo?: string;
  delayStatus?: "delayed" | "on_track";
}

export type ProductionActionKind =
  | "start-washing"
  | "finish-washing"
  | "start-drying"
  | "finish-drying"
  | "start-ironing"
  | "finish-ironing"
  | "quality-check"
  | "ready";

export interface ProductionActionInput {
  notes?: string;
}

export interface QualityCheckInput {
  passed: boolean;
  notes?: string;
  reason?: string;
  reworkStage?: "WAITING_WASH" | "WAITING_IRON";
}

export interface QcChecklistState {
  clean: boolean;
  dry: boolean;
  ironed: boolean;
  folded: boolean;
  packaging: boolean;
  perfume: boolean;
  specialRequestCompleted: boolean;
  operatorNotes: string;
}
