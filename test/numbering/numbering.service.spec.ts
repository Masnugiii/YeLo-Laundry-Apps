import { NotFoundException } from '@nestjs/common';
import { NumberingService } from '../../src/numbering/numbering.service';
import { formatDailyNumber, formatSequentialNumber } from '../../src/numbering/numbering.types';

describe('NumberingService', () => {
  const auditService = { logConfigUpdated: jest.fn() };
  let prisma: {
    numberingSequence: {
      findMany: jest.Mock;
      findUnique: jest.Mock;
      update: jest.Mock;
    };
    order?: {
      findFirst: jest.Mock;
    };
    payment?: {
      findFirst: jest.Mock;
    };
    expense?: {
      findFirst: jest.Mock;
    };
    systemSetting?: {
      findFirst: jest.Mock;
    };
    $queryRaw: jest.Mock;
    $executeRaw: jest.Mock;
    $transaction: jest.Mock;
  };

  prisma = {
    numberingSequence: {
      findMany: jest.fn(),
      findUnique: jest.fn(),
      update: jest.fn(),
    },
    $queryRaw: jest.fn(),
    $executeRaw: jest.fn(),
    $transaction: jest.fn(async (callback: (client: typeof prisma) => unknown) =>
      callback(prisma),
    ),
  };

  let service: NumberingService;

  beforeEach(() => {
    jest.clearAllMocks();
    prisma.order = {
      findFirst: jest.fn().mockResolvedValue(null),
    };
    prisma.payment = {
      findFirst: jest.fn().mockResolvedValue(null),
    };
    prisma.expense = {
      findFirst: jest.fn().mockResolvedValue(null),
    };
    prisma.systemSetting = {
      findFirst: jest.fn().mockResolvedValue(null),
    };
    service = new NumberingService(prisma as never, auditService as never);
  });

  it('generates daily ORD numbers sequentially', async () => {
    const date = new Date('2026-08-09T10:00:00.000Z');
    const resetDate = new Date(date);
    resetDate.setHours(0, 0, 0, 0);

    prisma.$queryRaw.mockResolvedValueOnce([
      {
        id: '1',
        type: 'ORD',
        prefix: 'YL',
        current_counter: 2,
        padding: 6,
        daily_reset: true,
        last_reset_date: resetDate,
        is_active: true,
      },
    ]);

    const number = await service.generateNumber('ORD', undefined, date);

    expect(number).toBe(formatDailyNumber('YL', 3, 6, date));
    expect(prisma.$executeRaw).toHaveBeenCalled();
  });

  it('generates CST numbers without date segment', async () => {
    prisma.$queryRaw.mockResolvedValueOnce([
      {
        id: '1',
        type: 'CST',
        prefix: 'CUS',
        current_counter: 4,
        padding: 4,
        daily_reset: false,
        last_reset_date: null,
        is_active: true,
      },
    ]);
    prisma.numberingSequence.update.mockResolvedValue({});

    const number = await service.generateNumber('CST');

    expect(number).toBe(formatSequentialNumber('CUS', 5, 4));
  });

  it('syncs ORD daily counter with existing invoice numbers', async () => {
    const date = new Date('2026-08-09T10:00:00.000Z');
    const resetDate = new Date(date);
    resetDate.setHours(0, 0, 0, 0);

    prisma.$queryRaw.mockResolvedValueOnce([
      {
        id: '1',
        type: 'ORD',
        prefix: 'YL',
        current_counter: 0,
        padding: 6,
        daily_reset: true,
        last_reset_date: resetDate,
        is_active: true,
      },
    ]);
    prisma.order = {
      findFirst: jest.fn().mockResolvedValue({
        invoiceNumber: formatDailyNumber('YL', 3, 6, date),
      }),
    };

    const number = await service.generateNumber('ORD', undefined, date);

    expect(number).toBe(formatDailyNumber('YL', 4, 6, date));
    expect(prisma.$executeRaw).toHaveBeenCalled();
  });

  it('syncs PAY daily counter with existing payment references', async () => {
    const date = new Date('2026-08-09T10:00:00.000Z');
    const resetDate = new Date(date);
    resetDate.setHours(0, 0, 0, 0);

    prisma.$queryRaw.mockResolvedValueOnce([
      {
        id: '1',
        type: 'PAY',
        prefix: 'PAY',
        current_counter: 0,
        padding: 6,
        daily_reset: true,
        last_reset_date: resetDate,
        is_active: true,
      },
    ]);
    prisma.payment = {
      findFirst: jest.fn().mockResolvedValue({
        referenceNumber: formatDailyNumber('PAY', 2, 6, date),
      }),
    };

    const number = await service.generateNumber('PAY', undefined, date);

    expect(number).toBe(formatDailyNumber('PAY', 3, 6, date));
    expect(prisma.$executeRaw).toHaveBeenCalled();
  });

  it('rejects invalid numbering type configuration lookup', async () => {
    await expect(service.getConfiguration('INVALID')).rejects.toBeInstanceOf(
      NotFoundException,
    );
  });

  it('prevents duplicate numbers under concurrent generation', async () => {
    let invocation = 0;
    prisma.$queryRaw.mockImplementation(async () => {
      const currentCounter = invocation;
      invocation += 1;
      return [
        {
          id: '1',
          type: 'PAY',
          prefix: 'PAY',
          current_counter: currentCounter,
          padding: 6,
          daily_reset: false,
          last_reset_date: null,
          is_active: true,
        },
      ];
    });
    prisma.numberingSequence.update.mockResolvedValue({});

    const results = await Promise.all([
      service.generateNumber('PAY'),
      service.generateNumber('PAY'),
    ]);

    expect(new Set(results).size).toBe(2);
    expect(results).toEqual([
      formatSequentialNumber('PAY', 1, 6),
      formatSequentialNumber('PAY', 2, 6),
    ]);
  });
});
