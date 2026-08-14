import type { EmployeeRole } from "@/types/employee";

export type { EmployeeRole };

export const INTERNAL_ACCESS_ROLES: EmployeeRole[] = [
  "OWNER",
  "MANAGER",
  "CASHIER",
  "OPERATOR",
  "BINATU",
  "DRIVER",
];

export const INTERNAL_ROLE_LABELS: Record<EmployeeRole, string> = {
  OWNER: "Owner",
  MANAGER: "Manager",
  CASHIER: "Cashier",
  OPERATOR: "Operator",
  BINATU: "Binatu",
  DRIVER: "Driver",
};

export interface InternalRoleRecord {
  id: string;
  code: string;
  name: string;
  description?: string | null;
  apiRole: EmployeeRole;
  isActive: boolean;
}

export interface PermissionRecord {
  id: string;
  code: string;
  name: string;
  module: string;
  description?: string | null;
}

export type FeatureViewMatch = "all" | "any";

export type FeatureManageMode = "permission" | "role-default";

export type FeatureCapabilityLayout = "standard" | "wallet";

export interface InternalAccessFeature {
  id: string;
  label: string;
  description: string;
  viewPermissions: string[];
  viewMatch?: FeatureViewMatch;
  managePermissions?: string[];
  manageMode?: FeatureManageMode;
  manageRoleDefaults?: Partial<Record<EmployeeRole, boolean>>;
  linkedFeatureIds?: string[];
  capabilityLayout?: FeatureCapabilityLayout;
  topUpPermissions?: string[];
  deductPermissions?: string[];
  viewHint?: string;
  topUpHint?: string;
  deductHint?: string;
}

export interface FeatureAccessState {
  view: boolean;
  manage: boolean;
  topUp?: boolean;
  deduct?: boolean;
}

export type AccessMatrixState = Record<string, FeatureAccessState>;

export interface AssignRolePermissionsInput {
  roleId: string;
  permissionIds: string[];
}
