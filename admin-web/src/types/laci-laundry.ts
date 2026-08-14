export interface StorageBoxOrderItem {
  id: string;
  orderNumber: string;
  customerName: string;
  customerPhone: string | null;
  orderStatus: string;
  assignedAt: string | null;
  assignedBy: {
    id: string;
    fullName: string;
    employeeCode: string;
  } | null;
}

export interface StorageBoxSummary {
  id: string;
  code: string;
  lockerCode: string;
  lockerName: string;
  boxNumber: number;
  status: "AVAILABLE" | "OCCUPIED";
  statusLabel: string;
  orderCount: number;
  orders: StorageBoxOrderItem[];
}

export interface StorageLockerSummary {
  code: string;
  name: string;
  totalBoxes: number;
  occupiedCount: number;
  availableCount: number;
  orderCount: number;
  boxes: StorageBoxSummary[];
}

export interface StorageDashboard {
  totalLockers: number;
  totalBoxes: number;
  occupiedCount: number;
  availableCount: number;
  totalOrdersInStorage: number;
  lockers: Array<{
    code: string;
    name: string;
    totalBoxes: number;
    occupiedCount: number;
    availableCount: number;
    orderCount: number;
  }>;
}
