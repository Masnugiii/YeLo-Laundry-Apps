export type ReportPeriodPreset =
  | "today"
  | "yesterday"
  | "last_7_days"
  | "last_30_days"
  | "this_month"
  | "last_month"
  | "custom";

export interface ReportQueryParams {
  period?: ReportPeriodPreset;
  dateFrom?: string;
  dateTo?: string;
  employeeId?: string;
  customerId?: string;
}

export interface TrendPoint {
  label: string;
  date: string;
  value: number;
}

export interface NamedValue {
  name: string;
  value: number;
}

export interface ExecutiveDashboard {
  period: string;
  dateFrom: string;
  dateTo: string;
  revenueToday: number;
  revenueWeek: number;
  revenueMonth: number;
  netProfit: number;
  totalOrders: number;
  completedOrders: number;
  pendingOrders: number;
  cancelledOrders: number;
  averageOrderValue: number;
  laundryKgToday: number;
  laundryKgMonth: number;
  pickupToday: number;
  deliveryToday: number;
  attendanceToday: number;
  payrollThisPeriod: number;
  walletBalance: number;
  rewardPointsIssued: number;
  newCustomers: number;
  returningCustomers: number;
}

export interface SalesReport {
  period: string;
  dateFrom: string;
  dateTo: string;
  summary: {
    totalRevenue: number;
    averageTransaction: number;
    largestTransaction: number;
    transactionCount: number;
  };
  revenuePerDay: TrendPoint[];
  revenuePerWeek: TrendPoint[];
  revenuePerMonth: TrendPoint[];
  revenuePerService: Array<{
    serviceId: string;
    serviceName: string;
    serviceCode: string;
    orderCount: number;
    revenue: number;
  }>;
  revenuePerEmployee: Array<{
    employeeId: string;
    employeeName: string;
    employeeCode: string;
    transactionCount: number;
    revenue: number;
  }>;
  revenuePerCustomer: Array<{
    customerId: string;
    customerName: string;
    customerCode: string;
    orderCount: number;
    revenue: number;
  }>;
}

export interface CustomerAnalytics {
  period: string;
  dateFrom: string;
  dateTo: string;
  newCustomers: number;
  returningCustomers: number;
  inactiveCustomers: number;
  activeCustomers: number;
  averageVisits: number;
  averageSpending: number;
  topCustomers: Array<{
    customerId: string;
    customerName: string;
    customerCode: string;
    lifetimeValue: number;
    visits: number;
    averageSpending: number;
  }>;
  membershipDistribution: NamedValue[];
  customerTrend: TrendPoint[];
}

export interface ProductionAnalytics {
  period: string;
  dateFrom: string;
  dateTo: string;
  kgProcessed: number;
  piecesProcessed: number;
  averageCompletionMinutes: number;
  delayedOrders: number;
  productionPerEmployee: Array<{
    employeeId: string;
    employeeName: string;
    employeeCode: string;
    jobsCompleted: number;
    totalMinutes: number;
  }>;
  productionTrend: TrendPoint[];
}

export interface EmployeePerformanceReport {
  period: string;
  dateFrom: string;
  dateTo: string;
  employees: Array<{
    employeeId: string;
    employeeName: string;
    employeeCode: string;
    position: string;
    attendanceDays: number;
    ordersCompleted: number;
    kgProcessed: number;
    averageCompletionMinutes: number;
    bonusEarned: number;
    payroll: number;
    revenueHandled: number;
    productivity: number;
  }>;
}

export interface FinanceAnalytics {
  period: string;
  dateFrom: string;
  dateTo: string;
  revenue: number;
  expense: number;
  payroll: number;
  refunds: number;
  grossProfit: number;
  netProfit: number;
  cashFlow: number;
  operatingMargin: number;
  trend: Array<{
    label: string;
    date: string;
    revenue: number;
    expenses: number;
    netProfit: number;
  }>;
  cashFlowTrend: TrendPoint[];
}

export interface PayrollAnalytics {
  period: string;
  dateFrom: string;
  dateTo: string;
  summary: {
    totalPayroll: number;
    totalBonus: number;
    totalDeduction: number;
    averagePayroll: number;
    recordCount: number;
  };
  history: Array<{
    id: string;
    employeeName: string;
    periodStart: string;
    periodEnd: string;
    netSalary: number;
    totalBonus: number;
    totalDeduction: number;
    status: string;
  }>;
  byEmployee: Array<{
    employeeId: string;
    employeeName: string;
    employeeCode: string;
    netSalary: number;
    bonus: number;
    deduction: number;
    periods: number;
  }>;
  byRole: Array<{
    role: string;
    netSalary: number;
    bonus: number;
    deduction: number;
    periods: number;
  }>;
}

export interface WalletAnalytics {
  period: string;
  dateFrom: string;
  dateTo: string;
  topUp: number;
  walletPayment: number;
  refund: number;
  adjustment: number;
  promotion: number;
  currentBalance: number;
  activeWallets: number;
  breakdown: Array<{ type: string; amount: number; count: number }>;
  trend: TrendPoint[];
}

export interface MembershipAnalytics {
  period: string;
  dateFrom: string;
  dateTo: string;
  distribution: NamedValue[];
  growth: TrendPoint[];
  upgradeHistory: Array<{
    customerId: string;
    level: string;
    upgradedAt: string;
    lifetimePoints: number;
  }>;
  totalMembers: number;
  pointsIssuedInPeriod: number;
}

export interface ForecastReport {
  basedOnDays: number;
  historical: {
    revenue: number;
    orders: number;
    avgDailyRevenue: number;
    avgDailyOrders: number;
    avgPayrollPerPeriod: number;
    avgDailyKg: number;
  };
  forecast: {
    revenue: { next7Days: number; next30Days: number };
    orders: { next7Days: number; next30Days: number };
    payroll: { nextPeriod: number };
    production: { next7DaysKg: number; next30DaysKg: number };
  };
  method: string;
  disclaimer: string;
}

export interface ReportSchedulerArchitecture {
  supportedFrequencies: string[];
  channels: string[];
  recipients: string[];
  status: string;
  jobs: Array<{
    code: string;
    frequency: string;
    report: string;
    enabled: boolean;
  }>;
  note: string;
}
