const REFERENCE_PREFIX = 'WLT';

export function formatWalletReferenceDate(date: Date): string {
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');

  return `${year}${month}${day}`;
}

export function buildWalletReferencePrefix(date = new Date()): string {
  return `${REFERENCE_PREFIX}-${formatWalletReferenceDate(date)}-`;
}

export function parseWalletReferenceSequence(
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

export function formatWalletReferenceNumber(
  sequence: number,
  date = new Date(),
): string {
  return `${buildWalletReferencePrefix(date)}${String(sequence).padStart(6, '0')}`;
}
