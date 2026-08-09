export const SETTINGS_SECTIONS = [
  'company',
  'services',
  'pricing',
  'payroll',
  'loyalty',
  'membership',
  'wallet',
  'delivery',
  'attendance',
  'payment_methods',
  'expense_categories',
  'notifications',
  'backup',
  'documents',
  'numbering',
] as const;

export type SettingsSection = (typeof SETTINGS_SECTIONS)[number];

/** Sections writable via PATCH /settings/:section in Phase 1. */
export const WRITABLE_SETTINGS_SECTIONS: readonly SettingsSection[] = [
  'company',
  'payroll',
  'loyalty',
] as const;

export interface SettingsSectionMeta {
  section: SettingsSection;
  label: string;
  writable: boolean;
  description: string;
}

export interface SettingsManifestResponse {
  writableSections: SettingsSection[];
  sections: Partial<Record<SettingsSection, unknown>>;
}

export interface SettingsSectionUpdateResponse {
  section: SettingsSection;
  data: unknown;
}

export function isSettingsSection(value: string): value is SettingsSection {
  return (SETTINGS_SECTIONS as readonly string[]).includes(value);
}

export function isWritableSettingsSection(
  section: SettingsSection,
): boolean {
  return (WRITABLE_SETTINGS_SECTIONS as readonly string[]).includes(section);
}

export const SETTINGS_SECTION_META: Record<
  SettingsSection,
  Omit<SettingsSectionMeta, 'section'>
> = {
  company: {
    label: 'Company / Business Profile',
    writable: true,
    description: 'Outlet profile, timezone, currency, and tax settings',
  },
  services: {
    label: 'Services',
    writable: false,
    description: 'Laundry service catalog (read-only in Phase 1)',
  },
  pricing: {
    label: 'Pricing',
    writable: false,
    description: 'Active service prices (read-only in Phase 1)',
  },
  payroll: {
    label: 'Payroll',
    writable: true,
    description: 'Payroll calculation rules and schedule',
  },
  loyalty: {
    label: 'Loyalty',
    writable: true,
    description: 'Points, cashback, and loyalty program rules',
  },
  membership: {
    label: 'Membership',
    writable: false,
    description: 'Membership tiers (derived from loyalty settings)',
  },
  wallet: {
    label: 'Yelo Wallet',
    writable: false,
    description: 'Wallet rules (derived from loyalty settings)',
  },
  delivery: {
    label: 'Delivery',
    writable: false,
    description: 'Pickup and delivery configuration (Phase 2)',
  },
  attendance: {
    label: 'Attendance',
    writable: false,
    description: 'Work hours and attendance defaults (read-only in Phase 1)',
  },
  payment_methods: {
    label: 'Payment Methods',
    writable: false,
    description: 'Accepted payment methods (read-only in Phase 1)',
  },
  expense_categories: {
    label: 'Expense Categories',
    writable: false,
    description: 'Expense category master data (read-only in Phase 1)',
  },
  notifications: {
    label: 'Notifications',
    writable: false,
    description: 'Notification templates and toggles (Phase 2)',
  },
  backup: {
    label: 'Backup',
    writable: false,
    description: 'Backup schedule and retention (Phase 2)',
  },
  documents: {
    label: 'Document Rules',
    writable: false,
    description: 'Upload limits and file type rules (Phase 2)',
  },
  numbering: {
    label: 'Business Numbering',
    writable: false,
    description: 'ORD/INV/EXP/PAY/CST/EMP numbering configuration',
  },
};
