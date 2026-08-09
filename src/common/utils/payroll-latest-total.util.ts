export function parsePayrollLatestTotal(settingValue?: string | null): number {
  if (!settingValue) {
    return 0;
  }

  try {
    const parsed = JSON.parse(settingValue) as { total?: number } | number;
    if (typeof parsed === 'object' && parsed !== null && 'total' in parsed) {
      return Number(parsed.total ?? 0);
    }
    return Number(parsed);
  } catch {
    const fallback = Number(settingValue);
    return Number.isFinite(fallback) ? fallback : 0;
  }
}
