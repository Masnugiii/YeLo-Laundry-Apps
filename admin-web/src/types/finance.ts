export type FinancePeriod = "daily" | "weekly" | "monthly" | "yearly";

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

export interface RevenueListParams {
  page?: number;
  limit?: number;
  search?: string;
  customerId?: string;
  employeeId?: string;
  paymentMethod?: string;
  paymentStatus?: string;
  dateFrom?: string;
  dateTo?: string;
}

export interface ExpenseCategory {
  id: string;
  code: string;
  name: string;
}

export interface Expense {
  id: string;
  referenceNumber: string | null;
  title: string;
  description: string | null;
  amount: number;
  expenseDate: string;
  receiptPhotoUrl: string | null;
  approvalStatus: "PENDING" | "APPROVED" | "REJECTED" | null;
  approvedByEmployeeId: string | null;
  approvedAt: string | null;
  category: ExpenseCategory;
  createdBy: {
    id: string;
    fullName: string;
    employeeCode: string;
  };
  createdAt: string;
  updatedAt: string;
}

export interface ExpenseListParams {
  page?: number;
  limit?: number;
  search?: string;
  categoryCode?: string;
  dateFrom?: string;
  dateTo?: string;
}

export interface CreateExpenseInput {
  categoryCode: string;
  title: string;
  description?: string;
  amount: number;
  expenseDate: string;
  receiptPhotoUrl?: string;
}

export interface UpdateExpenseInput {
  categoryCode?: string;
  title?: string;
  description?: string;
  amount?: number;
  expenseDate?: string;
  receiptPhotoUrl?: string;
  approvalAction?: "APPROVED" | "REJECTED";
  rejectionReason?: string;
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
  type: "INCOME" | "EXPENSE";
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

export interface FinanceReportParams {
  period?: FinancePeriod;
  dateFrom?: string;
  dateTo?: string;
}

export interface RevenueSummary {
  total: number;
  paymentCount: number;
}

export interface ExpenseCategorySummary {
  categoryCode: string;
  categoryName: string;
  amount: number;
  count: number;
}

export interface ExpenseSummary {
  total: number;
  expenseCount: number;
  byCategory: ExpenseCategorySummary[];
}

export interface WalletSummary {
  topUp: number;
  walletPayment: number;
  refund: number;
  currentBalance: number;
  activeWallets: number;
}

export interface FinancialSummary {
  period: FinancePeriod;
  dateFrom: string;
  dateTo: string;
  revenue: RevenueSummary;
  expense: ExpenseSummary;
  payment: PaymentHistorySummary;
  wallet: WalletSummary;
  profitLoss: ProfitLossSummary;
  trend: FinanceTrendPoint[];
}

export interface Payment {
  id: string;
  referenceNumber: string | null;
  orderId: string;
  orderNumber: string;
  queueNumber: string;
  customer: {
    id: string;
    customerCode: string;
    fullName: string;
    phone: string;
  };
  paymentMethod: {
    id: string;
    code: string;
    name: string;
    apiCode: string | null;
  };
  amount: number;
  refundedAmount: number;
  netAmount: number;
  paymentStatus: string;
  displayStatus: string;
  paidAt: string;
  notes: string | null;
  receivedBy: {
    id: string;
    fullName: string;
    employeeCode: string;
  };
  createdAt: string;
  updatedAt: string;
}

export interface PaymentListParams {
  page?: number;
  limit?: number;
  search?: string;
  customerId?: string;
  orderId?: string;
  paymentMethod?: string;
  paymentStatus?: string;
  dateFrom?: string;
  dateTo?: string;
}
