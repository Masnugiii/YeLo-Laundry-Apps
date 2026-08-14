import {
  buildPointExpirationDate,
  calculateDepositPoints,
  calculateLaundryPaymentPoints,
} from '../../src/loyalty/loyalty-earning.rules';

describe('loyalty earning rules', () => {
  describe('laundry payment formula', () => {
    it.each([
      [49_999, 0],
      [50_000, 1],
      [75_000, 1],
      [99_999, 1],
      [100_000, 2],
      [150_000, 3],
      [249_999, 4],
      [250_000, 5],
      [500_000, 10],
    ])('floor(%i / 50000) => %i point(s)', (amount, expected) => {
      expect(calculateLaundryPaymentPoints(amount)).toBe(expected);
    });

    it('rejects non-positive and non-finite amounts (no installment junk)', () => {
      expect(calculateLaundryPaymentPoints(0)).toBe(0);
      expect(calculateLaundryPaymentPoints(-50_000)).toBe(0);
      expect(calculateLaundryPaymentPoints(Number.NaN)).toBe(0);
    });
  });

  describe('deposit formula', () => {
    it.each([
      [100_000, 0],
      [200_000, 0],
      [249_999, 0],
      [250_000, 6],
      [300_000, 6],
      [499_999, 6],
      [500_000, 12],
      [750_000, 18],
      [1_000_000, 24],
    ])('deposit %i => %i point(s)', (amount, expected) => {
      expect(calculateDepositPoints(amount)).toBe(expected);
    });
  });

  describe('expiration date', () => {
    it('uses configured pointExpirationDays from settings', () => {
      const from = new Date(2026, 0, 1);
      const expiredAt = buildPointExpirationDate(30, from);
      expect(expiredAt.getFullYear()).toBe(2026);
      expect(expiredAt.getMonth()).toBe(0);
      expect(expiredAt.getDate()).toBe(31);
    });
  });
});
