/** Converts a Prisma Time field to HH:mm string. */
export function formatTimeValue(value: Date): string {
  const hours = value.getUTCHours().toString().padStart(2, '0');
  const minutes = value.getUTCMinutes().toString().padStart(2, '0');
  return `${hours}:${minutes}`;
}

/** Parses HH:mm into a Date suitable for Prisma @db.Time fields. */
export function parseTimeString(value: string): Date {
  const [hours, minutes] = value.split(':').map((part) => Number.parseInt(part, 10));
  return new Date(Date.UTC(1970, 0, 1, hours, minutes, 0, 0));
}
