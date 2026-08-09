export type ExpenseApprovalStatus = 'PENDING' | 'APPROVED' | 'REJECTED';

export interface ExpenseFinancialMeta {
  referenceNumber: string;
  approvalStatus: ExpenseApprovalStatus;
  approvedByEmployeeId?: string;
  approvedAt?: string;
  rejectionReason?: string;
}

const META_PREFIX = '<!--EXPENSE_META:';
const META_SUFFIX = '-->';

export function encodeExpenseDescription(
  meta: ExpenseFinancialMeta,
  description?: string | null,
): string {
  const body = description?.trim() ?? '';
  return `${META_PREFIX}${JSON.stringify(meta)}${META_SUFFIX}${body ? `\n${body}` : ''}`;
}

export function decodeExpenseDescription(stored: string | null | undefined): {
  meta: ExpenseFinancialMeta | null;
  description: string | null;
} {
  if (!stored?.startsWith(META_PREFIX)) {
    return { meta: null, description: stored ?? null };
  }

  const metaEndIndex = stored.indexOf(META_SUFFIX);

  if (metaEndIndex === -1) {
    return { meta: null, description: stored };
  }

  try {
    const parsed = JSON.parse(
      stored.slice(META_PREFIX.length, metaEndIndex),
    ) as ExpenseFinancialMeta;

    const body = stored.slice(metaEndIndex + META_SUFFIX.length).trimStart();

    return {
      meta: parsed,
      description: body || null,
    };
  } catch {
    return { meta: null, description: stored };
  }
}
