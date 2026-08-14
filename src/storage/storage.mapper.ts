import { StorageBoxWithOrders, StorageLockerWithBoxes } from './storage.select';
import { LOCKER_BOX_COUNTS } from './storage.constants';

export interface StorageLocationResponse {
  code: string;
  lockerCode: string;
  lockerName: string;
  boxNumber: number;
  displayLocker: string;
  displayBox: string;
}

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
  status: 'AVAILABLE' | 'OCCUPIED';
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

export interface OrderStorageInfo {
  current: StorageLocationResponse | null;
  last: StorageLocationResponse | null;
  assignedAt: string | null;
  assignedBy: {
    id: string;
    fullName: string;
    employeeCode: string;
  } | null;
  history: Array<{
    action: string;
    location: StorageLocationResponse;
    assignedBy: {
      id: string;
      fullName: string;
      employeeCode: string;
    } | null;
    createdAt: string;
  }>;
}

function toLocation(
  lockerCode: string,
  lockerName: string,
  boxNumber: number,
  code: string,
): StorageLocationResponse {
  return {
    code,
    lockerCode,
    lockerName,
    boxNumber,
    displayLocker: lockerName,
    displayBox: `Kotak ${String(boxNumber).padStart(2, '0')}`,
  };
}

function toStorageBoxOrderItem(
  order: StorageBoxWithOrders['currentOrders'][number],
): StorageBoxOrderItem {
  return {
    id: order.id,
    orderNumber: order.queueNumber,
    customerName: order.customer.fullName,
    customerPhone: order.customer.phone,
    orderStatus: order.orderStatus,
    assignedAt: order.storageAssignedAt?.toISOString() ?? null,
    assignedBy: order.storageAssignedBy
      ? {
          id: order.storageAssignedBy.id,
          fullName: order.storageAssignedBy.fullName,
          employeeCode: order.storageAssignedBy.employeeCode,
        }
      : null,
  };
}

export function toStorageBoxSummary(box: StorageBoxWithOrders): StorageBoxSummary {
  const orders = box.currentOrders.map(toStorageBoxOrderItem);
  const orderCount = orders.length;
  const occupied = orderCount > 0;

  return {
    id: box.id,
    code: box.code,
    lockerCode: box.locker.code,
    lockerName: box.locker.name,
    boxNumber: box.boxNumber,
    status: occupied ? 'OCCUPIED' : 'AVAILABLE',
    statusLabel: occupied ? 'TERISI' : 'KOSONG',
    orderCount,
    orders,
  };
}

export function toStorageLockerSummary(locker: StorageLockerWithBoxes): StorageLockerSummary {
  const boxes = locker.boxes.map(toStorageBoxSummary);
  const occupiedCount = boxes.filter((box) => box.status === 'OCCUPIED').length;
  const orderCount = boxes.reduce((sum, box) => sum + box.orderCount, 0);
  const totalBoxes =
    LOCKER_BOX_COUNTS[locker.code as keyof typeof LOCKER_BOX_COUNTS] ?? boxes.length;

  return {
    code: locker.code,
    name: locker.name,
    totalBoxes,
    occupiedCount,
    availableCount: totalBoxes - occupiedCount,
    orderCount,
    boxes,
  };
}

export function toStorageDashboard(lockers: StorageLockerWithBoxes[]): StorageDashboard {
  const summaries = lockers.map(toStorageLockerSummary);
  const totalBoxes = summaries.reduce((sum, locker) => sum + locker.totalBoxes, 0);
  const occupiedCount = summaries.reduce((sum, locker) => sum + locker.occupiedCount, 0);
  const totalOrdersInStorage = summaries.reduce((sum, locker) => sum + locker.orderCount, 0);

  return {
    totalLockers: summaries.length,
    totalBoxes,
    occupiedCount,
    availableCount: totalBoxes - occupiedCount,
    totalOrdersInStorage,
    lockers: summaries.map((locker) => ({
      code: locker.code,
      name: locker.name,
      totalBoxes: locker.totalBoxes,
      occupiedCount: locker.occupiedCount,
      availableCount: locker.availableCount,
      orderCount: locker.orderCount,
    })),
  };
}

export function toStorageLocationFromBox(box: {
  code: string;
  boxNumber: number;
  locker: { code: string; name: string };
}): StorageLocationResponse {
  return toLocation(box.locker.code, box.locker.name, box.boxNumber, box.code);
}
