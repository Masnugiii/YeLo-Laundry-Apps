export type CustomerMemberStatus = "MEMBER" | "REGULAR";

export interface Customer {
  id: string;
  customerCode: string;
  fullName: string;
  phone: string;
  email: string | null;
  gender: string | null;
  birthDate: string | null;
  photoUrl: string | null;
  isActive: boolean;
  loyaltyPoints: number;
  walletBalance: number;
  memberStatus: CustomerMemberStatus;
  totalOrders: number;
  totalSpending: number;
  lastOrderAt: string | null;
  createdAt: string;
  updatedAt: string;
  deletedAt: string | null;
  wallet: {
    balance: number;
    currency: string;
    isActive: boolean;
  } | null;
  defaultAddress: CustomerAddress | null;
  addresses: CustomerAddress[];
}

export interface CustomerAddress {
  id: string;
  recipientName: string;
  phone: string;
  province: string;
  city: string;
  district: string;
  postalCode: string | null;
  addressDetail: string;
  isDefault: boolean;
}

export interface CustomerBusinessSummary {
  totalOrders: number;
  completedOrders: number;
  cancelledOrders: number;
  totalSpending: number;
  averageOrderValue: number;
  memberSince: string;
  lastOrderAt: string | null;
}

export interface CustomerNote {
  id: string;
  customerId: string;
  title: string | null;
  note: string;
  category: string;
  isPinned: boolean;
  createdBy: {
    id: string;
    fullName: string;
    employeeCode: string;
  };
  createdAt: string;
  updatedAt: string;
}

export interface CustomerListParams {
  page?: number;
  limit?: number;
  search?: string;
  isActive?: boolean;
  isMember?: boolean;
  dateFrom?: string;
  dateTo?: string;
  sortBy?: "createdAt" | "updatedAt" | "fullName" | "customerCode";
  sortOrder?: "asc" | "desc";
}

export interface CreateCustomerInput {
  fullName: string;
  phone: string;
  email?: string;
  gender?: string;
  birthDate?: string;
  isActive?: boolean;
  address?: string;
  notes?: string;
}

export interface UpdateCustomerInput {
  fullName?: string;
  phone?: string;
  email?: string;
  gender?: string;
  birthDate?: string;
  isActive?: boolean;
}

export interface ImportCustomerRow {
  fullName: string;
  phone: string;
  email?: string;
  gender?: string;
  birthDate?: string;
  address?: string;
  memberStatus?: string;
}

export type DuplicateImportStrategy = "SKIP" | "UPDATE" | "CANCEL";

export interface CustomerImportResult {
  imported: number;
  duplicate: number;
  failed: number;
  errors: Array<{ row: number; phone: string; message: string }>;
}

export interface OrderListItem {
  id: string;
  orderNumber: string;
  queueNumber: string;
  orderStatus: string;
  paymentStatus: string;
  grandTotal: number;
  pickupRequired: boolean;
  deliveryRequired: boolean;
  orderDate: string;
  completedDate: string | null;
}

export interface PaymentListItem {
  id: string;
  referenceNumber: string | null;
  amount: number;
  paymentStatus: string;
  paidAt: string;
}
