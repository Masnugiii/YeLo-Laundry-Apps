import type { NumberingSequence } from "@/types/master-data";

export function suggestNextEmployeeCode(config: NumberingSequence): string {
  const nextCounter = config.currentCounter + 1;
  const padded = String(nextCounter).padStart(config.padding, "0");

  if (config.dailyReset) {
    const now = new Date();
    const year = now.getFullYear();
    const month = String(now.getMonth() + 1).padStart(2, "0");
    const day = String(now.getDate()).padStart(2, "0");
    return `${config.prefix}-${year}${month}${day}-${padded}`;
  }

  return `${config.prefix}-${padded}`;
}
