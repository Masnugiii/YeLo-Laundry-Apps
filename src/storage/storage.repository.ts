import { Injectable } from '@nestjs/common';
import { OrderStatus, Prisma, StorageAssignmentAction } from '@prisma/client';
import { PrismaService } from '../database/prisma/prisma.service';
import {
  storageBoxWithOrdersSelect,
  storageLockerWithBoxesSelect,
  StorageBoxWithOrders,
  StorageLockerWithBoxes,
} from './storage.select';

const ACTIVE_ORDER_FILTER: Prisma.OrderWhereInput = {
  deletedAt: null,
  orderStatus: { notIn: [OrderStatus.COMPLETED, OrderStatus.CANCELLED] },
};

@Injectable()
export class StorageRepository {
  constructor(private readonly prisma: PrismaService) {}

  findAllLockersWithBoxes(): Promise<StorageLockerWithBoxes[]> {
    return this.prisma.storageLocker.findMany({
      where: { isActive: true },
      select: storageLockerWithBoxesSelect,
      orderBy: { code: 'asc' },
    });
  }

  findLockerByCode(code: string): Promise<StorageLockerWithBoxes | null> {
    return this.prisma.storageLocker.findFirst({
      where: { code, isActive: true },
      select: storageLockerWithBoxesSelect,
    });
  }

  findBoxByCode(code: string): Promise<StorageBoxWithOrders | null> {
    return this.prisma.storageBox.findFirst({
      where: { code, isActive: true },
      select: storageBoxWithOrdersSelect,
    });
  }

  findBoxByLockerAndNumber(
    lockerCode: string,
    boxNumber: number,
  ): Promise<StorageBoxWithOrders | null> {
    return this.prisma.storageBox.findFirst({
      where: {
        boxNumber,
        isActive: true,
        locker: { code: lockerCode, isActive: true },
      },
      select: storageBoxWithOrdersSelect,
    });
  }

  findBoxById(id: string): Promise<StorageBoxWithOrders | null> {
    return this.prisma.storageBox.findFirst({
      where: { id, isActive: true },
      select: storageBoxWithOrdersSelect,
    });
  }

  findOrderForStorage(orderId: string) {
    return this.findOrderWithStorageAssignee(orderId);
  }

  findOrderWithStorageAssignee(orderId: string) {
    return this.prisma.order.findFirst({
      where: { id: orderId, deletedAt: null },
      select: {
        id: true,
        queueNumber: true,
        orderStatus: true,
        storageBoxId: true,
        lastStorageBoxId: true,
        storageAssignedAt: true,
        customer: { select: { id: true, fullName: true, phone: true } },
        storageAssignedBy: {
          select: { id: true, fullName: true, employeeCode: true },
        },
      },
    });
  }

  searchBoxes(params: {
    q?: string;
    lockerCode?: string;
    status?: string;
    skip: number;
    take: number;
  }) {
    const where: Prisma.StorageBoxWhereInput = {
      isActive: true,
      locker: { isActive: true },
    };

    if (params.lockerCode) {
      where.locker = { code: params.lockerCode, isActive: true };
    }

    if (params.status === 'available') {
      where.currentOrders = { none: ACTIVE_ORDER_FILTER };
    } else if (params.status === 'occupied') {
      where.currentOrders = { some: ACTIVE_ORDER_FILTER };
    } else if (params.status === 'ready_for_pickup') {
      where.currentOrders = {
        some: {
          ...ACTIVE_ORDER_FILTER,
          orderStatus: OrderStatus.READY_FOR_PICKUP,
        },
      };
    }

    if (params.q?.trim()) {
      const q = params.q.trim();
      where.OR = [
        { code: { contains: q, mode: 'insensitive' } },
        { locker: { code: { contains: q, mode: 'insensitive' } } },
        {
          currentOrders: {
            some: {
              ...ACTIVE_ORDER_FILTER,
              OR: [
                { queueNumber: { contains: q, mode: 'insensitive' } },
                {
                  customer: {
                    OR: [
                      { fullName: { contains: q, mode: 'insensitive' } },
                      { phone: { contains: q, mode: 'insensitive' } },
                    ],
                  },
                },
              ],
            },
          },
        },
      ];
    }

    return this.prisma.$transaction([
      this.prisma.storageBox.findMany({
        where,
        select: storageBoxWithOrdersSelect,
        orderBy: [{ locker: { code: 'asc' } }, { boxNumber: 'asc' }],
        skip: params.skip,
        take: params.take,
      }),
      this.prisma.storageBox.count({ where }),
    ]);
  }

  async assignBox(params: {
    orderId: string;
    storageBoxId: string;
    employeeId: string;
    action: StorageAssignmentAction;
    previousStorageBoxId?: string | null;
  }) {
    return this.prisma.$transaction(async (tx) => {
      const box = await tx.storageBox.findUnique({
        where: { id: params.storageBoxId },
        select: { id: true, isActive: true },
      });

      if (!box?.isActive) {
        throw new Error('STORAGE_BOX_NOT_FOUND');
      }

      await tx.order.update({
        where: { id: params.orderId },
        data: {
          storageBoxId: params.storageBoxId,
          storageAssignedAt: new Date(),
          storageAssignedByEmployeeId: params.employeeId,
        },
      });

      await tx.orderStorageAssignment.create({
        data: {
          orderId: params.orderId,
          storageBoxId: params.storageBoxId,
          previousStorageBoxId: params.previousStorageBoxId ?? null,
          action: params.action,
          assignedByEmployeeId: params.employeeId,
        },
      });

      return params.storageBoxId;
    });
  }

  async releaseBoxForOrder(orderId: string, employeeId: string | null) {
    return this.prisma.$transaction(async (tx) => {
      const order = await tx.order.findUnique({
        where: { id: orderId },
        select: { id: true, storageBoxId: true },
      });

      if (!order?.storageBoxId) {
        return null;
      }

      const storageBoxId = order.storageBoxId;

      await tx.order.update({
        where: { id: orderId },
        data: {
          lastStorageBoxId: storageBoxId,
          storageBoxId: null,
          storageAssignedAt: null,
          storageAssignedByEmployeeId: null,
        },
      });

      if (employeeId) {
        await tx.orderStorageAssignment.create({
          data: {
            orderId,
            storageBoxId,
            action: StorageAssignmentAction.RELEASED,
            assignedByEmployeeId: employeeId,
          },
        });
      }

      return storageBoxId;
    });
  }

  findOrderStorageHistory(orderId: string) {
    return this.prisma.orderStorageAssignment.findMany({
      where: { orderId },
      orderBy: { createdAt: 'asc' },
      include: {
        storageBox: {
          select: {
            code: true,
            boxNumber: true,
            locker: { select: { code: true, name: true } },
          },
        },
        assignedBy: {
          select: { id: true, fullName: true, employeeCode: true },
        },
      },
    });
  }
}
