const DEFAULT_DEV_OTP_PHONES = [
  '081234567890',
  '081234567891',
  '081234567892',
  '081234567893',
  '081234567894',
  '081910090910',
];

export function parseDevOtpPhoneWhitelist(raw?: string): Set<string> {
  const source = raw?.trim() ? raw : DEFAULT_DEV_OTP_PHONES.join(',');
  return new Set(
    source
      .split(',')
      .map((phone) => phone.trim())
      .filter(Boolean),
  );
}

export const DEV_OTP_GENERATE_RATE_LIMIT = 10;
export const DEV_OTP_GENERATE_WINDOW_MS = 15 * 60 * 1000;
