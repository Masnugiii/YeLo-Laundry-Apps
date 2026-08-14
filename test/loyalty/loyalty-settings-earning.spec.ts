import {
  calculateDepositPoints,
  calculateLaundryPaymentPoints,
} from '../../src/loyalty/loyalty-earning.rules';

describe('loyalty earning rules — configurable settings', () => {
  it('uses updated laundry minimum transaction (Rp60.000)', () => {
    const rule = {
      enabled: true,
      minimumTransaction: 60_000,
      pointsPerUnit: 1,
    };

    expect(calculateLaundryPaymentPoints(59_999, rule)).toBe(0);
    expect(calculateLaundryPaymentPoints(60_000, rule)).toBe(1);
    expect(calculateLaundryPaymentPoints(120_000, rule)).toBe(2);
  });

  it('uses updated deposit rule (Rp500.000 / 10 points)', () => {
    const rule = {
      enabled: true,
      minimumDeposit: 500_000,
      pointsPerMultiplier: 10,
    };

    expect(calculateDepositPoints(499_999, rule)).toBe(0);
    expect(calculateDepositPoints(500_000, rule)).toBe(10);
    expect(calculateDepositPoints(1_000_000, rule)).toBe(20);
  });

  it('returns zero when laundry earning is disabled', () => {
    expect(
      calculateLaundryPaymentPoints(100_000, {
        enabled: false,
        minimumTransaction: 50_000,
        pointsPerUnit: 1,
      }),
    ).toBe(0);
  });

  it('returns zero when deposit earning is disabled', () => {
    expect(
      calculateDepositPoints(500_000, {
        enabled: false,
        minimumDeposit: 250_000,
        pointsPerMultiplier: 6,
      }),
    ).toBe(0);
  });
});
