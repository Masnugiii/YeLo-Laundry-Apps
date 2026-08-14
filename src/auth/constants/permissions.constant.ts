export const PERMISSIONS = {
  DASHBOARD: 'dashboard',
  ORDERS: 'orders',
  FINANCE: 'finance',
  CUSTOMERS: 'customers',
  WALLET: 'wallet',
  WALLET_TOPUP: 'wallet_topup',
  WALLET_DEDUCT: 'wallet_deduct',
  LOYALTY: 'loyalty',
  ATTENDANCE: 'attendance',
  IRONING: 'ironing',
  PICKUP: 'pickup',
  DELIVERY: 'delivery',
  REPORTS: 'reports',
  SETTINGS: 'settings',
  NOTIFICATION: 'notification',
  CUSTOMER_SERVICE: 'customer_service',
  STORAGE: 'storage',
} as const;

export type Permission = (typeof PERMISSIONS)[keyof typeof PERMISSIONS];
