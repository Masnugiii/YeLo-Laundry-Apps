export interface OrderFinancialMeta {
  discount: number;
  tax: number;
  serviceFee: number;
}

const META_PREFIX = '<!--ORDER_META:';
const META_SUFFIX = '-->';

const DEFAULT_META: OrderFinancialMeta = {
  discount: 0,
  tax: 0,
  serviceFee: 0,
};

export function encodeOrderNotes(
  meta: Partial<OrderFinancialMeta>,
  notes?: string | null,
): string | null {
  const payload: OrderFinancialMeta = {
    discount: meta.discount ?? 0,
    tax: meta.tax ?? 0,
    serviceFee: meta.serviceFee ?? 0,
  };

  const body = notes?.trim() ?? '';

  if (!payload.discount && !payload.tax && !payload.serviceFee && !body) {
    return null;
  }

  return `${META_PREFIX}${JSON.stringify(payload)}${META_SUFFIX}${body ? `\n${body}` : ''}`;
}

export function decodeOrderNotes(stored: string | null | undefined): {
  meta: OrderFinancialMeta;
  notes: string | null;
} {
  if (!stored?.startsWith(META_PREFIX)) {
    return {
      meta: { ...DEFAULT_META },
      notes: stored ?? null,
    };
  }

  const metaEndIndex = stored.indexOf(META_SUFFIX);

  if (metaEndIndex === -1) {
    return {
      meta: { ...DEFAULT_META },
      notes: stored,
    };
  }

  try {
    const parsed = JSON.parse(
      stored.slice(META_PREFIX.length, metaEndIndex),
    ) as Partial<OrderFinancialMeta>;

    const body = stored.slice(metaEndIndex + META_SUFFIX.length).trimStart();

    return {
      meta: {
        discount: Number(parsed.discount ?? 0),
        tax: Number(parsed.tax ?? 0),
        serviceFee: Number(parsed.serviceFee ?? 0),
      },
      notes: body || null,
    };
  } catch {
    return {
      meta: { ...DEFAULT_META },
      notes: stored,
    };
  }
}
