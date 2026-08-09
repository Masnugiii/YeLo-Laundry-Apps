export enum CustomerNoteCategory {
  SERVICE = 'SERVICE',
  COMPLAINT = 'COMPLAINT',
  PAYMENT = 'PAYMENT',
  DELIVERY = 'DELIVERY',
  SPECIAL_REQUEST = 'SPECIAL_REQUEST',
  OTHER = 'OTHER',
}

export interface CustomerNoteMeta {
  title: string | null;
  category: CustomerNoteCategory;
  isPinned: boolean;
}

export interface DecodedCustomerNote {
  meta: CustomerNoteMeta;
  body: string;
}

const META_PREFIX = '<!--NOTE_META:';
const META_SUFFIX = '-->';

const DEFAULT_META: CustomerNoteMeta = {
  title: null,
  category: CustomerNoteCategory.OTHER,
  isPinned: false,
};

export function encodeCustomerNote(
  meta: Partial<CustomerNoteMeta>,
  body: string,
): string {
  const payload: CustomerNoteMeta = {
    title: meta.title?.trim() || null,
    category: meta.category ?? CustomerNoteCategory.OTHER,
    isPinned: meta.isPinned ?? false,
  };

  return `${META_PREFIX}${JSON.stringify(payload)}${META_SUFFIX}\n${body.trim()}`;
}

export function decodeCustomerNote(stored: string): DecodedCustomerNote {
  if (!stored.startsWith(META_PREFIX)) {
    return {
      meta: { ...DEFAULT_META },
      body: stored,
    };
  }

  const metaEndIndex = stored.indexOf(META_SUFFIX);

  if (metaEndIndex === -1) {
    return {
      meta: { ...DEFAULT_META },
      body: stored,
    };
  }

  const metaJson = stored.slice(META_PREFIX.length, metaEndIndex);

  try {
    const parsed = JSON.parse(metaJson) as Partial<CustomerNoteMeta>;
    const body = stored.slice(metaEndIndex + META_SUFFIX.length).trimStart();

    return {
      meta: {
        title: parsed.title ?? null,
        category: isValidCategory(parsed.category)
          ? parsed.category
          : CustomerNoteCategory.OTHER,
        isPinned: parsed.isPinned ?? false,
      },
      body,
    };
  } catch {
    return {
      meta: { ...DEFAULT_META },
      body: stored,
    };
  }
}

export function buildPinnedMarker(): string {
  return '"isPinned":true';
}

export function buildCategoryMarker(category: CustomerNoteCategory): string {
  return `"category":"${category}"`;
}

function isValidCategory(
  value: unknown,
): value is CustomerNoteCategory {
  return (
    typeof value === 'string' &&
    Object.values(CustomerNoteCategory).includes(value as CustomerNoteCategory)
  );
}
