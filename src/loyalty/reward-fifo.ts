/**
 * FIFO plan for consuming earn lots ordered by expiredAt ASC.
 */
export function planFifoConsumption(
  lots: Array<{ id: string; remainingPoint: number }>,
  pointsNeeded: number,
): Array<{ earnPointId: string; points: number }> {
  if (!Number.isFinite(pointsNeeded) || pointsNeeded <= 0) {
    return [];
  }

  let remaining = Math.floor(pointsNeeded);
  const plan: Array<{ earnPointId: string; points: number }> = [];

  for (const lot of lots) {
    if (remaining <= 0) {
      break;
    }
    const available = Math.max(0, Math.floor(lot.remainingPoint));
    if (available <= 0) {
      continue;
    }
    const take = Math.min(available, remaining);
    plan.push({ earnPointId: lot.id, points: take });
    remaining -= take;
  }

  if (remaining > 0) {
    throw new Error('INSUFFICIENT_ACTIVE_POINTS');
  }

  return plan;
}

export function sumAvailablePoints(
  lots: Array<{ remainingPoint: number }>,
): number {
  return lots.reduce(
    (sum, lot) => sum + Math.max(0, Math.floor(lot.remainingPoint)),
    0,
  );
}
