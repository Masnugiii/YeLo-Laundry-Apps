export const ROLES = {
  OWNER: 'OWNER',
  MANAGER: 'MANAGER',
  CASHIER: 'CASHIER',
  OPERATOR: 'OPERATOR',
  BINATU: 'BINATU',
  DRIVER: 'DRIVER',
} as const;

export type Role = (typeof ROLES)[keyof typeof ROLES];
