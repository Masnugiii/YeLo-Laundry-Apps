import { Decimal } from '@prisma/client/runtime/library';
import {
  CustomerDetailRecord,
  CustomerListRecord,
  CustomerSearchRecord,
} from './customer.select';

export interface CustomerWalletSummary {
  balance: number;
  currency: string;
  isActive: boolean;
}

export interface CustomerAddressSummary {
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

export interface CustomerListItem {
  id: string;
  customerCode: string;
  fullName: string;
  phone: string;
  email: string | null;
  gender: string | null;
  birthDate: Date | null;
  photoUrl: string | null;
  isActive: boolean;
  loyaltyPoints: number;
  walletBalance: number;
  memberStatus: 'MEMBER' | 'REGULAR';
  totalOrders: number;
  totalSpending: number;
  lastOrderAt: Date | null;
  createdAt: Date;
  updatedAt: Date;
  deletedAt: Date | null;
}

export interface CustomerBusinessSummary {
  totalOrders: number;
  completedOrders: number;
  cancelledOrders: number;
  totalSpending: number;
  averageOrderValue: number;
  memberSince: Date;
  lastOrderAt: Date | null;
}

export interface CustomerImportResult {
  imported: number;
  duplicate: number;
  failed: number;
  errors: Array<{ row: number; phone: string; message: string }>;
}

export interface CustomerDetail extends CustomerListItem {
  wallet: CustomerWalletSummary | null;
  defaultAddress: CustomerAddressSummary | null;
  addresses: CustomerAddressSummary[];
}

export interface CustomerSearchResult {
  id: string;
  customerCode: string;
  fullName: string;
  phone: string;
  isActive: boolean;
  walletBalance: number;
}

export interface PaginatedCustomers {
  items: CustomerListItem[];
  meta: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}

function decimalToNumber(value: Decimal | number | null | undefined): number {
  if (value === null || value === undefined) {
    return 0;
  }

  return Number(value);
}

function sumLoyaltyPoints(
  rewardPoints: Array<{ point: number }> | undefined,
): number {
  return rewardPoints?.reduce((total, entry) => total + entry.point, 0) ?? 0;
}

function mapAddress(
  address: CustomerDetailRecord['defaultAddress'],
): CustomerAddressSummary | null {
  if (!address) {
    return null;
  }

  return {
    id: address.id,
    recipientName: address.recipientName,
    phone: address.phone,
    province: address.province,
    city: address.city,
    district: address.district,
    postalCode: address.postalCode,
    addressDetail: address.addressDetail,
    isDefault: address.isDefault,
  };
}

export function toCustomerListItem(
  customer: CustomerListRecord,
  stats?: {
    totalOrders: number;
    totalSpending: number;
    lastOrderAt: Date | null;
  },
): CustomerListItem {
  const loyaltyPoints = sumLoyaltyPoints(customer.rewardPoints);

  return {
    id: customer.id,
    customerCode: customer.customerCode,
    fullName: customer.fullName,
    phone: customer.phone,
    email: customer.email,
    gender: customer.gender,
    birthDate: customer.birthDate,
    photoUrl: customer.photoUrl,
    isActive: customer.isActive,
    loyaltyPoints,
    walletBalance: decimalToNumber(customer.wallet?.currentBalance),
    memberStatus: loyaltyPoints > 0 ? 'MEMBER' : 'REGULAR',
    totalOrders: stats?.totalOrders ?? 0,
    totalSpending: stats?.totalSpending ?? 0,
    lastOrderAt: stats?.lastOrderAt ?? null,
    createdAt: customer.createdAt,
    updatedAt: customer.updatedAt,
    deletedAt: customer.deletedAt,
  };
}

export function toCustomerDetail(
  customer: CustomerDetailRecord,
  stats?: {
    totalOrders: number;
    totalSpending: number;
    lastOrderAt: Date | null;
  },
): CustomerDetail {
  const listItem = toCustomerListItem(customer, stats);

  return {
    ...listItem,
    wallet: customer.wallet
      ? {
          balance: decimalToNumber(customer.wallet.currentBalance),
          currency: customer.wallet.currency,
          isActive: customer.wallet.isActive,
        }
      : null,
    defaultAddress: mapAddress(customer.defaultAddress),
    addresses: (customer.addresses ?? []).map(
      (address) => mapAddress(address)!,
    ),
  };
}

export function toCustomerSearchResult(
  customer: CustomerSearchRecord,
): CustomerSearchResult {
  return {
    id: customer.id,
    customerCode: customer.customerCode,
    fullName: customer.fullName,
    phone: customer.phone,
    isActive: customer.isActive,
    walletBalance: decimalToNumber(customer.wallet?.currentBalance),
  };
}
