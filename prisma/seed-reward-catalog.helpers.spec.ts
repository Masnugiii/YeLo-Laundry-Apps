import { YELO_REWARD_CATALOG_SEED } from '../src/loyalty/reward-catalog.constants';
import { seedYeloRewardCatalog } from './seed-reward-catalog.helpers';

describe('seedYeloRewardCatalog', () => {
  it('upserts exactly the six required rewards without duplicates on rerun', async () => {
    const upsert = jest.fn().mockResolvedValue({});
    const tx = {
      rewardCatalogItem: { upsert },
    };

    const first = await seedYeloRewardCatalog(tx as never);
    const second = await seedYeloRewardCatalog(tx as never);

    expect(first.upserted).toBe(6);
    expect(second.upserted).toBe(6);
    expect(first.codes).toEqual(YELO_REWARD_CATALOG_SEED.map((item) => item.code));
    expect(upsert).toHaveBeenCalledTimes(12);
    expect(upsert.mock.calls[0][0].where).toEqual({ code: 'CKS_5KG' });
    expect(upsert.mock.calls[0][0].create.costPoints).toBe(5);
    expect(upsert.mock.calls[0][0].create.kg).toBe(5);
    expect(upsert.mock.calls[0][0].update.isActive).toBeUndefined();
  });
});
