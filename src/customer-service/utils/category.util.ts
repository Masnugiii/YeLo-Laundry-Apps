export const CS_CATEGORIES = [
  'ORDER_BARU',
  'KOMPLAIN',
  'PERTANYAAN',
  'PROMO',
  'TRACKING_ORDER',
  'LAINNYA',
] as const;

export type CsCategory = (typeof CS_CATEGORIES)[number];

const CATEGORY_PREFIX = /^\[CS:([A-Z_]+)\]\s*/;

export function parseCategory(subject: string): CsCategory {
  const match = subject.match(CATEGORY_PREFIX);
  const value = match?.[1];
  if (value && CS_CATEGORIES.includes(value as CsCategory)) {
    return value as CsCategory;
  }
  return 'LAINNYA';
}

export function stripCategoryPrefix(subject: string): string {
  return subject.replace(CATEGORY_PREFIX, '').trim();
}

export function formatSubject(category: CsCategory, subject: string): string {
  const cleanSubject = stripCategoryPrefix(subject);
  return `[CS:${category}] ${cleanSubject}`;
}

export function categoryConfidence(category: CsCategory): number {
  return category === 'LAINNYA' ? 0 : 85;
}
