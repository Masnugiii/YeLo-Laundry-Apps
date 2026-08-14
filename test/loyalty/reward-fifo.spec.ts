import { planFifoConsumption, sumAvailablePoints } from '../../src/loyalty/reward-fifo';

describe('reward FIFO helpers', () => {
  it('consumes earliest-expiring lots first', () => {
    const plan = planFifoConsumption(
      [
        { id: 'a', remainingPoint: 5 },
        { id: 'b', remainingPoint: 5 },
      ],
      6,
    );

    expect(plan).toEqual([
      { earnPointId: 'a', points: 5 },
      { earnPointId: 'b', points: 1 },
    ]);
  });

  it('throws when active lots are insufficient', () => {
    expect(() =>
      planFifoConsumption([{ id: 'a', remainingPoint: 4 }], 5),
    ).toThrow('INSUFFICIENT_ACTIVE_POINTS');
  });

  it('sums available remaining points', () => {
    expect(
      sumAvailablePoints([
        { remainingPoint: 5 },
        { remainingPoint: 0 },
        { remainingPoint: 3 },
      ]),
    ).toBe(8);
  });
});
