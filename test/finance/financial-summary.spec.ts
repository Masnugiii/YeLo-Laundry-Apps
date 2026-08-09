import { FinancePeriod } from '../../src/finance/dto/report.dto';
import { ReportService } from '../../src/finance/report.service';

describe('ReportService.getFinancialSummary', () => {
  const paymentService = {
    findAll: jest.fn(),
  };

  const prisma = {
    payment: {
      count: jest.fn(),
      findMany: jest.fn(),
      aggregate: jest.fn(),
    },
    expense: {
      findMany: jest.fn(),
    },
    cashflow: {
      findMany: jest.fn(),
      aggregate: jest.fn(),
    },
    walletTransaction: {
      groupBy: jest.fn(),
    },
    customerWallet: {
      aggregate: jest.fn(),
    },
    order: {
      findMany: jest.fn(),
    },
    systemSetting: {
      findUnique: jest.fn(),
    },
  };

  let service: ReportService;

  beforeEach(() => {
    jest.clearAllMocks();
    service = new ReportService(
      prisma as never,
      paymentService as never,
    );
  });

  it('aggregates revenue, expense, payment, wallet, and profit/loss for a period', async () => {
    prisma.payment.count.mockResolvedValue(12);
    prisma.expense.findMany.mockResolvedValue([
      {
        amount: 150000,
        expenseCategory: { code: 'UTIL', name: 'Utilities' },
      },
      {
        amount: 50000,
        expenseCategory: { code: 'UTIL', name: 'Utilities' },
      },
    ]);
    prisma.cashflow.findMany.mockResolvedValue([
      {
        transactionDate: new Date('2026-08-01T10:00:00.000Z'),
        type: 'INCOME',
        amount: 500000,
      },
      {
        transactionDate: new Date('2026-08-02T10:00:00.000Z'),
        type: 'EXPENSE',
        amount: 100000,
      },
    ]);
    prisma.walletTransaction.groupBy.mockResolvedValue([
      { type: 'top_up', _sum: { amount: 300000 } },
      { type: 'deduction', _sum: { amount: 120000 } },
      { type: 'refund', _sum: { amount: 20000 } },
    ]);
    prisma.customerWallet.aggregate.mockResolvedValue({
      _sum: { currentBalance: 1500000 },
      _count: 42,
    });
    prisma.systemSetting.findUnique.mockResolvedValue({
      settingValue: '2500000',
    });
    prisma.cashflow.aggregate
      .mockResolvedValueOnce({ _sum: { amount: 2500000 } })
      .mockResolvedValueOnce({ _sum: { amount: 200000 } });

    jest.spyOn(service, 'getPaymentHistory').mockResolvedValue({
      success: true,
      message: 'ok',
      data: {
        cash: 1000000,
        transfer: 500000,
        qris: 300000,
        wallet: 200000,
        outstanding: 150000,
        refund: 50000,
      },
    });
    jest.spyOn(service, 'getProfitLoss').mockResolvedValue({
      success: true,
      message: 'ok',
      data: {
        period: FinancePeriod.MONTHLY,
        summary: {
          revenue: 2500000,
          expenses: 200000,
          payroll: 2500000,
          refunds: 50000,
          grossProfit: 2300000,
          operatingProfit: -200000,
          netProfit: -250000,
        },
        periods: [],
      },
    });

    const result = await service.getFinancialSummary({
      period: FinancePeriod.MONTHLY,
    });

    expect(result.success).toBe(true);
    expect(result.data?.revenue.total).toBe(2500000);
    expect(result.data?.revenue.paymentCount).toBe(12);
    expect(result.data?.expense.total).toBe(200000);
    expect(result.data?.expense.expenseCount).toBe(2);
    expect(result.data?.expense.byCategory).toEqual([
      {
        categoryCode: 'UTIL',
        categoryName: 'Utilities',
        amount: 200000,
        count: 2,
      },
    ]);
    expect(result.data?.payment.cash).toBe(1000000);
    expect(result.data?.wallet.topUp).toBe(300000);
    expect(result.data?.wallet.currentBalance).toBe(1500000);
    expect(result.data?.profitLoss.netProfit).toBe(-250000);
    expect(result.data?.trend.length).toBeGreaterThan(0);
  });
});
