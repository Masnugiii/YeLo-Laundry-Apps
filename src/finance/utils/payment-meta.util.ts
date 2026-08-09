export interface RefundHistoryEntry {
  referenceNumber: string;
  amount: number;
  reason: string;
  refundedAt: string;
  refundedByEmployeeId: string;
}

export interface PaymentFinancialMeta {
  apiPaymentMethod?: string;
  discountType?: 'PERCENTAGE' | 'FIXED' | 'MANUAL' | 'VOUCHER';
  discountValue?: number;
  voucherCode?: string;
  refunds?: RefundHistoryEntry[];
}

const META_PREFIX = '<!--PAYMENT_META:';
const META_SUFFIX = '-->';

const DEFAULT_META: PaymentFinancialMeta = {};

export function encodePaymentNotes(
  meta: Partial<PaymentFinancialMeta>,
  notes?: string | null,
): string | null {
  const payload: PaymentFinancialMeta = {
    ...DEFAULT_META,
    ...meta,
  };

  const hasMeta =
    payload.apiPaymentMethod ||
    payload.discountType ||
    payload.discountValue ||
    payload.voucherCode ||
    (payload.refunds?.length ?? 0) > 0;

  const body = notes?.trim() ?? '';

  if (!hasMeta && !body) {
    return null;
  }

  return `${META_PREFIX}${JSON.stringify(payload)}${META_SUFFIX}${body ? `\n${body}` : ''}`;
}

export function decodePaymentNotes(stored: string | null | undefined): {
  meta: PaymentFinancialMeta;
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
    ) as Partial<PaymentFinancialMeta>;

    const body = stored.slice(metaEndIndex + META_SUFFIX.length).trimStart();

    return {
      meta: {
        ...DEFAULT_META,
        ...parsed,
        refunds: parsed.refunds ?? [],
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

export function getTotalRefunded(meta: PaymentFinancialMeta): number {
  return (meta.refunds ?? []).reduce((sum, entry) => sum + entry.amount, 0);
}
