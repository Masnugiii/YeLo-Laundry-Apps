import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { OrderStatus } from '@prisma/client';
import { StorageAssignmentAction } from '@prisma/client';
import { ApiSuccessResponse } from '../common/interfaces/api-response.interface';
import { AssignStorageDto, StorageSearchQueryDto } from './dto/storage.dto';
import {
  LOCKER_BOX_COUNTS,
  LOCKER_CODES,
  TOTAL_STORAGE_BOXES,
} from './storage.constants';
import {
  OrderStorageInfo,
  StorageBoxSummary,
  StorageDashboard,
  StorageLockerSummary,
  toStorageBoxSummary,
  toStorageDashboard,
  toStorageLocationFromBox,
  toStorageLockerSummary,
} from './storage.mapper';
import { StorageRepository } from './storage.repository';

const TERMINAL_STATUSES: OrderStatus[] = [
  OrderStatus.COMPLETED,
  OrderStatus.CANCELLED,
];

@Injectable()
export class StorageService {
  constructor(private readonly repository: StorageRepository) {}

  async getDashboard(): Promise<ApiSuccessResponse<StorageDashboard>> {
    const lockers = await this.repository.findAllLockersWithBoxes();
    return {
      success: true,
      message: 'Storage dashboard retrieved',
      data: toStorageDashboard(lockers),
    };
  }

  async getLockers(): Promise<ApiSuccessResponse<StorageLockerSummary[]>> {
    const lockers = await this.repository.findAllLockersWithBoxes();
    return {
      success: true,
      message: 'Storage lockers retrieved',
      data: lockers.map(toStorageLockerSummary),
    };
  }

  async getLocker(code: string): Promise<ApiSuccessResponse<StorageLockerSummary>> {
    const locker = await this.repository.findLockerByCode(code.toUpperCase());
    if (!locker) {
      throw new NotFoundException(`Locker ${code} not found`);
    }
    return {
      success: true,
      message: 'Storage locker retrieved',
      data: toStorageLockerSummary(locker),
    };
  }

  async getBox(code: string): Promise<ApiSuccessResponse<StorageBoxSummary>> {
    const box = await this.repository.findBoxByCode(code.toUpperCase());
    if (!box) {
      throw new NotFoundException(`Storage box ${code} not found`);
    }
    return {
      success: true,
      message: 'Storage box retrieved',
      data: toStorageBoxSummary(box),
    };
  }

  async search(query: StorageSearchQueryDto) {
    const page = query.page ?? 1;
    const limit = query.limit ?? 50;
    const skip = (page - 1) * limit;
    const [items, total] = await this.repository.searchBoxes({
      q: query.q,
      lockerCode: query.lockerCode?.toUpperCase(),
      status: query.status ?? 'all',
      skip,
      take: limit,
    });

    return {
      success: true,
      message: 'Storage boxes retrieved',
      data: {
        items: items.map(toStorageBoxSummary),
        meta: {
          page,
          limit,
          total,
          totalPages: Math.max(1, Math.ceil(total / limit)),
        },
      },
    };
  }

  async getAvailableBoxes(lockerCode: string) {
    const normalized = lockerCode.toUpperCase();
    this.validateLockerCode(normalized);

    const locker = await this.repository.findLockerByCode(normalized);
    if (!locker) {
      throw new NotFoundException(`Locker ${normalized} not found`);
    }

    return {
      success: true,
      message: 'Storage boxes retrieved',
      data: locker.boxes.map(toStorageBoxSummary),
    };
  }

  async assign(
    orderId: string,
    dto: AssignStorageDto,
    employeeId: string,
  ): Promise<ApiSuccessResponse<StorageBoxSummary>> {
    const order = await this.repository.findOrderForStorage(orderId);
    if (!order) {
      throw new NotFoundException('Order not found');
    }
    if (TERMINAL_STATUSES.includes(order.orderStatus)) {
      throw new BadRequestException('Cannot assign storage to a completed or cancelled order');
    }

    const lockerCode = dto.lockerCode.toUpperCase();
    this.validateLockerAndBox(lockerCode, dto.boxNumber);

    const targetBox = await this.repository.findBoxByLockerAndNumber(
      lockerCode,
      dto.boxNumber,
    );
    if (!targetBox) {
      throw new NotFoundException(
        `Storage box ${lockerCode}-${String(dto.boxNumber).padStart(2, '0')} not found`,
      );
    }

    if (order.storageBoxId === targetBox.id) {
      return {
        success: true,
        message: 'Order is already assigned to this storage box',
        data: toStorageBoxSummary(targetBox),
      };
    }

    if (order.storageBoxId) {
      await this.repository.assignBox({
        orderId,
        storageBoxId: targetBox.id,
        employeeId,
        action: StorageAssignmentAction.MOVED,
        previousStorageBoxId: order.storageBoxId,
      });
    } else {
      await this.repository.assignBox({
        orderId,
        storageBoxId: targetBox.id,
        employeeId,
        action: StorageAssignmentAction.ASSIGNED,
      });
    }

    const updated = await this.repository.findBoxByCode(targetBox.code);
    return {
      success: true,
      message: 'Storage assigned successfully',
      data: toStorageBoxSummary(updated!),
    };
  }

  async move(
    orderId: string,
    dto: AssignStorageDto,
    employeeId: string,
  ): Promise<ApiSuccessResponse<StorageBoxSummary>> {
    const order = await this.repository.findOrderForStorage(orderId);
    if (!order) {
      throw new NotFoundException('Order not found');
    }
    if (!order.storageBoxId) {
      throw new BadRequestException('Order has no current storage assignment');
    }

    return this.assign(orderId, dto, employeeId);
  }

  async getOrderStorage(orderId: string): Promise<ApiSuccessResponse<OrderStorageInfo>> {
    const order = await this.repository.findOrderWithStorageAssignee(orderId);
    if (!order) {
      throw new NotFoundException('Order not found');
    }

    const [currentBox, lastBox, history] = await Promise.all([
      order.storageBoxId
        ? this.repository.findBoxById(order.storageBoxId)
        : Promise.resolve(null),
      order.lastStorageBoxId
        ? this.repository.findBoxById(order.lastStorageBoxId)
        : Promise.resolve(null),
      this.repository.findOrderStorageHistory(orderId),
    ]);

    const historyItems = history.map((entry) => ({
      action: entry.action,
      location: toStorageLocationFromBox(entry.storageBox),
      assignedBy: entry.assignedBy
        ? {
            id: entry.assignedBy.id,
            fullName: entry.assignedBy.fullName,
            employeeCode: entry.assignedBy.employeeCode,
          }
        : null,
      createdAt: entry.createdAt.toISOString(),
    }));

    return {
      success: true,
      message: 'Order storage retrieved',
      data: {
        current: currentBox ? toStorageLocationFromBox(currentBox) : null,
        last: lastBox ? toStorageLocationFromBox(lastBox) : null,
        assignedAt: order.storageAssignedAt?.toISOString() ?? null,
        assignedBy: order.storageAssignedBy
          ? {
              id: order.storageAssignedBy.id,
              fullName: order.storageAssignedBy.fullName,
              employeeCode: order.storageAssignedBy.employeeCode,
            }
          : null,
        history: historyItems,
      },
    };
  }

  async releaseForOrder(orderId: string, employeeId: string | null) {
    await this.repository.releaseBoxForOrder(orderId, employeeId);
  }

  validateLockerCode(lockerCode: string) {
    if (!LOCKER_CODES.includes(lockerCode as (typeof LOCKER_CODES)[number])) {
      throw new BadRequestException(`Unknown locker: ${lockerCode}`);
    }
  }

  validateLockerAndBox(lockerCode: string, boxNumber: number) {
    this.validateLockerCode(lockerCode);
    const max = LOCKER_BOX_COUNTS[lockerCode as keyof typeof LOCKER_BOX_COUNTS];
    if (!max || boxNumber < 1 || boxNumber > max) {
      throw new BadRequestException(
        `Invalid box number ${boxNumber} for locker ${lockerCode}`,
      );
    }
  }

  getPhysicalConfig() {
    return {
      totalBoxes: TOTAL_STORAGE_BOXES,
      lockers: LOCKER_CODES.map((code) => ({
        code,
        name: `Laci ${code}`,
        boxCount: LOCKER_BOX_COUNTS[code],
      })),
    };
  }
}
