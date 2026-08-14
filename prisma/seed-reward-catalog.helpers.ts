import { Prisma, PrismaClient } from '@prisma/client';
import { YELO_REWARD_CATALOG_SEED } from '../src/loyalty/reward-catalog.constants';

type DbClient = PrismaClient | Prisma.TransactionClient;

/**
 * Idempotent upsert of the six YeLo Rewards catalog items.
 * Safe to re-run; does not delete or deactivate existing custom rewards.
 */
export async function seedYeloRewardCatalog(db: DbClient): Promise<{
  upserted: number;
  codes: string[];
}> {
  let upserted = 0;
  const codes: string[] = [];

  for (const item of YELO_REWARD_CATALOG_SEED) {
    const metadata = item.metadata
      ? (item.metadata as Prisma.InputJsonValue)
      : undefined;

    await db.rewardCatalogItem.upsert({
      where: { code: item.code },
      create: {
        code: item.code,
        name: item.name,
        description: item.description,
        type: item.type,
        costPoints: item.costPoints,
        isActive: true,
        kg: item.kg ?? null,
        serviceType: item.serviceType ?? null,
        serviceDurationDays: item.serviceDurationDays ?? null,
        metadata,
      },
      update: {
        name: item.name,
        description: item.description,
        type: item.type,
        costPoints: item.costPoints,
        kg: item.kg ?? null,
        serviceType: item.serviceType ?? null,
        serviceDurationDays: item.serviceDurationDays ?? null,
        metadata,
        deletedAt: null,
        // Do not force isActive=true on update so operators can deactivate.
      },
    });
    upserted += 1;
    codes.push(item.code);
  }

  return { upserted, codes };
}
