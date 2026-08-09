import { Injectable } from '@nestjs/common';
import {
  CashflowType,
  OrderStatus,
  PaymentStatus,
  PayrollRecordStatus,
  ReferenceType,
  RewardPointType,
  WalletTransactionType,
} from '@prisma/client';
import { parsePayrollLatestTotal } from '../common/utils/payroll-latest-total.util';
import { PrismaService } from '../database/prisma/prisma.service';
import { LoyaltySettingsService } from '../loyalty/loyalty-settings.service';
import { MembershipLevel } from '../loyalty/loyalty.types';
import { ReportQueryDto } from './dto/report-query.dto';
import {
  eachDayInRange,
  formatDayKey,
  formatDayLabel,
  resolveReportRange,
} from './utils/report-date-range.util';

interface TrendPoint {
  label: string;
  date: string;
  value: number;
}

interface NamedValue {
  name: string;
  value: number;
}

export type { TrendPoint, NamedValue };

@Injectable()
export class ReportsService {
  private dashboardCache: {
    key: string;
    expiresAt: number;
    data: Record<string, unknown>;
  } | null = null;

  constructor(
    private readonly prisma: PrismaService,
    private readonly loyaltySettings: LoyaltySettingsService,
  ) {}

  async getExecutiveDashboard(query: ReportQueryDto) {
    const range = resolveReportRange(query.period, query.dateFrom, query.dateTo);
    const cacheKey = `exec:${range.preset}:${range.dateFrom.toISOString()}:${range.dateTo.toISOString()}`;
    const now = Date.now();
    if (
      this.dashboardCache &&
      this.dashboardCache.key === cacheKey &&
      this.dashboardCache.expiresAt > now
    ) {
      return this.dashboardCache.data;
    }

    const todayStart = this.startOfDay(new Date());
    const todayEnd = this.endOfDay(new Date());
    const weekStart = new Date(todayStart);
    weekStart.setDate(weekStart.getDate() - weekStart.getDay());
    const monthStart = new Date(new Date().getFullYear(), new Date().getMonth(), 1);

    const pendingStatuses: OrderStatus[] = [
      OrderStatus.CREATED,
      OrderStatus.WAITING_PAYMENT,
      OrderStatus.PAYMENT_CONFIRMED,
      OrderStatus.WAITING_BINATU,
      OrderStatus.IRONING_ACCEPTED,
      OrderStatus.CURRENTLY_IRONING,
      OrderStatus.FINISHED_IRONING,
      OrderStatus.READY_FOR_PICKUP,
      OrderStatus.WAITING_PICKUP_DRIVER,
      OrderStatus.PICKUP_COMPLETED,
      OrderStatus.WAITING_DELIVERY,
      OrderStatus.OUT_FOR_DELIVERY,
      OrderStatus.DELIVERED,
    ];

    const orderWhere = {
      deletedAt: null,
      orderDate: { gte: range.dateFrom, lte: range.dateTo },
      ...(query.customerId ? { customerId: query.customerId } : {}),
      ...(query.employeeId ? { createdByEmployeeId: query.employeeId } : {}),
    };

    const data = await this.buildExecutiveDashboardData(
      range,
      todayStart,
      todayEnd,
      weekStart,
      monthStart,
      pendingStatuses,
      orderWhere,
    );

    this.dashboardCache = { key: cacheKey, expiresAt: now + 60_000, data };
    return data;
  }

  private async buildExecutiveDashboardData(
    range: ReturnType<typeof resolveReportRange>,
    todayStart: Date,
    todayEnd: Date,
    weekStart: Date,
    monthStart: Date,
    pendingStatuses: OrderStatus[],
    orderWhere: Record<string, unknown>,
  ) {
    const [
      revenueToday,
      revenueWeek,
      revenueMonth,
      expenseMonth,
      payrollSetting,
      totalOrders,
      completedOrders,
      pendingOrders,
      cancelledOrders,
      paymentAgg,
      laundryKgToday,
      laundryKgMonth,
      pickupToday,
      deliveryToday,
      attendanceToday,
      payrollPeriod,
      walletBalance,
      rewardPointsIssued,
      newCustomers,
      returningCustomers,
    ] = await Promise.all([
      this.sumIncome(todayStart, todayEnd),
      this.sumIncome(weekStart, todayEnd),
      this.sumIncome(monthStart, todayEnd),
      this.sumExpense(monthStart, todayEnd),
      this.prisma.systemSetting.findUnique({
        where: { settingKey: 'payroll.latest_total' },
      }),
      this.prisma.order.count({ where: orderWhere }),
      this.prisma.order.count({
        where: { ...orderWhere, orderStatus: OrderStatus.COMPLETED },
      }),
      this.prisma.order.count({
        where: { ...orderWhere, orderStatus: { in: pendingStatuses } },
      }),
      this.prisma.order.count({
        where: { ...orderWhere, orderStatus: OrderStatus.CANCELLED },
      }),
      this.prisma.payment.aggregate({
        where: {
          deletedAt: null,
          paymentStatus: PaymentStatus.PAID,
          paidAt: { gte: range.dateFrom, lte: range.dateTo },
        },
        _sum: { amount: true },
        _count: true,
        _max: { amount: true },
      }),
      this.sumLaundryKg(todayStart, todayEnd),
      this.sumLaundryKg(monthStart, todayEnd),
      this.prisma.pickupJob.count({
        where: {
          deletedAt: null,
          scheduledPickupAt: { gte: todayStart, lte: todayEnd },
        },
      }),
      this.prisma.deliveryJob.count({
        where: {
          deletedAt: null,
          scheduledDeliveryAt: { gte: todayStart, lte: todayEnd },
        },
      }),
      this.prisma.attendance.count({
        where: {
          deletedAt: null,
          attendanceDate: { gte: todayStart, lte: todayEnd },
        },
      }),
      this.prisma.payrollRecord.aggregate({
        where: {
          deletedAt: null,
          periodStart: { lte: todayEnd },
          periodEnd: { gte: monthStart },
        },
        _sum: { netSalary: true },
      }),
      this.prisma.customerWallet.aggregate({
        where: { deletedAt: null, isActive: true },
        _sum: { currentBalance: true },
      }),
      this.prisma.rewardPoint.aggregate({
        where: {
          deletedAt: null,
          type: RewardPointType.earn,
          createdAt: { gte: range.dateFrom, lte: range.dateTo },
        },
        _sum: { point: true },
      }),
      this.prisma.customer.count({
        where: {
          deletedAt: null,
          createdAt: { gte: range.dateFrom, lte: range.dateTo },
        },
      }),
      this.countReturningCustomers(range.dateFrom, range.dateTo),
    ]);

    const revenueMonthValue = Number(revenueMonth._sum.amount ?? 0);
    const expenseValue = Number(expenseMonth._sum.amount ?? 0);
    const payrollValue = Number(payrollPeriod._sum.netSalary ?? 0) ||
      parsePayrollLatestTotal(payrollSetting?.settingValue);
    const paidCount = paymentAgg._count ?? 0;
    const paidTotal = Number(paymentAgg._sum.amount ?? 0);

    const data = {
      period: range.preset,
      dateFrom: range.dateFrom.toISOString(),
      dateTo: range.dateTo.toISOString(),
      revenueToday: Number(revenueToday._sum.amount ?? 0),
      revenueWeek: Number(revenueWeek._sum.amount ?? 0),
      revenueMonth: revenueMonthValue,
      netProfit: revenueMonthValue - expenseValue - payrollValue,
      totalOrders,
      completedOrders,
      pendingOrders,
      cancelledOrders,
      averageOrderValue: paidCount > 0 ? Number((paidTotal / paidCount).toFixed(2)) : 0,
      laundryKgToday: Number(laundryKgToday),
      laundryKgMonth: Number(laundryKgMonth),
      pickupToday,
      deliveryToday,
      attendanceToday,
      payrollThisPeriod: payrollValue,
      walletBalance: Number(walletBalance._sum.currentBalance ?? 0),
      rewardPointsIssued: rewardPointsIssued._sum.point ?? 0,
      newCustomers,
      returningCustomers,
    };

    return data;
  }

  async getSalesReport(query: ReportQueryDto) {
    const range = resolveReportRange(query.period, query.dateFrom, query.dateTo);
    const paymentWhere = {
      deletedAt: null,
      paymentStatus: PaymentStatus.PAID,
      paidAt: { gte: range.dateFrom, lte: range.dateTo },
      ...(query.employeeId ? { receivedByEmployeeId: query.employeeId } : {}),
      ...(query.customerId
        ? { order: { customerId: query.customerId } }
        : {}),
    };

    const [payments, paymentStats, serviceRows, employeeRows, customerRows, cashflowRows] =
      await Promise.all([
        this.prisma.payment.findMany({
          where: paymentWhere,
          select: { amount: true, paidAt: true },
        }),
        this.prisma.payment.aggregate({
          where: paymentWhere,
          _sum: { amount: true },
          _avg: { amount: true },
          _max: { amount: true },
          _count: true,
        }),
        this.prisma.orderItem.groupBy({
          by: ['serviceId'],
          where: {
            deletedAt: null,
            order: {
              deletedAt: null,
              payments: {
                some: paymentWhere,
              },
            },
          },
          _sum: { subtotal: true },
          _count: true,
        }),
        this.prisma.payment.groupBy({
          by: ['receivedByEmployeeId'],
          where: paymentWhere,
          _sum: { amount: true },
          _count: true,
        }),
        this.prisma.payment.groupBy({
          by: ['orderId'],
          where: paymentWhere,
          _sum: { amount: true },
          _count: true,
        }),
        this.prisma.cashflow.findMany({
          where: {
            type: CashflowType.INCOME,
            referenceType: ReferenceType.ORDER_PAYMENT,
            transactionDate: { gte: range.dateFrom, lte: range.dateTo },
          },
          select: { amount: true, transactionDate: true },
        }),
      ]);

    const serviceIds = serviceRows.map((r) => r.serviceId);
    const services = serviceIds.length
      ? await this.prisma.service.findMany({
          where: { id: { in: serviceIds } },
          select: { id: true, serviceName: true, serviceCode: true },
        })
      : [];
    const serviceMap = new Map(services.map((s) => [s.id, s]));

    const employeeIds = employeeRows.map((r) => r.receivedByEmployeeId);
    const employees = employeeIds.length
      ? await this.prisma.employee.findMany({
          where: { id: { in: employeeIds } },
          select: { id: true, fullName: true, employeeCode: true },
        })
      : [];
    const employeeMap = new Map(employees.map((e) => [e.id, e]));

    const orderIds = customerRows.map((r) => r.orderId);
    const orders = orderIds.length
      ? await this.prisma.order.findMany({
          where: { id: { in: orderIds } },
          select: {
            id: true,
            customer: { select: { id: true, fullName: true, customerCode: true } },
          },
        })
      : [];
    const orderCustomerMap = new Map(
      orders.map((o) => [o.id, o.customer]),
    );

    const customerRevenue = new Map<string, { name: string; code: string; revenue: number; orders: number }>();
    for (const row of customerRows) {
      const customer = orderCustomerMap.get(row.orderId);
      if (!customer) continue;
      const existing = customerRevenue.get(customer.id) ?? {
        name: customer.fullName,
        code: customer.customerCode,
        revenue: 0,
        orders: 0,
      };
      existing.revenue += Number(row._sum.amount ?? 0);
      existing.orders += row._count;
      customerRevenue.set(customer.id, existing);
    }

    const dailyMap = new Map<string, number>();
    for (const row of cashflowRows) {
      const key = formatDayKey(row.transactionDate);
      dailyMap.set(key, (dailyMap.get(key) ?? 0) + Number(row.amount));
    }

    const revenuePerDay: TrendPoint[] = eachDayInRange(range.dateFrom, range.dateTo).map(
      (day) => ({
        label: formatDayLabel(day),
        date: formatDayKey(day),
        value: Number((dailyMap.get(formatDayKey(day)) ?? 0).toFixed(2)),
      }),
    );

    return {
      period: range.preset,
      dateFrom: range.dateFrom.toISOString(),
      dateTo: range.dateTo.toISOString(),
      summary: {
        totalRevenue: Number(paymentStats._sum.amount ?? 0),
        averageTransaction: Number(paymentStats._avg.amount ?? 0),
        largestTransaction: Number(paymentStats._max.amount ?? 0),
        transactionCount: paymentStats._count ?? 0,
      },
      revenuePerDay,
      revenuePerWeek: this.bucketByWeek(revenuePerDay),
      revenuePerMonth: [
        {
          label: range.dateFrom.toLocaleDateString('en-GB', { month: 'short', year: 'numeric' }),
          date: formatDayKey(range.dateFrom).slice(0, 7),
          value: Number(paymentStats._sum.amount ?? 0),
        },
      ],
      revenuePerService: serviceRows
        .map((row) => {
          const service = serviceMap.get(row.serviceId);
          return {
            serviceId: row.serviceId,
            serviceName: service?.serviceName ?? 'Unknown',
            serviceCode: service?.serviceCode ?? '-',
            orderCount: row._count,
            revenue: Number(row._sum.subtotal ?? 0),
          };
        })
        .sort((a, b) => b.revenue - a.revenue),
      revenuePerEmployee: employeeRows
        .map((row) => {
          const employee = employeeMap.get(row.receivedByEmployeeId);
          return {
            employeeId: row.receivedByEmployeeId,
            employeeName: employee?.fullName ?? 'Unknown',
            employeeCode: employee?.employeeCode ?? '-',
            transactionCount: row._count,
            revenue: Number(row._sum.amount ?? 0),
          };
        })
        .sort((a, b) => b.revenue - a.revenue),
      revenuePerCustomer: [...customerRevenue.entries()]
        .map(([customerId, item]) => ({
          customerId,
          customerName: item.name,
          customerCode: item.code,
          orderCount: item.orders,
          revenue: Number(item.revenue.toFixed(2)),
        }))
        .sort((a, b) => b.revenue - a.revenue)
        .slice(0, 25),
      payments: payments.length,
    };
  }

  async getCustomerAnalytics(query: ReportQueryDto) {
    const range = resolveReportRange(query.period, query.dateFrom, query.dateTo);

    const [newCustomers, allCustomers, orderGroups, membershipDistribution] =
      await Promise.all([
        this.prisma.customer.count({
          where: {
            deletedAt: null,
            createdAt: { gte: range.dateFrom, lte: range.dateTo },
          },
        }),
        this.prisma.customer.count({ where: { deletedAt: null, isActive: true } }),
        this.prisma.order.groupBy({
          by: ['customerId'],
          where: {
            deletedAt: null,
            orderDate: { gte: range.dateFrom, lte: range.dateTo },
            orderStatus: { not: OrderStatus.CANCELLED },
          },
          _count: true,
        }),
        this.getMembershipDistribution(),
      ]);

    const returning = orderGroups.filter((g) => g._count > 1).length;
    const oneTime = orderGroups.filter((g) => g._count === 1).length;

    const inactiveCutoff = new Date(range.dateTo);
    inactiveCutoff.setDate(inactiveCutoff.getDate() - 90);
    const inactiveCustomers = await this.prisma.customer.count({
      where: {
        deletedAt: null,
        isActive: true,
        orders: {
          none: {
            deletedAt: null,
            orderDate: { gte: inactiveCutoff },
          },
        },
      },
    });

    const customerRevenue = await this.prisma.payment.groupBy({
      by: ['orderId'],
      where: {
        deletedAt: null,
        paymentStatus: PaymentStatus.PAID,
        paidAt: { gte: range.dateFrom, lte: range.dateTo },
      },
      _sum: { amount: true },
    });

    const orderIds = customerRevenue.map((r) => r.orderId);
    const orders = orderIds.length
      ? await this.prisma.order.findMany({
          where: { id: { in: orderIds } },
          select: {
            id: true,
            customerId: true,
            customer: { select: { fullName: true, customerCode: true } },
          },
        })
      : [];
    const orderMap = new Map(orders.map((o) => [o.id, o]));

    const clvMap = new Map<string, { name: string; code: string; revenue: number; visits: number }>();
    for (const row of customerRevenue) {
      const order = orderMap.get(row.orderId);
      if (!order) continue;
      const existing = clvMap.get(order.customerId) ?? {
        name: order.customer.fullName,
        code: order.customer.customerCode,
        revenue: 0,
        visits: 0,
      };
      existing.revenue += Number(row._sum.amount ?? 0);
      existing.visits += 1;
      clvMap.set(order.customerId, existing);
    }

    const topCustomers = [...clvMap.entries()]
      .map(([customerId, item]) => ({
        customerId,
        customerName: item.name,
        customerCode: item.code,
        lifetimeValue: Number(item.revenue.toFixed(2)),
        visits: item.visits,
        averageSpending: item.visits > 0 ? Number((item.revenue / item.visits).toFixed(2)) : 0,
      }))
      .sort((a, b) => b.lifetimeValue - a.lifetimeValue)
      .slice(0, 20);

    const totalVisits = orderGroups.reduce((sum, g) => sum + g._count, 0);
    const totalSpending = topCustomers.reduce((sum, c) => sum + c.lifetimeValue, 0);

    return {
      period: range.preset,
      dateFrom: range.dateFrom.toISOString(),
      dateTo: range.dateTo.toISOString(),
      newCustomers,
      returningCustomers: returning,
      inactiveCustomers,
      activeCustomers: allCustomers,
      averageVisits:
        orderGroups.length > 0
          ? Number((totalVisits / orderGroups.length).toFixed(2))
          : 0,
      averageSpending:
        orderGroups.length > 0
          ? Number((totalSpending / orderGroups.length).toFixed(2))
          : 0,
      topCustomers,
      membershipDistribution,
      customerTrend: await this.buildCustomerTrend(range.dateFrom, range.dateTo),
    };
  }

  async getProductionAnalytics(query: ReportQueryDto) {
    const range = resolveReportRange(query.period, query.dateFrom, query.dateTo);

    const completedWhere = {
      deletedAt: null,
      orderStatus: OrderStatus.COMPLETED,
      completedDate: { gte: range.dateFrom, lte: range.dateTo },
      ...(query.employeeId ? { createdByEmployeeId: query.employeeId } : {}),
    };

    const [itemsAgg, delayedOrders, ironingJobs, completedOrders] = await Promise.all([
      this.prisma.orderItem.aggregate({
        where: {
          deletedAt: null,
          order: completedWhere,
        },
        _sum: { weight: true, quantity: true },
      }),
      this.prisma.order.count({
        where: {
          deletedAt: null,
          estimatedFinishDate: { lt: new Date() },
          orderStatus: { notIn: [OrderStatus.COMPLETED, OrderStatus.CANCELLED] },
        },
      }),
      this.prisma.ironingJob.findMany({
        where: {
          deletedAt: null,
          finishedAt: { gte: range.dateFrom, lte: range.dateTo },
          ...(query.employeeId ? { employeeId: query.employeeId } : {}),
        },
        select: {
          employeeId: true,
          actualMinutes: true,
          finishedAt: true,
          employee: { select: { fullName: true, employeeCode: true } },
        },
      }),
      this.prisma.order.findMany({
        where: completedWhere,
        select: { orderDate: true, completedDate: true },
      }),
    ]);

    const employeeProduction = new Map<string, { name: string; code: string; jobs: number; minutes: number }>();
    for (const job of ironingJobs) {
      if (!job.employeeId) continue;
      const existing = employeeProduction.get(job.employeeId) ?? {
        name: job.employee?.fullName ?? 'Unknown',
        code: job.employee?.employeeCode ?? '-',
        jobs: 0,
        minutes: 0,
      };
      existing.jobs += 1;
      existing.minutes += job.actualMinutes ?? 0;
      employeeProduction.set(job.employeeId, existing);
    }

    const completionMinutes = completedOrders
      .filter((o) => o.completedDate)
      .map((o) =>
        (o.completedDate!.getTime() - o.orderDate.getTime()) / 60000,
      );
    const avgCompletionMinutes =
      completionMinutes.length > 0
        ? Number(
            (
              completionMinutes.reduce((a, b) => a + b, 0) /
              completionMinutes.length
            ).toFixed(1),
          )
        : 0;

    const trendMap = new Map<string, number>();
    for (const job of ironingJobs) {
      if (!job.finishedAt) continue;
      const key = formatDayKey(job.finishedAt);
      trendMap.set(key, (trendMap.get(key) ?? 0) + 1);
    }

    return {
      period: range.preset,
      dateFrom: range.dateFrom.toISOString(),
      dateTo: range.dateTo.toISOString(),
      kgProcessed: Number(itemsAgg._sum.weight ?? 0),
      piecesProcessed: Number(itemsAgg._sum.quantity ?? 0),
      averageCompletionMinutes: avgCompletionMinutes,
      delayedOrders,
      productionPerEmployee: [...employeeProduction.entries()].map(
        ([employeeId, item]) => ({
          employeeId,
          employeeName: item.name,
          employeeCode: item.code,
          jobsCompleted: item.jobs,
          totalMinutes: item.minutes,
        }),
      ),
      productionTrend: eachDayInRange(range.dateFrom, range.dateTo).map((day) => ({
        label: formatDayLabel(day),
        date: formatDayKey(day),
        value: trendMap.get(formatDayKey(day)) ?? 0,
      })),
    };
  }

  async getEmployeePerformance(query: ReportQueryDto) {
    const range = resolveReportRange(query.period, query.dateFrom, query.dateTo);
    const employeeFilter = query.employeeId ? { employeeId: query.employeeId } : {};

    const [attendanceRows, payrollRows, ironingRows, paymentRows] = await Promise.all([
      this.prisma.attendance.groupBy({
        by: ['employeeId', 'status'],
        where: {
          deletedAt: null,
          attendanceDate: { gte: range.dateFrom, lte: range.dateTo },
          ...employeeFilter,
        },
        _count: true,
      }),
      this.prisma.payrollRecord.findMany({
        where: {
          deletedAt: null,
          periodStart: { lte: range.dateTo },
          periodEnd: { gte: range.dateFrom },
          ...employeeFilter,
        },
        select: {
          employeeId: true,
          netSalary: true,
          totalBonus: true,
          totalDeduction: true,
          laundryKg: true,
          ironingKg: true,
          ordersFinished: true,
          employee: { select: { fullName: true, employeeCode: true, position: true } },
        },
      }),
      this.prisma.ironingJob.groupBy({
        by: ['employeeId'],
        where: {
          deletedAt: null,
          finishedAt: { gte: range.dateFrom, lte: range.dateTo },
          employeeId: { not: null },
          ...employeeFilter,
        },
        _count: true,
        _sum: { actualMinutes: true },
      }),
      this.prisma.payment.groupBy({
        by: ['receivedByEmployeeId'],
        where: {
          deletedAt: null,
          paymentStatus: PaymentStatus.PAID,
          paidAt: { gte: range.dateFrom, lte: range.dateTo },
          ...(query.employeeId ? { receivedByEmployeeId: query.employeeId } : {}),
        },
        _sum: { amount: true },
        _count: true,
      }),
    ]);

    const employeeIds = new Set<string>();
    attendanceRows.forEach((r) => employeeIds.add(r.employeeId));
    payrollRows.forEach((r) => employeeIds.add(r.employeeId));
    ironingRows.forEach((r) => r.employeeId && employeeIds.add(r.employeeId));
    paymentRows.forEach((r) => employeeIds.add(r.receivedByEmployeeId));

    const employees = employeeIds.size
      ? await this.prisma.employee.findMany({
          where: { id: { in: [...employeeIds] } },
          select: { id: true, fullName: true, employeeCode: true, position: true },
        })
      : [];
    const employeeMap = new Map(employees.map((e) => [e.id, e]));

    const attendanceByEmployee = new Map<string, Record<string, number>>();
    for (const row of attendanceRows) {
      const map = attendanceByEmployee.get(row.employeeId) ?? {};
      map[row.status] = row._count;
      attendanceByEmployee.set(row.employeeId, map);
    }

    const payrollByEmployee = new Map<string, typeof payrollRows>();
    for (const row of payrollRows) {
      const list = payrollByEmployee.get(row.employeeId) ?? [];
      list.push(row);
      payrollByEmployee.set(row.employeeId, list);
    }

    const ironingByEmployee = new Map(ironingRows.map((r) => [r.employeeId!, r]));
    const paymentByEmployee = new Map(
      paymentRows.map((r) => [r.receivedByEmployeeId, r]),
    );

    const items = [...employeeIds].map((employeeId) => {
      const employee = employeeMap.get(employeeId);
      const attendance = attendanceByEmployee.get(employeeId) ?? {};
      const payrolls = payrollByEmployee.get(employeeId) ?? [];
      const ironing = ironingByEmployee.get(employeeId);
      const payments = paymentByEmployee.get(employeeId);

      const totalAttendance = Object.values(attendance).reduce((a, b) => a + b, 0);
      const payrollTotal = payrolls.reduce((s, p) => s + Number(p.netSalary), 0);
      const bonusTotal = payrolls.reduce((s, p) => s + Number(p.totalBonus), 0);
      const kgProcessed = payrolls.reduce((s, p) => s + Number(p.laundryKg) + Number(p.ironingKg), 0);

      return {
        employeeId,
        employeeName: employee?.fullName ?? 'Unknown',
        employeeCode: employee?.employeeCode ?? '-',
        position: employee?.position ?? '-',
        attendanceDays: totalAttendance,
        attendanceBreakdown: attendance,
        ordersCompleted: payrolls.reduce((s, p) => s + p.ordersFinished, 0) ||
          (ironing?._count ?? 0),
        kgProcessed,
        averageCompletionMinutes: ironing?._sum.actualMinutes
          ? Number(((ironing._sum.actualMinutes ?? 0) / (ironing._count || 1)).toFixed(1))
          : 0,
        bonusEarned: bonusTotal,
        payroll: payrollTotal,
        revenueHandled: Number(payments?._sum.amount ?? 0),
        productivity:
          totalAttendance > 0
            ? Number(((ironing?._count ?? 0) / totalAttendance).toFixed(2))
            : 0,
      };
    });

    return {
      period: range.preset,
      dateFrom: range.dateFrom.toISOString(),
      dateTo: range.dateTo.toISOString(),
      employees: items.sort((a, b) => b.revenueHandled - a.revenueHandled),
    };
  }

  async getFinanceAnalytics(query: ReportQueryDto) {
    const range = resolveReportRange(query.period, query.dateFrom, query.dateTo);

    const [revenue, expense, payroll, refunds, cashflowRows] = await Promise.all([
      this.sumIncome(range.dateFrom, range.dateTo),
      this.sumExpense(range.dateFrom, range.dateTo),
      this.prisma.payrollRecord.aggregate({
        where: {
          deletedAt: null,
          status: PayrollRecordStatus.PAID,
          periodStart: { lte: range.dateTo },
          periodEnd: { gte: range.dateFrom },
        },
        _sum: { netSalary: true },
      }),
      this.prisma.cashflow.aggregate({
        where: {
          type: CashflowType.EXPENSE,
          referenceType: ReferenceType.REFUND,
          transactionDate: { gte: range.dateFrom, lte: range.dateTo },
        },
        _sum: { amount: true },
      }),
      this.prisma.cashflow.findMany({
        where: {
          transactionDate: { gte: range.dateFrom, lte: range.dateTo },
        },
        select: { type: true, amount: true, transactionDate: true },
        orderBy: { transactionDate: 'asc' },
      }),
    ]);

    const revenueValue = Number(revenue._sum.amount ?? 0);
    const expenseValue = Number(expense._sum.amount ?? 0);
    const payrollValue = Number(payroll._sum.netSalary ?? 0);
    const refundValue = Number(refunds._sum.amount ?? 0);
    const grossProfit = revenueValue - expenseValue;
    const netProfit = grossProfit - payrollValue - refundValue;
    const operatingMargin =
      revenueValue > 0 ? Number(((netProfit / revenueValue) * 100).toFixed(2)) : 0;

    let running = 0;
    const cashFlowTrend = cashflowRows.map((row) => {
      const amount = Number(row.amount);
      running += row.type === CashflowType.INCOME ? amount : -amount;
      return {
        label: formatDayLabel(row.transactionDate),
        date: formatDayKey(row.transactionDate),
        value: Number(running.toFixed(2)),
      };
    });

    const incomeByDay = new Map<string, { income: number; expense: number }>();
    for (const row of cashflowRows) {
      const key = formatDayKey(row.transactionDate);
      const bucket = incomeByDay.get(key) ?? { income: 0, expense: 0 };
      const amount = Number(row.amount);
      if (row.type === CashflowType.INCOME) bucket.income += amount;
      else bucket.expense += amount;
      incomeByDay.set(key, bucket);
    }

    return {
      period: range.preset,
      dateFrom: range.dateFrom.toISOString(),
      dateTo: range.dateTo.toISOString(),
      revenue: revenueValue,
      expense: expenseValue,
      payroll: payrollValue,
      refunds: refundValue,
      grossProfit: Number(grossProfit.toFixed(2)),
      netProfit: Number(netProfit.toFixed(2)),
      cashFlow: Number(
        cashflowRows
          .reduce(
            (sum, row) =>
              sum +
              (row.type === CashflowType.INCOME
                ? Number(row.amount)
                : -Number(row.amount)),
            0,
          )
          .toFixed(2),
      ),
      operatingMargin,
      trend: eachDayInRange(range.dateFrom, range.dateTo).map((day) => {
        const key = formatDayKey(day);
        const bucket = incomeByDay.get(key) ?? { income: 0, expense: 0 };
        return {
          label: formatDayLabel(day),
          date: key,
          revenue: bucket.income,
          expenses: bucket.expense,
          netProfit: Number((bucket.income - bucket.expense).toFixed(2)),
        };
      }),
      cashFlowTrend,
    };
  }

  async getPayrollAnalytics(query: ReportQueryDto) {
    const range = resolveReportRange(query.period, query.dateFrom, query.dateTo);

    const records = await this.prisma.payrollRecord.findMany({
      where: {
        deletedAt: null,
        periodStart: { lte: range.dateTo },
        periodEnd: { gte: range.dateFrom },
        ...(query.employeeId ? { employeeId: query.employeeId } : {}),
      },
      include: {
        employee: { select: { fullName: true, employeeCode: true, position: true } },
      },
      orderBy: { periodStart: 'desc' },
    });

    const byEmployee = new Map<string, { name: string; code: string; net: number; bonus: number; deduction: number; count: number }>();
    const byRole = new Map<string, { net: number; bonus: number; deduction: number; count: number }>();

    for (const record of records) {
      const empKey = record.employeeId;
      const emp = byEmployee.get(empKey) ?? {
        name: record.employee.fullName,
        code: record.employee.employeeCode,
        net: 0,
        bonus: 0,
        deduction: 0,
        count: 0,
      };
      emp.net += Number(record.netSalary);
      emp.bonus += Number(record.totalBonus);
      emp.deduction += Number(record.totalDeduction);
      emp.count += 1;
      byEmployee.set(empKey, emp);

      const role = record.employee.position ?? 'Unknown';
      const roleBucket = byRole.get(role) ?? { net: 0, bonus: 0, deduction: 0, count: 0 };
      roleBucket.net += Number(record.netSalary);
      roleBucket.bonus += Number(record.totalBonus);
      roleBucket.deduction += Number(record.totalDeduction);
      roleBucket.count += 1;
      byRole.set(role, roleBucket);
    }

    const totalNet = records.reduce((s, r) => s + Number(r.netSalary), 0);
    const totalBonus = records.reduce((s, r) => s + Number(r.totalBonus), 0);
    const totalDeduction = records.reduce((s, r) => s + Number(r.totalDeduction), 0);

    return {
      period: range.preset,
      dateFrom: range.dateFrom.toISOString(),
      dateTo: range.dateTo.toISOString(),
      summary: {
        totalPayroll: Number(totalNet.toFixed(2)),
        totalBonus: Number(totalBonus.toFixed(2)),
        totalDeduction: Number(totalDeduction.toFixed(2)),
        averagePayroll:
          records.length > 0 ? Number((totalNet / records.length).toFixed(2)) : 0,
        recordCount: records.length,
      },
      history: records.slice(0, 50).map((r) => ({
        id: r.id,
        employeeName: r.employee.fullName,
        periodStart: r.periodStart.toISOString(),
        periodEnd: r.periodEnd.toISOString(),
        netSalary: Number(r.netSalary),
        totalBonus: Number(r.totalBonus),
        totalDeduction: Number(r.totalDeduction),
        status: r.status,
      })),
      byEmployee: [...byEmployee.entries()].map(([employeeId, item]) => ({
        employeeId,
        employeeName: item.name,
        employeeCode: item.code,
        netSalary: Number(item.net.toFixed(2)),
        bonus: Number(item.bonus.toFixed(2)),
        deduction: Number(item.deduction.toFixed(2)),
        periods: item.count,
      })),
      byRole: [...byRole.entries()].map(([role, item]) => ({
        role,
        netSalary: Number(item.net.toFixed(2)),
        bonus: Number(item.bonus.toFixed(2)),
        deduction: Number(item.deduction.toFixed(2)),
        periods: item.count,
      })),
    };
  }

  async getWalletAnalytics(query: ReportQueryDto) {
    const range = resolveReportRange(query.period, query.dateFrom, query.dateTo);
    const txWhere = {
      deletedAt: null,
      createdAt: { gte: range.dateFrom, lte: range.dateTo },
      ...(query.customerId ? { customerId: query.customerId } : {}),
    };

    const [typeGroups, balance, trendRows] = await Promise.all([
      this.prisma.walletTransaction.groupBy({
        by: ['type'],
        where: txWhere,
        _sum: { amount: true },
        _count: true,
      }),
      this.prisma.customerWallet.aggregate({
        where: { deletedAt: null, isActive: true },
        _sum: { currentBalance: true },
        _count: true,
      }),
      this.prisma.walletTransaction.findMany({
        where: txWhere,
        select: { type: true, amount: true, createdAt: true },
      }),
    ]);

    const byType = (type: WalletTransactionType) => {
      const row = typeGroups.find((g) => g.type === type);
      return Number(row?._sum.amount ?? 0);
    };

    const trendMap = new Map<string, number>();
    for (const row of trendRows) {
      const key = formatDayKey(row.createdAt);
      trendMap.set(key, (trendMap.get(key) ?? 0) + Number(row.amount));
    }

    return {
      period: range.preset,
      dateFrom: range.dateFrom.toISOString(),
      dateTo: range.dateTo.toISOString(),
      topUp: byType(WalletTransactionType.top_up),
      walletPayment: byType(WalletTransactionType.deduction),
      refund: byType(WalletTransactionType.refund),
      adjustment:
        byType(WalletTransactionType.adjustment) +
        byType(WalletTransactionType.manual_credit) +
        byType(WalletTransactionType.manual_debit),
      promotion: byType(WalletTransactionType.promotion),
      currentBalance: Number(balance._sum.currentBalance ?? 0),
      activeWallets: balance._count,
      breakdown: typeGroups.map((row) => ({
        type: row.type,
        amount: Number(row._sum.amount ?? 0),
        count: row._count,
      })),
      trend: eachDayInRange(range.dateFrom, range.dateTo).map((day) => ({
        label: formatDayLabel(day),
        date: formatDayKey(day),
        value: Number((trendMap.get(formatDayKey(day)) ?? 0).toFixed(2)),
      })),
    };
  }

  async getMembershipAnalytics(query: ReportQueryDto) {
    const range = resolveReportRange(query.period, query.dateFrom, query.dateTo);
    const distribution = await this.getMembershipDistribution();
    const settings = await this.loyaltySettings.getSettings();

    const earnRows = await this.prisma.rewardPoint.findMany({
      where: {
        deletedAt: null,
        type: RewardPointType.earn,
        createdAt: { gte: range.dateFrom, lte: range.dateTo },
      },
      select: { customerId: true, point: true, createdAt: true },
    });

    const growthMap = new Map<string, number>();
    for (const row of earnRows) {
      const key = formatDayKey(row.createdAt);
      growthMap.set(key, (growthMap.get(key) ?? 0) + row.point);
    }

    const upgradeHistory = await this.buildUpgradeHistory(settings.membershipLevels);

    return {
      period: range.preset,
      dateFrom: range.dateFrom.toISOString(),
      dateTo: range.dateTo.toISOString(),
      distribution,
      growth: eachDayInRange(range.dateFrom, range.dateTo).map((day) => ({
        label: formatDayLabel(day),
        date: formatDayKey(day),
        value: growthMap.get(formatDayKey(day)) ?? 0,
      })),
      upgradeHistory,
      totalMembers: distribution.reduce((s, d) => s + d.value, 0),
      pointsIssuedInPeriod: earnRows.reduce((s, r) => s + r.point, 0),
    };
  }

  async getForecast(query: ReportQueryDto) {
    const range = resolveReportRange(
      query.period ?? undefined,
      query.dateFrom,
      query.dateTo,
    );
    const historyStart = new Date(range.dateTo);
    historyStart.setDate(historyStart.getDate() - 89);

    const [revenueRows, orderCount, payrollRows, productionRows] = await Promise.all([
      this.prisma.cashflow.findMany({
        where: {
          type: CashflowType.INCOME,
          referenceType: ReferenceType.ORDER_PAYMENT,
          transactionDate: { gte: historyStart, lte: range.dateTo },
        },
        select: { amount: true, transactionDate: true },
      }),
      this.prisma.order.count({
        where: {
          deletedAt: null,
          orderDate: { gte: historyStart, lte: range.dateTo },
          orderStatus: { not: OrderStatus.CANCELLED },
        },
      }),
      this.prisma.payrollRecord.aggregate({
        where: {
          deletedAt: null,
          periodEnd: { gte: historyStart, lte: range.dateTo },
        },
        _avg: { netSalary: true },
        _count: true,
      }),
      this.prisma.orderItem.aggregate({
        where: {
          deletedAt: null,
          order: {
            deletedAt: null,
            completedDate: { gte: historyStart, lte: range.dateTo },
            orderStatus: OrderStatus.COMPLETED,
          },
        },
        _sum: { weight: true },
      }),
    ]);

    const days = Math.max(
      1,
      Math.ceil(
        (range.dateTo.getTime() - historyStart.getTime()) / (1000 * 60 * 60 * 24),
      ),
    );

    const totalRevenue = revenueRows.reduce((s, r) => s + Number(r.amount), 0);
    const avgDailyRevenue = totalRevenue / days;
    const avgDailyOrders = orderCount / days;
    const avgPayroll = Number(payrollRows._avg.netSalary ?? 0);
    const avgDailyKg = Number(productionRows._sum.weight ?? 0) / days;

    const forecastDays = [7, 30];
    const project = (dailyAvg: number, horizon: number) =>
      Number((dailyAvg * horizon).toFixed(2));

    return {
      basedOnDays: days,
      historical: {
        revenue: Number(totalRevenue.toFixed(2)),
        orders: orderCount,
        avgDailyRevenue: Number(avgDailyRevenue.toFixed(2)),
        avgDailyOrders: Number(avgDailyOrders.toFixed(2)),
        avgPayrollPerPeriod: Number(avgPayroll.toFixed(2)),
        avgDailyKg: Number(avgDailyKg.toFixed(2)),
      },
      forecast: {
        revenue: {
          next7Days: project(avgDailyRevenue, 7),
          next30Days: project(avgDailyRevenue, 30),
        },
        orders: {
          next7Days: Math.round(avgDailyOrders * 7),
          next30Days: Math.round(avgDailyOrders * 30),
        },
        payroll: {
          nextPeriod: Number(avgPayroll.toFixed(2)),
        },
        production: {
          next7DaysKg: project(avgDailyKg, 7),
          next30DaysKg: project(avgDailyKg, 30),
        },
      },
      method: 'moving_average',
      disclaimer:
        'Forecasts use simple historical daily averages and are estimates only.',
    };
  }

  getSchedulerArchitecture() {
    return {
      supportedFrequencies: ['DAILY', 'WEEKLY', 'MONTHLY'],
      channels: ['EMAIL'],
      recipients: ['OWNER'],
      status: 'architecture_only',
      jobs: [
        {
          code: 'daily_executive_summary',
          frequency: 'DAILY',
          report: 'executive_dashboard',
          enabled: false,
        },
        {
          code: 'weekly_sales_report',
          frequency: 'WEEKLY',
          report: 'sales',
          enabled: false,
        },
        {
          code: 'monthly_finance_pack',
          frequency: 'MONTHLY',
          report: 'finance',
          enabled: false,
        },
      ],
      note: 'Scheduler execution will be implemented in a future sprint.',
    };
  }

  private async getMembershipDistribution(): Promise<NamedValue[]> {
    const settings = await this.loyaltySettings.getSettings();
    const levels = [...settings.membershipLevels].sort(
      (a, b) => a.minPoints - b.minPoints,
    );

    const earnGroups = await this.prisma.rewardPoint.groupBy({
      by: ['customerId'],
      where: { deletedAt: null, type: RewardPointType.earn },
      _sum: { point: true },
    });

    const buckets = new Map<string, number>(
      levels.map((level) => [level.code, 0]),
    );

    const customersWithOrders = await this.prisma.customer.count({
      where: { deletedAt: null },
    });
    const customersWithPoints = new Set(earnGroups.map((g) => g.customerId));

    for (const group of earnGroups) {
      const lifetime = group._sum.point ?? 0;
      const level = this.resolveMembershipLevel(lifetime, levels);
      buckets.set(level.code, (buckets.get(level.code) ?? 0) + 1);
    }

    const regularOnly =
      customersWithOrders - customersWithPoints.size;
    if (regularOnly > 0) {
      buckets.set('REGULAR', (buckets.get('REGULAR') ?? 0) + regularOnly);
    }

    return levels.map((level) => ({
      name: level.name,
      value: buckets.get(level.code) ?? 0,
    }));
  }

  private resolveMembershipLevel(
    lifetimePoints: number,
    levels: MembershipLevel[],
  ): MembershipLevel {
    const sorted = [...levels].sort((a, b) => b.minPoints - a.minPoints);
    return sorted.find((l) => lifetimePoints >= l.minPoints) ?? levels[0];
  }

  private async buildUpgradeHistory(levels: MembershipLevel[]) {
    const earnEvents = await this.prisma.rewardPoint.findMany({
      where: { deletedAt: null, type: RewardPointType.earn },
      select: { customerId: true, point: true, createdAt: true },
      orderBy: { createdAt: 'asc' },
    });

    const byCustomer = new Map<string, Array<{ point: number; createdAt: Date }>>();
    for (const event of earnEvents) {
      const list = byCustomer.get(event.customerId) ?? [];
      list.push({ point: event.point, createdAt: event.createdAt });
      byCustomer.set(event.customerId, list);
    }

    const upgrades: Array<{
      customerId: string;
      level: string;
      upgradedAt: string;
      lifetimePoints: number;
    }> = [];

    for (const [customerId, events] of byCustomer.entries()) {
      let lifetime = 0;
      let currentLevel = levels[0];
      for (const event of events) {
        lifetime += event.point;
        const next = this.resolveMembershipLevel(lifetime, levels);
        if (next.code !== currentLevel.code && next.minPoints > currentLevel.minPoints) {
          upgrades.push({
            customerId,
            level: next.name,
            upgradedAt: event.createdAt.toISOString(),
            lifetimePoints: lifetime,
          });
          currentLevel = next;
        }
      }
    }

    return upgrades
      .sort((a, b) => b.upgradedAt.localeCompare(a.upgradedAt))
      .slice(0, 50);
  }

  private async buildCustomerTrend(dateFrom: Date, dateTo: Date) {
    const customers = await this.prisma.customer.findMany({
      where: {
        deletedAt: null,
        createdAt: { gte: dateFrom, lte: dateTo },
      },
      select: { createdAt: true },
    });

    const map = new Map<string, number>();
    for (const customer of customers) {
      const key = formatDayKey(customer.createdAt);
      map.set(key, (map.get(key) ?? 0) + 1);
    }

    return eachDayInRange(dateFrom, dateTo).map((day) => ({
      label: formatDayLabel(day),
      date: formatDayKey(day),
      value: map.get(formatDayKey(day)) ?? 0,
    }));
  }

  private async countReturningCustomers(dateFrom: Date, dateTo: Date) {
    const groups = await this.prisma.order.groupBy({
      by: ['customerId'],
      where: {
        deletedAt: null,
        orderDate: { gte: dateFrom, lte: dateTo },
        orderStatus: { not: OrderStatus.CANCELLED },
      },
      _count: true,
    });
    return groups.filter((g) => g._count > 1).length;
  }

  private async sumLaundryKg(dateFrom: Date, dateTo: Date) {
    const result = await this.prisma.orderItem.aggregate({
      where: {
        deletedAt: null,
        order: {
          deletedAt: null,
          orderStatus: OrderStatus.COMPLETED,
          completedDate: { gte: dateFrom, lte: dateTo },
        },
      },
      _sum: { weight: true },
    });
    return Number(result._sum.weight ?? 0);
  }

  private sumIncome(dateFrom: Date, dateTo: Date) {
    return this.prisma.cashflow.aggregate({
      where: {
        type: CashflowType.INCOME,
        referenceType: ReferenceType.ORDER_PAYMENT,
        transactionDate: { gte: dateFrom, lte: dateTo },
      },
      _sum: { amount: true },
    });
  }

  private sumExpense(dateFrom: Date, dateTo: Date) {
    return this.prisma.cashflow.aggregate({
      where: {
        type: CashflowType.EXPENSE,
        referenceType: ReferenceType.EXPENSE,
        transactionDate: { gte: dateFrom, lte: dateTo },
      },
      _sum: { amount: true },
    });
  }

  private startOfDay(date: Date) {
    return new Date(date.getFullYear(), date.getMonth(), date.getDate());
  }

  private endOfDay(date: Date) {
    const end = this.startOfDay(date);
    end.setHours(23, 59, 59, 999);
    return end;
  }

  private bucketByWeek(points: TrendPoint[]): TrendPoint[] {
    const map = new Map<string, number>();
    for (const point of points) {
      const date = new Date(point.date);
      const weekStart = new Date(date);
      weekStart.setDate(weekStart.getDate() - weekStart.getDay());
      const key = formatDayKey(weekStart);
      map.set(key, (map.get(key) ?? 0) + point.value);
    }
    return [...map.entries()].map(([date, value]) => ({
      label: `W/C ${formatDayLabel(new Date(date))}`,
      date,
      value: Number(value.toFixed(2)),
    }));
  }
}
