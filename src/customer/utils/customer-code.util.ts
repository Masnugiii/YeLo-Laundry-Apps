export function formatCustomerCode(sequence: number): string {
  return `CUS-${String(sequence).padStart(4, '0')}`;
}

export function parseCustomerCodeSequence(customerCode: string): number | null {
  const match = customerCode.match(/^CUS-(\d+)$/i);
  if (!match) {
    return null;
  }

  return Number.parseInt(match[1], 10);
}
