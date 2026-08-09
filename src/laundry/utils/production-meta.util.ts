export type ProductionStatus =
  | 'RECEIVED'
  | 'WAITING_WASH'
  | 'WASHING'
  | 'WAITING_DRY'
  | 'DRYING'
  | 'WAITING_IRON'
  | 'IRONING'
  | 'QUALITY_CHECK'
  | 'READY'
  | 'COMPLETED';

export type ProductionPriority = 'NORMAL' | 'EXPRESS' | 'VIP';

export type QualityResult = 'PASS' | 'REWORK';

export type ReworkStage = 'WAITING_WASH' | 'WAITING_IRON';

export interface ProductionStageEvent {
  stage: ProductionStatus;
  employeeId: string;
  startedAt: string;
  finishedAt?: string;
  durationMinutes?: number;
  notes?: string;
}

export interface QualityCheckRecord {
  id: string;
  result: QualityResult;
  passed: boolean;
  reworkStage?: ReworkStage;
  reason?: string;
  notes?: string;
  employeeId: string;
  checkedAt: string;
}

export interface ProductionRecord {
  orderId: string;
  priority: ProductionPriority;
  currentStage: ProductionStatus;
  receivedAt: string;
  history: ProductionStageEvent[];
  qualityChecks: QualityCheckRecord[];
  createdByEmployeeId: string;
  updatedByEmployeeId?: string;
  createdAt: string;
  updatedAt: string;
}

export const PRODUCTION_SETTING_PREFIX = 'production.order.';

export function buildProductionSettingKey(orderId: string): string {
  return `${PRODUCTION_SETTING_PREFIX}${orderId}`;
}

export function parseProductionRecord(value: string): ProductionRecord | null {
  try {
    return JSON.parse(value) as ProductionRecord;
  } catch {
    return null;
  }
}

export const PRODUCTION_WORKFLOW: ProductionStatus[] = [
  'RECEIVED',
  'WAITING_WASH',
  'WASHING',
  'WAITING_DRY',
  'DRYING',
  'WAITING_IRON',
  'IRONING',
  'QUALITY_CHECK',
  'READY',
  'COMPLETED',
];

export const NEXT_STAGE: Partial<Record<ProductionStatus, ProductionStatus>> = {
  RECEIVED: 'WAITING_WASH',
  WAITING_WASH: 'WASHING',
  WASHING: 'WAITING_DRY',
  WAITING_DRY: 'DRYING',
  DRYING: 'WAITING_IRON',
  WAITING_IRON: 'IRONING',
  IRONING: 'QUALITY_CHECK',
  QUALITY_CHECK: 'READY',
  READY: 'COMPLETED',
};

export const PREVIOUS_STAGE: Partial<Record<ProductionStatus, ProductionStatus>> =
  Object.fromEntries(
    Object.entries(NEXT_STAGE).map(([current, next]) => [next, current]),
  ) as Partial<Record<ProductionStatus, ProductionStatus>>;

export const PRIORITY_WEIGHT: Record<ProductionPriority, number> = {
  VIP: 3,
  EXPRESS: 2,
  NORMAL: 1,
};

export function mapPriorityToPrisma(
  priority: ProductionPriority,
): 'LOW' | 'NORMAL' | 'HIGH' | 'URGENT' {
  switch (priority) {
    case 'VIP':
      return 'URGENT';
    case 'EXPRESS':
      return 'HIGH';
    default:
      return 'NORMAL';
  }
}

export function mapPrismaPriorityToProduction(
  priority: 'LOW' | 'NORMAL' | 'HIGH' | 'URGENT',
): ProductionPriority {
  switch (priority) {
    case 'URGENT':
      return 'VIP';
    case 'HIGH':
      return 'EXPRESS';
    default:
      return 'NORMAL';
  }
}
