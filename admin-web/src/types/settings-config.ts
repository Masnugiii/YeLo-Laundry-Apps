export interface CompanySettings {
  id?: string;
  companyName: string;
  phone: string | null;
  email: string | null;
  address: string | null;
  logoUrl: string | null;
  businessHours: string | null;
  timezone: string | null;
  currency: string | null;
  taxRate: number | null;
}

export interface AttendanceGpsConfig {
  officeLatitude: number;
  officeLongitude: number;
  officeRadiusMeters: number;
}

export interface AttendanceSettings {
  id?: string;
  workStartTime: string;
  workEndTime: string;
  lateToleranceMinutes: number;
  overtimeEnabled: boolean;
  gps: AttendanceGpsConfig | null;
  shiftCount: number;
}

export type DocumentCompressionMode = "original" | "compress";

export interface DocumentRules {
  maxFileSizeBytes: number;
  allowedMimeTypes: string[];
  compressionMode: DocumentCompressionMode;
  ocrEnabled: boolean;
}

export type BackupSchedule = "daily" | "weekly" | "monthly";

export interface BackupSettings {
  enabled: boolean;
  schedule: BackupSchedule;
  retentionDays: number;
}

export interface NotificationToggleSettings {
  notify_new_order: boolean;
  notify_payment: boolean;
  notify_ironing_finished: boolean;
  notify_pickup_delivery: boolean;
  notify_wallet: boolean;
}

export interface NotificationTemplateConfig {
  id: string;
  code: string;
  title: string;
  body: string;
  isActive: boolean;
}

export interface NotificationSettings {
  settings: NotificationToggleSettings;
  templates: NotificationTemplateConfig[];
}

export interface DeliverySettingsResponse {
  status: "not_configured";
  message?: string;
}

export interface QrisPaymentSettings {
  isActive: boolean;
  qrImageUrl: string | null;
  qrPayload: string | null;
  instructions: string;
}

export interface BankTransferPaymentSettings {
  isActive: boolean;
  bankName: string;
  accountNumber: string;
  accountHolder: string;
  instructions: string;
}

export interface PaymentSettings {
  qris: QrisPaymentSettings;
  bankTransfer: BankTransferPaymentSettings;
}

export interface SettingsSectionUpdateResult<T> {
  section: string;
  data: T;
}
