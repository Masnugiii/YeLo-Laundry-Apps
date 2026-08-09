export interface ApiEnvelope<T> {
  success: boolean;
  message: string;
  data: T;
}

export interface PaginationMeta {
  page: number;
  limit: number;
  total: number;
  totalPages: number;
}

export interface Paginated<T> {
  items: T[];
  meta: PaginationMeta;
}

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

export interface AuthUser {
  id: string;
  employeeCode: string;
  fullName: string;
  phone: string;
  roles: string[];
}

export interface LoginResponse {
  accessToken: string;
  user: AuthUser;
}
