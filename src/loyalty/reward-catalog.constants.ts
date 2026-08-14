import { RewardCatalogType } from '@prisma/client';

/** Reference reward value of 1 point (NOT cash, NOT the laundry earn rate). */
export const POINT_REWARD_VALUE_IDR = 5_000;

export interface RewardCatalogSeedItem {
  code: string;
  name: string;
  description: string;
  type: RewardCatalogType;
  costPoints: number;
  kg?: number | null;
  serviceType?: string | null;
  serviceDurationDays?: number | null;
  metadata?: Record<string, unknown> | null;
}

export const YELO_REWARD_CATALOG_SEED: readonly RewardCatalogSeedItem[] = [
  {
    code: 'CKS_5KG',
    name: 'CKS 5 KG',
    description:
      'Cuci Kering Setrika gratis maksimal 5 kg (durasi 3 hari). Kelebihan kg dibayar terpisah.',
    type: RewardCatalogType.LAUNDRY_KG,
    costPoints: 5,
    kg: 5,
    serviceType: 'CKS',
    serviceDurationDays: 3,
    metadata: {
      serviceName: 'Cuci Kering Setrika',
      freeKg: 5,
      durationDays: 3,
    },
  },
  {
    code: 'CKS_10KG',
    name: 'CKS 10 KG',
    description:
      'Cuci Kering Setrika gratis maksimal 10 kg (durasi 3 hari). Kelebihan kg dibayar terpisah.',
    type: RewardCatalogType.LAUNDRY_KG,
    costPoints: 10,
    kg: 10,
    serviceType: 'CKS',
    serviceDurationDays: 3,
    metadata: {
      serviceName: 'Cuci Kering Setrika',
      freeKg: 10,
      durationDays: 3,
    },
  },
  {
    code: 'BANTAL_PREMIUM',
    name: 'Bantal Premium',
    description: 'Tukar 5 point dengan Bantal Premium.',
    type: RewardCatalogType.PHYSICAL_GOODS,
    costPoints: 5,
  },
  {
    code: 'BLENDER',
    name: 'Blender',
    description: 'Tukar 10 point dengan Blender.',
    type: RewardCatalogType.PHYSICAL_GOODS,
    costPoints: 10,
  },
  {
    code: 'SPREI',
    name: 'Sprei',
    description: 'Tukar 10 point dengan Sprei.',
    type: RewardCatalogType.PHYSICAL_GOODS,
    costPoints: 10,
  },
  {
    code: 'MAGIC_COM',
    name: 'Magic Com',
    description: 'Tukar 15 point dengan Magic Com.',
    type: RewardCatalogType.PHYSICAL_GOODS,
    costPoints: 15,
  },
] as const;
