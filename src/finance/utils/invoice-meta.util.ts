export type InvoiceStatus = 'DRAFT' | 'ISSUED' | 'SENT' | 'PAID';

export interface InvoiceRecord {
  invoiceNumber: string;
  orderId: string;
  customerId: string;
  orderNumber: string;
  amount: number;
  status: InvoiceStatus;
  generatedAt: string;
  sentAt?: string;
  generatedByEmployeeId: string;
  sentByEmployeeId?: string;
}

export const INVOICE_SETTING_PREFIX = 'finance.invoice.';

export function buildInvoiceSettingKey(orderId: string): string {
  return `${INVOICE_SETTING_PREFIX}${orderId}`;
}

export function parseInvoiceRecord(value: string): InvoiceRecord | null {
  try {
    return JSON.parse(value) as InvoiceRecord;
  } catch {
    return null;
  }
}
