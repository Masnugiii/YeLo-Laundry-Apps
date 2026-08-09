import { Injectable } from '@nestjs/common';
import { OrderStatus } from '@prisma/client';
import { parsePayrollLatestTotal } from '../common/utils/payroll-latest-total.util';
import { PrismaService } from '../database/prisma/prisma.service';

export interface DashboardSummary {
  revenueToday: number;
  revenueThisMonth: number;
  netProfit: number;
  expenses: number;
  payroll: number;
  customers: number;
  employees: number;
  orders: number;
  laundryInProgress: number;
  readyPickup: number;
  deliveryToday: number;
  attendanceToday: number;
}

@Injectable()
export class DashboardService {
  constructor(private readonly prisma: PrismaService) {}

  async getSummary(): Promise<DashboardSummary> {
    const now = new Date();
    const startOfToday = new Date(
      now.getFullYear(),
      now.getMonth(),
      now.getDate(),
    );
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
    const endOfToday = new Date(startOfToday);
    endOfToday.setDate(endOfToday.getDate() + 1);

    const activeProductionStatuses: OrderStatus[] = [
      OrderStatus.WAITING_BINATU,
      OrderStatus.IRONING_ACCEPTED,
      OrderStatus.CURRENTLY_IRONING,
      OrderStatus.FINISHED_IRONING,
    ];

    const [
      revenueToday,
      revenueThisMonth,
      expenseAmount,
      payrollAmount,
      customers,
      employees,
      orders,
      laundryInProgress,
      readyPickup,
      deliveryToday,
      attendanceToday,
    ] = await this.prisma.$transaction([
      this.prisma.cashflow.aggregate({
        where: {
          type: 'INCOME',
          transactionDate: { gte: startOfToday, lt: endOfToday },
        },
        _sum: { amount: true },
      }),
      this.prisma.cashflow.aggregate({
        where: {
          type: 'INCOME',
          transactionDate: { gte: startOfMonth },
        },
        _sum: { amount: true },
      }),
      this.prisma.cashflow.aggregate({
        where: {
          type: 'EXPENSE',
          transactionDate: { gte: startOfMonth },
        },
        _sum: { amount: true },
      }),
      this.prisma.systemSetting.findUnique({
        where: { settingKey: 'payroll.latest_total' },
      }),
      this.prisma.customer.count({
        where: { deletedAt: null, isActive: true },
      }),
      this.prisma.employee.count({
        where: { deletedAt: null, status: 'active' },
      }),
      this.prisma.order.count({ where: { deletedAt: null } }),
      this.prisma.order.count({
        where: {
          deletedAt: null,
          orderStatus: { in: activeProductionStatuses },
        },
      }),
      this.prisma.order.count({
        where: {
          deletedAt: null,
          orderStatus: OrderStatus.READY_FOR_PICKUP,
        },
      }),
      this.prisma.deliveryJob.count({
        where: {
          deletedAt: null,
          scheduledDeliveryAt: { gte: startOfToday, lt: endOfToday },
        },
      }),
      this.prisma.attendance.count({
        where: {
          deletedAt: null,
          attendanceDate: { gte: startOfToday, lt: endOfToday },
        },
      }),
    ]);

    const revenueTodayValue = Number(revenueToday._sum.amount ?? 0);
    const revenueMonthValue = Number(revenueThisMonth._sum.amount ?? 0);
    const expensesValue = Number(expenseAmount._sum.amount ?? 0);
    const payrollValue = parsePayrollLatestTotal(payrollAmount?.settingValue);

    return {
      revenueToday: revenueTodayValue,
      revenueThisMonth: revenueMonthValue,
      netProfit: revenueMonthValue - expensesValue - payrollValue,
      expenses: expensesValue,
      payroll: payrollValue,
      customers,
      employees,
      orders,
      laundryInProgress,
      readyPickup,
      deliveryToday,
      attendanceToday,
    };
  }
}
