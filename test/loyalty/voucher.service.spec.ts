import { Test, TestingModule } from '@nestjs/testing';
import { VoucherService } from '../../src/loyalty/voucher.service';
import { PrismaService } from '../../src/database/prisma/prisma.service';

describe('VoucherService', () => {
  let service: VoucherService;

  const prismaMock = {
    loyaltyVoucher: {
      findMany: jest.fn(),
      count: jest.fn(),
      findFirst: jest.fn(),
      create: jest.fn(),
      update: jest.fn(),
    },
    $transaction: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        VoucherService,
        { provide: PrismaService, useValue: prismaMock },
      ],
    }).compile();

    service = module.get(VoucherService);
    jest.clearAllMocks();
  });

  it('calculates percentage discount with max cap', () => {
    const amount = service.calculateDiscountAmount(
      {
        id: '1',
        code: 'YELO20',
        name: 'Promo',
        description: null,
        discountType: 'PERCENTAGE',
        discountValue: { toString: () => '20' },
        maxDiscount: { toString: () => '15000' },
        cashbackType: null,
        cashbackValue: null,
        cashbackMax: null,
        cashbackExpirationDays: null,
        startDate: new Date('2026-01-01'),
        endDate: new Date('2026-12-31'),
        usageLimit: 0,
        usageCount: 0,
        minimumTransaction: { toString: () => '0' },
        status: 'ACTIVE',
        createdAt: new Date(),
        updatedAt: new Date(),
      },
      100000,
    );

    expect(amount).toBe(15000);
  });

  it('quotes promo total from backend calculation', async () => {
    prismaMock.loyaltyVoucher.findFirst.mockResolvedValue({
      id: 'promo-1',
      code: 'YELO25',
      name: 'Promo 25',
      description: 'Test',
      discountType: 'PERCENTAGE',
      discountValue: { toString: () => '25' },
      maxDiscount: null,
      cashbackType: null,
      cashbackValue: null,
      cashbackMax: null,
      cashbackExpirationDays: null,
      startDate: new Date('2026-01-01'),
      endDate: new Date('2026-12-31'),
      usageLimit: 0,
      usageCount: 0,
      minimumTransaction: { toString: () => '0' },
      status: 'ACTIVE',
      createdAt: new Date(),
      updatedAt: new Date(),
    });

    const quote = await service.quoteCustomerPromo({
      promoId: 'promo-1',
      subtotal: 100000,
    });

    expect(quote.discountPercent).toBe(25);
    expect(quote.discountAmount).toBe(25000);
    expect(quote.total).toBe(75000);
  });
});
