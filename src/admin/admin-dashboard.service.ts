import { Injectable } from '@nestjs/common';
import { DashboardService } from '../dashboard/dashboard.service';
import { PrismaService } from '../database/prisma/prisma.service';

export interface AdminDashboard {
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
  unreadNotifications: number;
  serverStatus: 'healthy' | 'degraded' | 'down';
}

@Injectable()
export class AdminDashboardService {
  constructor(
    private readonly dashboardService: DashboardService,
    private readonly prisma: PrismaService,
  ) {}

  async getDashboard(): Promise<AdminDashboard> {
    const [summary, unreadNotifications] = await Promise.all([
      this.dashboardService.getSummary(),
      this.prisma.notification.count({
        where: { deletedAt: null },
      }),
    ]);

    return {
      ...summary,
      unreadNotifications,
      serverStatus: 'healthy',
    };
  }
}
