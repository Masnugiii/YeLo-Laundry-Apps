export const PERMISSIONS = {
  DASHBOARD: 'dashboard',
  ORDERS: 'orders',
  FINANCE: 'finance',
  CUSTOMERS: 'customers',
  WALLET: 'wallet',
  LOYALTY: 'loyalty',
  ATTENDANCE: 'attendance',
  IRONING: 'ironing',
  PICKUP: 'pickup',
  DELIVERY: 'delivery',
  REPORTS: 'reports',
  SETTINGS: 'settings',
  NOTIFICATION: 'notification',
  CUSTOMER_SERVICE: 'customer_service',
} as const;

export type Permission = (typeof PERMISSIONS)[keyof typeof PERMISSIONS];
