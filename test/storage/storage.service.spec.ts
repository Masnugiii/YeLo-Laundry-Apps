import {
  BadRequestException,
  NotFoundException,
} from '@nestjs/common';
import { OrderStatus, StorageAssignmentAction } from '@prisma/client';
import { StorageService } from '../../src/storage/storage.service';
import { StorageRepository } from '../../src/storage/storage.repository';

function makeOrder(id: string, queueNumber: string, storageBoxId: string | null = null) {
  return {
    id,
    queueNumber,
    orderStatus: OrderStatus.READY_FOR_PICKUP,
    storageBoxId,
    lastStorageBoxId: null,
    storageAssignedAt: null,
    customer: { id: `c-${id}`, fullName: `Customer ${id}`, phone: '081' },
    storageAssignedBy: null,
  };
}

function makeBox(
  id: string,
  code: string,
  boxNumber: number,
  orders: ReturnType<typeof makeOrder>[] = [],
) {
  return {
    id,
    code,
    boxNumber,
    isActive: true,
    locker: { id: `l-${code[0]}`, code: code[0], name: `Laci ${code[0]}` },
    currentOrders: orders,
  };
}

describe('StorageService', () => {
  let service: StorageService;
  let repository: jest.Mocked<StorageRepository>;

  beforeEach(() => {
    repository = {
      findAllLockersWithBoxes: jest.fn(),
      findLockerByCode: jest.fn(),
      findBoxByCode: jest.fn(),
      findBoxByLockerAndNumber: jest.fn(),
      findBoxById: jest.fn(),
      findOrderForStorage: jest.fn(),
      findOrderWithStorageAssignee: jest.fn(),
      searchBoxes: jest.fn(),
      assignBox: jest.fn(),
      releaseBoxForOrder: jest.fn(),
      findOrderStorageHistory: jest.fn(),
    } as unknown as jest.Mocked<StorageRepository>;

    service = new StorageService(repository);
  });

  it('rejects unknown locker code', () => {
    expect(() => service.validateLockerAndBox('Z', 1)).toThrow(BadRequestException);
  });

  it('rejects locker A box 10', () => {
    expect(() => service.validateLockerAndBox('A', 10)).toThrow(BadRequestException);
  });

  it('rejects locker B box 16', () => {
    expect(() => service.validateLockerAndBox('B', 16)).toThrow(BadRequestException);
  });

  it('rejects locker C box 16', () => {
    expect(() => service.validateLockerAndBox('C', 16)).toThrow(BadRequestException);
  });

  it('returns physical config with 39 boxes', () => {
    const config = service.getPhysicalConfig();
    expect(config.totalBoxes).toBe(39);
    expect(config.lockers).toHaveLength(3);
    expect(config.lockers.find((l) => l.code === 'A')?.boxCount).toBe(9);
    expect(config.lockers.find((l) => l.code === 'B')?.boxCount).toBe(15);
    expect(config.lockers.find((l) => l.code === 'C')?.boxCount).toBe(15);
  });

  it('assigns first order to A-01', async () => {
    const order = makeOrder('order-1', 'YL-000045');
    const box = makeBox('box-1', 'A-01', 1);

    repository.findOrderForStorage.mockResolvedValue(order as never);
    repository.findBoxByLockerAndNumber.mockResolvedValue(box as never);
    repository.assignBox.mockResolvedValue('box-1');
    repository.findBoxByCode.mockResolvedValue(
      makeBox('box-1', 'A-01', 1, [makeOrder('order-1', 'YL-000045', 'box-1')]) as never,
    );

    const result = await service.assign(
      'order-1',
      { lockerCode: 'A', boxNumber: 1 },
      'emp-1',
    );

    expect(repository.assignBox).toHaveBeenCalledWith({
      orderId: 'order-1',
      storageBoxId: 'box-1',
      employeeId: 'emp-1',
      action: StorageAssignmentAction.ASSIGNED,
    });
    expect(result.data?.orderCount).toBe(1);
    expect(result.data?.statusLabel).toBe('TERISI');
  });

  it('allows multiple orders in the same box', async () => {
    const existingOrders = [
      makeOrder('order-1', 'YL-000045', 'box-1'),
      makeOrder('order-2', 'YL-000046', 'box-1'),
    ];
    const order3 = makeOrder('order-3', 'YL-000051');
    const box = makeBox('box-1', 'A-01', 1, existingOrders);

    repository.findOrderForStorage.mockResolvedValue(order3 as never);
    repository.findBoxByLockerAndNumber.mockResolvedValue(box as never);
    repository.assignBox.mockResolvedValue('box-1');
    repository.findBoxByCode.mockResolvedValue(
      makeBox('box-1', 'A-01', 1, [...existingOrders, makeOrder('order-3', 'YL-000051', 'box-1')]) as never,
    );

    const result = await service.assign(
      'order-3',
      { lockerCode: 'A', boxNumber: 1 },
      'emp-1',
    );

    expect(repository.assignBox).toHaveBeenCalledWith({
      orderId: 'order-3',
      storageBoxId: 'box-1',
      employeeId: 'emp-1',
      action: StorageAssignmentAction.ASSIGNED,
    });
    expect(result.data?.orderCount).toBe(3);
  });

  it('moves a single order without affecting other orders in source box', async () => {
    const order = makeOrder('order-1', 'YL-000045', 'box-1');
    const targetBox = makeBox('box-2', 'B-03', 3, [makeOrder('order-4', 'YL-000047', 'box-2')]);

    repository.findOrderForStorage.mockResolvedValue(order as never);
    repository.findBoxByLockerAndNumber.mockResolvedValue(targetBox as never);
    repository.assignBox.mockResolvedValue('box-2');
    repository.findBoxByCode.mockResolvedValue(
      makeBox('box-2', 'B-03', 3, [
        makeOrder('order-4', 'YL-000047', 'box-2'),
        makeOrder('order-1', 'YL-000045', 'box-2'),
      ]) as never,
    );

    const result = await service.move(
      'order-1',
      { lockerCode: 'B', boxNumber: 3 },
      'emp-1',
    );

    expect(repository.assignBox).toHaveBeenCalledWith({
      orderId: 'order-1',
      storageBoxId: 'box-2',
      employeeId: 'emp-1',
      action: StorageAssignmentAction.MOVED,
      previousStorageBoxId: 'box-1',
    });
    expect(result.data?.orderCount).toBe(2);
  });

  it('releases storage on order completion helper', async () => {
    repository.releaseBoxForOrder.mockResolvedValue('box-1');
    await service.releaseForOrder('order-1', 'emp-1');
    expect(repository.releaseBoxForOrder).toHaveBeenCalledWith('order-1', 'emp-1');
  });

  it('returns all boxes for locker selection (multi-order)', async () => {
    const locker = {
      id: 'locker-a',
      code: 'A',
      name: 'Laci A',
      isActive: true,
      boxes: [
        makeBox('box-1', 'A-01', 1, [makeOrder('order-1', 'YL-000045', 'box-1')]),
        makeBox('box-2', 'A-02', 2),
      ],
    };

    repository.findLockerByCode.mockResolvedValue(locker as never);

    const result = await service.getAvailableBoxes('A');
    expect(result.data).toHaveLength(2);
    expect(result.data[0].orderCount).toBe(1);
    expect(result.data[1].orderCount).toBe(0);
  });

  it('rejects assign for unknown box', async () => {
    repository.findOrderForStorage.mockResolvedValue(makeOrder('order-1', 'YL-000045') as never);
    repository.findBoxByLockerAndNumber.mockResolvedValue(null);

    await expect(
      service.assign('order-1', { lockerCode: 'A', boxNumber: 1 }, 'emp-1'),
    ).rejects.toBeInstanceOf(NotFoundException);
  });
});
