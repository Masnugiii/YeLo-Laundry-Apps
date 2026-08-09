export function getAttendanceDate(date = new Date()): Date {
  return new Date(date.getFullYear(), date.getMonth(), date.getDate());
}

export function formatDateKey(date: Date): string {
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');

  return `${year}-${month}-${day}`;
}

export function parseDateKey(value: string): Date {
  const [year, month, day] = value.split('-').map((part) => Number.parseInt(part, 10));

  return new Date(year, month - 1, day);
}

export function getMinutesFromDate(date: Date): number {
  return date.getHours() * 60 + date.getMinutes();
}

export function getMinutesFromTimeValue(timeValue: Date): number {
  return timeValue.getUTCHours() * 60 + timeValue.getUTCMinutes();
}
