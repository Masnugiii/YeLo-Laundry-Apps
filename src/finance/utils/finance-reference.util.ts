export type FinanceReferenceKind = 'PAY' | 'INV' | 'EXP' | 'REF';

export function formatFinanceReferenceDate(date: Date): string {
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');

  return `${year}${month}${day}`;
}

export function buildFinanceReferencePrefix(
  kind: FinanceReferenceKind,
  date = new Date(),
): string {
  return `${kind}-${formatFinanceReferenceDate(date)}-`;
}

export function parseFinanceReferenceSequence(
  referenceNumber: string,
  prefix: string,
): number | null {
  if (!referenceNumber.startsWith(prefix)) {
    return null;
  }

  const sequencePart = referenceNumber.slice(prefix.length);
  const sequence = Number.parseInt(sequencePart, 10);

  return Number.isNaN(sequence) ? null : sequence;
}

export function formatFinanceReferenceNumber(
  kind: FinanceReferenceKind,
  sequence: number,
  date = new Date(),
): string {
  return `${buildFinanceReferencePrefix(kind, date)}${String(sequence).padStart(6, '0')}`;
}
