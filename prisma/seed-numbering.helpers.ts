import { Prisma } from '@prisma/client';

export const DEFAULT_NUMBERING_SEQUENCES = [
  { type: 'ORD', prefix: 'YL', padding: 6, dailyReset: true, currentCounter: 0 },
  { type: 'INV', prefix: 'INV', padding: 6, dailyReset: true, currentCounter: 0 },
  { type: 'EXP', prefix: 'EXP', padding: 6, dailyReset: true, currentCounter: 0 },
  { type: 'PAY', prefix: 'PAY', padding: 6, dailyReset: true, currentCounter: 0 },
  { type: 'CST', prefix: 'CUS', padding: 4, dailyReset: false, currentCounter: 0 },
  { type: 'EMP', prefix: 'EMP', padding: 4, dailyReset: false, currentCounter: 0 },
] as const;

export async function seedDefaultNumberingSequences(
  tx: Prisma.TransactionClient,
): Promise<number> {
  let created = 0;

  for (const sequence of DEFAULT_NUMBERING_SEQUENCES) {
    const existing = await tx.numberingSequence.findUnique({
      where: { type: sequence.type },
      select: { id: true },
    });

    if (existing) {
      continue;
    }

    await tx.numberingSequence.create({
      data: {
        type: sequence.type,
        prefix: sequence.prefix,
        padding: sequence.padding,
        dailyReset: sequence.dailyReset,
        currentCounter: sequence.currentCounter,
        isActive: true,
      },
    });

    created += 1;
  }

  return created;
}
