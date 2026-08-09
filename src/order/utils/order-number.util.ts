const INVOICE_PREFIX = 'YL';

export function formatOrderDate(date: Date): string {
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');

  return `${year}${month}${day}`;
}

export function buildInvoicePrefix(date = new Date()): string {
  return `${INVOICE_PREFIX}-${formatOrderDate(date)}-`;
}

export function parseInvoiceSequence(
  invoiceNumber: string,
  prefix: string,
): number | null {
  if (!invoiceNumber.startsWith(prefix)) {
    return null;
  }

  const sequencePart = invoiceNumber.slice(prefix.length);
  const sequence = Number.parseInt(sequencePart, 10);

  return Number.isNaN(sequence) ? null : sequence;
}

export function formatInvoiceNumber(
  sequence: number,
  date = new Date(),
): string {
  return `${buildInvoicePrefix(date)}${String(sequence).padStart(6, '0')}`;
}
