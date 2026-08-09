import { ReportPeriodPreset } from '../dto/report-query.dto';

export interface ResolvedReportRange {
  dateFrom: Date;
  dateTo: Date;
  preset: ReportPeriodPreset;
}

function startOfDay(date: Date): Date {
  return new Date(date.getFullYear(), date.getMonth(), date.getDate());
}

function endOfDay(date: Date): Date {
  const end = startOfDay(date);
  end.setHours(23, 59, 59, 999);
  return end;
}

export function resolveReportRange(
  preset: ReportPeriodPreset = ReportPeriodPreset.THIS_MONTH,
  dateFrom?: Date,
  dateTo?: Date,
): ResolvedReportRange {
  if (preset === ReportPeriodPreset.CUSTOM && dateFrom && dateTo) {
    return {
      dateFrom: startOfDay(dateFrom),
      dateTo: endOfDay(dateTo),
      preset,
    };
  }

  const now = new Date();
  const todayStart = startOfDay(now);
  const todayEnd = endOfDay(now);

  switch (preset) {
    case ReportPeriodPreset.TODAY:
      return { dateFrom: todayStart, dateTo: todayEnd, preset };
    case ReportPeriodPreset.YESTERDAY: {
      const yesterday = new Date(todayStart);
      yesterday.setDate(yesterday.getDate() - 1);
      return {
        dateFrom: startOfDay(yesterday),
        dateTo: endOfDay(yesterday),
        preset,
      };
    }
    case ReportPeriodPreset.LAST_7_DAYS: {
      const from = new Date(todayStart);
      from.setDate(from.getDate() - 6);
      return { dateFrom: from, dateTo: todayEnd, preset };
    }
    case ReportPeriodPreset.LAST_30_DAYS: {
      const from = new Date(todayStart);
      from.setDate(from.getDate() - 29);
      return { dateFrom: from, dateTo: todayEnd, preset };
    }
    case ReportPeriodPreset.LAST_MONTH: {
      const from = new Date(now.getFullYear(), now.getMonth() - 1, 1);
      const to = endOfDay(new Date(now.getFullYear(), now.getMonth(), 0));
      return { dateFrom: from, dateTo: to, preset };
    }
    case ReportPeriodPreset.THIS_MONTH:
    default: {
      const from = new Date(now.getFullYear(), now.getMonth(), 1);
      return { dateFrom: from, dateTo: todayEnd, preset: ReportPeriodPreset.THIS_MONTH };
    }
  }
}

export function eachDayInRange(dateFrom: Date, dateTo: Date): Date[] {
  const days: Date[] = [];
  const cursor = startOfDay(dateFrom);
  const end = startOfDay(dateTo);

  while (cursor <= end) {
    days.push(new Date(cursor));
    cursor.setDate(cursor.getDate() + 1);
  }

  return days;
}

export function formatDayKey(date: Date): string {
  return date.toISOString().slice(0, 10);
}

export function formatDayLabel(date: Date): string {
  return date.toLocaleDateString('en-GB', { day: '2-digit', month: 'short' });
}
