/**
 * Normalize Indonesian phone numbers to local format (e.g. 081234567890).
 */
export function normalizePhone(phone: string): string {
  let normalized = phone.replace(/[\s-]/g, '');

  if (normalized.startsWith('+62')) {
    normalized = `0${normalized.slice(3)}`;
  } else if (normalized.startsWith('62')) {
    normalized = `0${normalized.slice(2)}`;
  }

  return normalized;
}
