import { Injectable } from '@nestjs/common';
import {
  CashflowType,
  OrderPaymentStatus,
  PaymentStatus,
  ReferenceType,
} from '@prisma/client';
import { PrismaService } from '../database/prisma/prisma.service';
import { ApiSuccessResponse } from '../common/interfaces/api-response.interface';
import { parsePayrollLatestTotal } from '../common/utils/payroll-latest-total.util';
import { decodeOrderNotes } from '../order/utils/order-meta.util';
import { calculateOrderTotals } from '../order/order.mapper';
import {
  FinancePeriod,
  FinanceReportQueryDto,
  FinanceRevenueQueryDto,
} from './dto/report.dto';
import { PaymentQueryDto } from './dto/payment.dto';
import { PaymentService } from './payment.service';

export interface OwnerSummary {
  revenueToday: number;
  expenseToday: number;
  profitToday: number;
  revenueThisMonth: number;
  expenseThisMonth: number;
  profitThisMonth: number;
}

export interface PaymentMethodSummary {
  method: string;
  label: string;
  amount: number;
  count: number;
}

export interface FinanceTrendPoint {
  label: string;
  date: string;
  revenue: number;
  expenses: number;
  netProfit: number;
  orderCount: number;
}

export interface FinanceDashboard {
  revenueToday: number;
  revenueThisWeek: number;
  revenueThisMonth: number;
  revenueThisYear: number;
  outstandingPayment: number;
  cashIncome: number;
  digitalPayment: number;
  refundAmount: number;
  expenseAmount: number;
  payrollAmount: number;
  profitEstimate: number;
  netProfit: number;
  averageOrderValue: number;
  ownerSummary: OwnerSummary;
  paymentMethodBreakdown: PaymentMethodSummary[];
  trends: FinanceTrendPoint[];
  topServices: Array<{
    serviceId: string;
    serviceName: string;
    serviceCode: string;
    orderCount: number;
    revenue: number;
  }>;
  topCustomers: Array<{
    customerId: string;
    customerName: string;
    customerCode: string;
    orderCount: number;
    revenue: number;
  }>;
}

export interface RevenueListItem {
  id: string;
  invoice: string;
  orderNumber: string;
  customerName: string;
  customerPhone: string;
  paymentMethod: string;
  amount: number;
  paidDate: string;
  cashier: string;
  status: string;
}

export interface PaginatedRevenue {
  items: RevenueListItem[];
  meta: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}

export interface ProfitLossSummary {
  revenue: number;
  expenses: number;
  payroll: number;
  refunds: number;
  grossProfit: number;
  operatingProfit: number;
  netProfit: number;
}

export interface ProfitLossPeriod {
  label: string;
  date: string;
  revenue: number;
  expenses: number;
  payroll: number;
  netProfit: number;
}

export interface ProfitLossReport {
  period: FinancePeriod;
  summary: ProfitLossSummary;
  periods: ProfitLossPeriod[];
}

export interface CashFlowEntry {
  id: string;
  type: 'INCOME' | 'EXPENSE';
  referenceType: string;
  amount: number;
  description: string | null;
  transactionDate: string;
  runningBalance: number;
}

export interface CashFlowReport {
  moneyIn: number;
  moneyOut: number;
  endingBalance: number;
  entries: CashFlowEntry[];
}

export interface PaymentHistorySummary {
  cash: number;
  transfer: number;
  qris: number;
  wallet: number;
  outstanding: number;
  refund: number;
}

@Injectable()
export class ReportService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly paymentService: PaymentService,
  ) {}

  async getDashboard(): Promise<ApiSuccessResponse<FinanceDashboard>> {
    const now = new Date();
    const startOfToday = this.startOfDay(now);
    const endOfToday = this.endOfDay(now);
    const startOfWeek = new Date(startOfToday);
    startOfWeek.setDate(startOfWeek.getDate() - startOfWeek.getDay());
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
    const startOfYear = new Date(now.getFullYear(), 0, 1);

    const [
      revenueToday,
      revenueThisWeek,
      revenueThisMonth,
      revenueThisYear,
      expenseToday,
      expenseMonth,
      refundAmount,
      cashIncome,
      digitalPayment,
      payrollSetting,
      unpaidOrders,
      paidOrdersCount,
      topServiceRows,
      topCustomerRows,
      paymentMethodRows,
      trendRows,
    ] = await this.prisma.$transaction([
      this.sumIncome(startOfToday, endOfToday),
      this.sumIncome(startOfWeek),
      this.sumIncome(startOfMonth),
      this.sumIncome(startOfYear),
      this.sumExpense(startOfToday, endOfToday),
      this.sumExpense(startOfMonth),
      this.sumRefunds(startOfMonth),
      this.sumPaymentsByMethod('CASH', startOfMonth),
      this.sumDigitalPayments(startOfMonth),
      this.prisma.systemSetting.findUnique({
        where: { settingKey: 'payroll.latest_total' },
      }),
      this.prisma.order.findMany({
        where: {
          deletedAt: null,
          paymentStatus: OrderPaymentStatus.UNPAID,
          orderStatus: { not: 'CANCELLED' },
        },
        select: {
          notes: true,
          items: {
            where: { deletedAt: null },
            select: { subtotal: true },
          },
          payments: {
            where: {
              deletedAt: null,
              paymentStatus: PaymentStatus.PAID,
            },
            select: { amount: true },
          },
        },
      }),
      this.prisma.payment.count({
        where: {
          deletedAt: null,
          paymentStatus: PaymentStatus.PAID,
          paidAt: { gte: startOfMonth },
        },
      }),
      this.prisma.orderItem.groupBy({
        by: ['serviceId'],
        where: {
          deletedAt: null,
          order: {
            deletedAt: null,
            paymentStatus: OrderPaymentStatus.PAID,
          },
        },
        _count: { _all: true },
        _sum: { subtotal: true },
        orderBy: { _sum: { subtotal: 'desc' } },
        take: 5,
      }),
      this.prisma.order.groupBy({
        by: ['customerId'],
        where: {
          deletedAt: null,
          paymentStatus: OrderPaymentStatus.PAID,
        },
        _count: { _all: true },
        orderBy: { _count: { customerId: 'desc' } },
        take: 5,
      }),
      this.prisma.payment.groupBy({
        by: ['paymentMethodId'],
        where: {
          deletedAt: null,
          paymentStatus: PaymentStatus.PAID,
          paidAt: { gte: startOfMonth },
        },
        _sum: { amount: true },
        _count: { _all: true },
        orderBy: { paymentMethodId: 'asc' },
      }),
      this.prisma.cashflow.findMany({
        where: { transactionDate: { gte: this.daysAgo(30) } },
        orderBy: { transactionDate: 'asc' },
        select: {
          transactionDate: true,
          type: true,
          amount: true,
        },
      }),
    ]);

    const revenueTodayAmount = Number(revenueToday._sum.amount ?? 0);
    const revenueWeekAmount = Number(revenueThisWeek._sum.amount ?? 0);
    const revenueMonthAmount = Number(revenueThisMonth._sum.amount ?? 0);
    const revenueYearAmount = Number(revenueThisYear._sum.amount ?? 0);
    const expenseTodayAmount = Number(expenseToday._sum.amount ?? 0);
    const expenseMonthAmount = Number(expenseMonth._sum.amount ?? 0);
    const refundMonthAmount = Number(refundAmount._sum.amount ?? 0);
    const payrollAmount = parsePayrollLatestTotal(payrollSetting?.settingValue);
    const cashIncomeAmount = Number(cashIncome._sum.amount ?? 0);
    const digitalPaymentAmount = Number(digitalPayment._sum.amount ?? 0);

    const outstandingPayment = unpaidOrders.reduce((total, order) => {
      const { meta } = decodeOrderNotes(order.notes);
      const itemsSubtotal = order.items.reduce(
        (sum, item) => sum + Number(item.subtotal),
        0,
      );
      const grandTotal = calculateOrderTotals(itemsSubtotal, meta).grandTotal;
      const paid = order.payments.reduce(
        (sum, payment) => sum + Number(payment.amount),
        0,
      );
      return total + Math.max(grandTotal - paid, 0);
    }, 0);

    const profitEstimate = Number(
      (revenueMonthAmount - expenseMonthAmount - refundMonthAmount).toFixed(2),
    );
    const netProfit = Number(
      (profitEstimate - payrollAmount).toFixed(2),
    );
    const averageOrderValue =
      paidOrdersCount > 0
        ? Number((revenueMonthAmount / paidOrdersCount).toFixed(2))
        : 0;

    const serviceIds = topServiceRows.map((row) => row.serviceId);
    const services = await this.prisma.service.findMany({
      where: { id: { in: serviceIds } },
      select: { id: true, serviceName: true, serviceCode: true },
    });
    const serviceMap = new Map(services.map((service) => [service.id, service]));

    const customerIds = topCustomerRows.map((row) => row.customerId);
    const customers = await this.prisma.customer.findMany({
      where: { id: { in: customerIds } },
      select: { id: true, fullName: true, customerCode: true },
    });
    const customerMap = new Map(
      customers.map((customer) => [customer.id, customer]),
    );

    const customerRevenue = await Promise.all(
      topCustomerRows.map(async (row) => {
        const payments = await this.prisma.payment.aggregate({
          where: {
            deletedAt: null,
            paymentStatus: PaymentStatus.PAID,
            order: {
              customerId: row.customerId,
              deletedAt: null,
            },
          },
          _sum: { amount: true },
        });
        const customer = customerMap.get(row.customerId);
        return {
          customerId: row.customerId,
          customerName: customer?.fullName ?? 'Unknown',
          customerCode: customer?.customerCode ?? '',
          orderCount:
            typeof row._count === 'object' ? (row._count._all ?? 0) : 0,
          revenue: Number(payments._sum.amount ?? 0),
        };
      }),
    );

    const paymentMethods = await this.prisma.paymentMethod.findMany({
      where: {
        id: {
          in: paymentMethodRows.map((row) => row.paymentMethodId),
        },
      },
      select: { id: true, code: true, name: true },
    });
    const paymentMethodMap = new Map(
      paymentMethods.map((method) => [method.id, method]),
    );

    const paymentMethodBreakdown = paymentMethodRows.map((row) => {
      const method = paymentMethodMap.get(row.paymentMethodId);
      return {
        method: method?.code ?? 'UNKNOWN',
        label: method?.name ?? 'Unknown',
        amount: Number(row._sum?.amount ?? 0),
        count: typeof row._count === 'object' ? (row._count._all ?? 0) : 0,
      };
    });

    const trends = this.buildDailyTrends(trendRows);

    return {
      success: true,
      message: 'Finance dashboard retrieved successfully',
      data: {
        revenueToday: revenueTodayAmount,
        revenueThisWeek: revenueWeekAmount,
        revenueThisMonth: revenueMonthAmount,
        revenueThisYear: revenueYearAmount,
        outstandingPayment: Number(outstandingPayment.toFixed(2)),
        cashIncome: cashIncomeAmount,
        digitalPayment: digitalPaymentAmount,
        refundAmount: refundMonthAmount,
        expenseAmount: expenseMonthAmount,
        payrollAmount,
        profitEstimate,
        netProfit,
        averageOrderValue,
        ownerSummary: {
          revenueToday: revenueTodayAmount,
          expenseToday: expenseTodayAmount,
          profitToday: Number(
            (revenueTodayAmount - expenseTodayAmount).toFixed(2),
          ),
          revenueThisMonth: revenueMonthAmount,
          expenseThisMonth: expenseMonthAmount,
          profitThisMonth: netProfit,
        },
        paymentMethodBreakdown,
        trends,
        topServices: topServiceRows.map((row) => {
          const service = serviceMap.get(row.serviceId);
          return {
            serviceId: row.serviceId,
            serviceName: service?.serviceName ?? 'Unknown',
            serviceCode: service?.serviceCode ?? '',
            orderCount:
              typeof row._count === 'object' ? (row._count._all ?? 0) : 0,
            revenue: Number(row._sum?.subtotal ?? 0),
          };
        }),
        topCustomers: customerRevenue.sort((a, b) => b.revenue - a.revenue),
      },
    };
  }

  async getRevenue(
    query: FinanceRevenueQueryDto,
  ): Promise<ApiSuccessResponse<PaginatedRevenue>> {
    const paymentQuery: PaymentQueryDto = {
      page: query.page,
      limit: query.limit,
      search: query.search,
      customerId: query.customerId,
      employeeId: query.employeeId,
      paymentMethod: query.paymentMethod as PaymentQueryDto['paymentMethod'],
      paymentStatus: query.paymentStatus as PaymentQueryDto['paymentStatus'],
      dateFrom: query.dateFrom,
      dateTo: query.dateTo,
    };

    const result = await this.paymentService.findAll(paymentQuery);
    const payments = result.data?.items ?? [];
    const meta = result.data?.meta ?? {
      page: query.page ?? 1,
      limit: query.limit ?? 25,
      total: 0,
      totalPages: 1,
    };

    return {
      success: true,
      message: 'Revenue records retrieved successfully',
      data: {
        items: payments.map((payment) => ({
          id: payment.id,
          invoice: payment.referenceNumber ?? payment.orderNumber,
          orderNumber: payment.orderNumber,
          customerName: payment.customer.fullName,
          customerPhone: payment.customer.phone,
          paymentMethod: payment.paymentMethod.name,
          amount: payment.netAmount,
          paidDate: payment.paidAt.toISOString(),
          cashier: payment.receivedBy.fullName,
          status: payment.displayStatus,
        })),
        meta,
      },
    };
  }

  async getProfitLoss(
    query: FinanceReportQueryDto,
  ): Promise<ApiSuccessResponse<ProfitLossReport>> {
    const period = query.period ?? FinancePeriod.MONTHLY;
    const { start, end } = this.resolveRange(period, query.dateFrom, query.dateTo);
    const payrollAmount = await this.getPayrollAmount();

    const cashflows = await this.prisma.cashflow.findMany({
      where: {
        transactionDate: { gte: start, lte: end },
      },
      orderBy: { transactionDate: 'asc' },
      select: {
        transactionDate: true,
        type: true,
        referenceType: true,
        amount: true,
      },
    });

    const periods = this.bucketCashflows(cashflows, period, payrollAmount);
    const summary = periods.reduce<ProfitLossSummary>(
      (acc, item) => ({
        revenue: acc.revenue + item.revenue,
        expenses: acc.expenses + item.expenses,
        payroll: acc.payroll + item.payroll,
        refunds: acc.refunds,
        grossProfit: 0,
        operatingProfit: 0,
        netProfit: 0,
      }),
      {
        revenue: 0,
        expenses: 0,
        payroll: payrollAmount,
        refunds: 0,
        grossProfit: 0,
        operatingProfit: 0,
        netProfit: 0,
      },
    );

    const refunds = cashflows
      .filter((entry) => entry.referenceType === ReferenceType.REFUND)
      .reduce((sum, entry) => sum + Number(entry.amount), 0);

    summary.refunds = refunds;
    summary.grossProfit = Number((summary.revenue - summary.expenses).toFixed(2));
    summary.operatingProfit = Number(
      (summary.grossProfit - summary.payroll).toFixed(2),
    );
    summary.netProfit = Number(
      (summary.operatingProfit - summary.refunds).toFixed(2),
    );

    return {
      success: true,
      message: 'Profit and loss report retrieved successfully',
      data: {
        period,
        summary,
        periods,
      },
    };
  }

  async getCashFlow(
    query: FinanceReportQueryDto,
  ): Promise<ApiSuccessResponse<CashFlowReport>> {
    const { start, end } = this.resolveRange(
      query.period ?? FinancePeriod.MONTHLY,
      query.dateFrom,
      query.dateTo,
    );

    const entries = await this.prisma.cashflow.findMany({
      where: { transactionDate: { gte: start, lte: end } },
      orderBy: { transactionDate: 'asc' },
      select: {
        id: true,
        type: true,
        referenceType: true,
        amount: true,
        description: true,
        transactionDate: true,
      },
    });

    let runningBalance = 0;
    let moneyIn = 0;
    let moneyOut = 0;

    const mapped = entries.map((entry) => {
      const amount = Number(entry.amount);
      if (entry.type === CashflowType.INCOME) {
        moneyIn += amount;
        runningBalance += amount;
      } else {
        moneyOut += amount;
        runningBalance -= amount;
      }

      return {
        id: entry.id,
        type: entry.type,
        referenceType: entry.referenceType,
        amount,
        description: entry.description,
        transactionDate: entry.transactionDate.toISOString(),
        runningBalance: Number(runningBalance.toFixed(2)),
      };
    });

    return {
      success: true,
      message: 'Cash flow report retrieved successfully',
      data: {
        moneyIn: Number(moneyIn.toFixed(2)),
        moneyOut: Number(moneyOut.toFixed(2)),
        endingBalance: Number(runningBalance.toFixed(2)),
        entries: mapped,
      },
    };
  }

  async getPaymentHistory(
    query: FinanceReportQueryDto,
  ): Promise<ApiSuccessResponse<PaymentHistorySummary>> {
    const { start, end } = this.resolveRange(
      query.period ?? FinancePeriod.MONTHLY,
      query.dateFrom,
      query.dateTo,
    );

    const payments = await this.prisma.payment.findMany({
      where: {
        deletedAt: null,
        paidAt: { gte: start, lte: end },
      },
      select: {
        amount: true,
        paymentStatus: true,
        paymentMethod: { select: { code: true } },
      },
    });

    const refunds = await this.prisma.cashflow.aggregate({
      where: {
        type: CashflowType.EXPENSE,
        referenceType: ReferenceType.REFUND,
        transactionDate: { gte: start, lte: end },
      },
      _sum: { amount: true },
    });

    const outstandingAmount = await this.calculateOutstandingPayment();

    const summary: PaymentHistorySummary = {
      cash: 0,
      transfer: 0,
      qris: 0,
      wallet: 0,
      outstanding: outstandingAmount,
      refund: Number(refunds._sum.amount ?? 0),
    };

    for (const payment of payments) {
      if (payment.paymentStatus !== PaymentStatus.PAID) continue;
      const amount = Number(payment.amount);
      switch (payment.paymentMethod.code) {
        case 'CASH':
          summary.cash += amount;
          break;
        case 'BANK_TRANSFER':
          summary.transfer += amount;
          break;
        case 'QRIS':
          summary.qris += amount;
          break;
        case 'YELO_WALLET':
          summary.wallet += amount;
          break;
        default:
          summary.transfer += amount;
      }
    }

    return {
      success: true,
      message: 'Payment history summary retrieved successfully',
      data: summary,
    };
  }

  private async calculateOutstandingPayment() {
    const unpaidOrders = await this.prisma.order.findMany({
      where: {
        deletedAt: null,
        paymentStatus: OrderPaymentStatus.UNPAID,
        orderStatus: { not: 'CANCELLED' },
      },
      select: {
        notes: true,
        items: {
          where: { deletedAt: null },
          select: { subtotal: true },
        },
        payments: {
          where: {
            deletedAt: null,
            paymentStatus: PaymentStatus.PAID,
          },
          select: { amount: true },
        },
      },
    });

    return Number(
      unpaidOrders
        .reduce((total, order) => {
          const { meta } = decodeOrderNotes(order.notes);
          const itemsSubtotal = order.items.reduce(
            (sum, item) => sum + Number(item.subtotal),
            0,
          );
          const grandTotal = calculateOrderTotals(itemsSubtotal, meta).grandTotal;
          const paid = order.payments.reduce(
            (sum, payment) => sum + Number(payment.amount),
            0,
          );
          return total + Math.max(grandTotal - paid, 0);
        }, 0)
        .toFixed(2),
    );
  }

  private startOfDay(date: Date) {
    return new Date(date.getFullYear(), date.getMonth(), date.getDate());
  }

  private endOfDay(date: Date) {
    const end = this.startOfDay(date);
    end.setHours(23, 59, 59, 999);
    return end;
  }

  private daysAgo(days: number) {
    const date = new Date();
    date.setDate(date.getDate() - days);
    return this.startOfDay(date);
  }

  private sumIncome(start: Date, end?: Date) {
    return this.prisma.cashflow.aggregate({
      where: {
        type: CashflowType.INCOME,
        referenceType: ReferenceType.ORDER_PAYMENT,
        transactionDate: end ? { gte: start, lte: end } : { gte: start },
      },
      _sum: { amount: true },
    });
  }

  private sumExpense(start: Date, end?: Date) {
    return this.prisma.cashflow.aggregate({
      where: {
        type: CashflowType.EXPENSE,
        referenceType: ReferenceType.EXPENSE,
        transactionDate: end ? { gte: start, lte: end } : { gte: start },
      },
      _sum: { amount: true },
    });
  }

  private sumRefunds(start: Date) {
    return this.prisma.cashflow.aggregate({
      where: {
        type: CashflowType.EXPENSE,
        referenceType: ReferenceType.REFUND,
        transactionDate: { gte: start },
      },
      _sum: { amount: true },
    });
  }

  private sumPaymentsByMethod(code: string, start: Date) {
    return this.prisma.payment.aggregate({
      where: {
        deletedAt: null,
        paymentStatus: PaymentStatus.PAID,
        paidAt: { gte: start },
        paymentMethod: { code },
      },
      _sum: { amount: true },
    });
  }

  private sumDigitalPayments(start: Date) {
    return this.prisma.payment.aggregate({
      where: {
        deletedAt: null,
        paymentStatus: PaymentStatus.PAID,
        paidAt: { gte: start },
        paymentMethod: { code: { not: 'CASH' } },
      },
      _sum: { amount: true },
    });
  }

  private async getPayrollAmount() {
    const setting = await this.prisma.systemSetting.findUnique({
      where: { settingKey: 'payroll.latest_total' },
    });
    return parsePayrollLatestTotal(setting?.settingValue);
  }

  private resolveRange(
    period: FinancePeriod,
    dateFrom?: Date,
    dateTo?: Date,
  ) {
    if (dateFrom && dateTo) {
      return { start: dateFrom, end: dateTo };
    }

    const now = new Date();
    const end = this.endOfDay(now);
    let start = this.startOfDay(now);

    switch (period) {
      case FinancePeriod.DAILY:
        break;
      case FinancePeriod.WEEKLY:
        start.setDate(start.getDate() - 6);
        break;
      case FinancePeriod.MONTHLY:
        start = new Date(now.getFullYear(), now.getMonth(), 1);
        break;
      case FinancePeriod.YEARLY:
        start = new Date(now.getFullYear(), 0, 1);
        break;
    }

    return { start, end };
  }

  private buildDailyTrends(
    rows: Array<{
      transactionDate: Date;
      type: CashflowType;
      amount: { toString(): string };
    }>,
  ): FinanceTrendPoint[] {
    const map = new Map<string, FinanceTrendPoint>();

    for (const row of rows) {
      const key = row.transactionDate.toISOString().slice(0, 10);
      const current = map.get(key) ?? {
        label: key,
        date: key,
        revenue: 0,
        expenses: 0,
        netProfit: 0,
        orderCount: 0,
      };

      const amount = Number(row.amount);
      if (row.type === CashflowType.INCOME) {
        current.revenue += amount;
        current.orderCount += 1;
      } else {
        current.expenses += amount;
      }
      current.netProfit = Number(
        (current.revenue - current.expenses).toFixed(2),
      );
      map.set(key, current);
    }

    return [...map.values()].sort((a, b) => a.date.localeCompare(b.date));
  }

  private bucketCashflows(
    cashflows: Array<{
      transactionDate: Date;
      type: CashflowType;
      referenceType: ReferenceType;
      amount: { toString(): string };
    }>,
    period: FinancePeriod,
    payrollAmount: number,
  ): ProfitLossPeriod[] {
    const map = new Map<string, ProfitLossPeriod>();

    for (const entry of cashflows) {
      const key = this.bucketKey(entry.transactionDate, period);
      const current = map.get(key) ?? {
        label: key,
        date: key,
        revenue: 0,
        expenses: 0,
        payroll: 0,
        netProfit: 0,
      };

      const amount = Number(entry.amount);
      if (entry.type === CashflowType.INCOME) {
        current.revenue += amount;
      } else if (entry.referenceType === ReferenceType.EXPENSE) {
        current.expenses += amount;
      }

      current.netProfit = Number(
        (current.revenue - current.expenses).toFixed(2),
      );
      map.set(key, current);
    }

    const periods = [...map.values()].sort((a, b) => a.date.localeCompare(b.date));
    if (periods.length > 0 && payrollAmount > 0) {
      periods[periods.length - 1].payroll = payrollAmount;
      periods[periods.length - 1].netProfit = Number(
        (
          periods[periods.length - 1].revenue -
          periods[periods.length - 1].expenses -
          payrollAmount
        ).toFixed(2),
      );
    }

    return periods;
  }

  private bucketKey(date: Date, period: FinancePeriod) {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');

    switch (period) {
      case FinancePeriod.DAILY:
        return `${year}-${month}-${day}`;
      case FinancePeriod.WEEKLY: {
        const weekStart = new Date(date);
        weekStart.setDate(weekStart.getDate() - weekStart.getDay());
        return weekStart.toISOString().slice(0, 10);
      }
      case FinancePeriod.MONTHLY:
        return `${year}-${month}`;
      case FinancePeriod.YEARLY:
      default:
        return `${year}`;
    }
  }
}
