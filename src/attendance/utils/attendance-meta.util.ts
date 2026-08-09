export interface BreakSession {
  start: string;
  end?: string;
}

export interface AttendanceMeta {
  shiftId?: string;
  checkInPhotoUrl?: string;
  checkOutPhotoUrl?: string;
  checkInNotes?: string;
  checkOutNotes?: string;
  checkInAccuracy?: number;
  checkOutAccuracy?: number;
  breakSessions?: BreakSession[];
  activeBreakStart?: string;
  breakMinutes?: number;
  overtimeMinutes?: number;
  earlyLeaveMinutes?: number;
  displayStatus?: string;
}

const META_PREFIX = '<!--ATTENDANCE_META:';
const META_SUFFIX = '-->';

const DEFAULT_META: AttendanceMeta = {
  breakSessions: [],
  breakMinutes: 0,
  overtimeMinutes: 0,
  earlyLeaveMinutes: 0,
};

export function encodeAttendanceNotes(
  meta: Partial<AttendanceMeta>,
  notes?: string | null,
): string | null {
  const payload: AttendanceMeta = {
    ...DEFAULT_META,
    ...meta,
    breakSessions: meta.breakSessions ?? DEFAULT_META.breakSessions,
  };

  const body = notes?.trim() ?? '';
  const hasMeta = Object.keys(payload).some((key) => {
    const value = payload[key as keyof AttendanceMeta];

    if (Array.isArray(value)) {
      return value.length > 0;
    }

    return value !== undefined && value !== null && value !== 0 && value !== '';
  });

  if (!hasMeta && !body) {
    return null;
  }

  return `${META_PREFIX}${JSON.stringify(payload)}${META_SUFFIX}${body ? `\n${body}` : ''}`;
}

export function decodeAttendanceNotes(stored: string | null | undefined): {
  meta: AttendanceMeta;
  notes: string | null;
} {
  if (!stored?.startsWith(META_PREFIX)) {
    return {
      meta: { ...DEFAULT_META },
      notes: stored ?? null,
    };
  }

  const metaEndIndex = stored.indexOf(META_SUFFIX);

  if (metaEndIndex === -1) {
    return {
      meta: { ...DEFAULT_META },
      notes: stored,
    };
  }

  try {
    const parsed = JSON.parse(
      stored.slice(META_PREFIX.length, metaEndIndex),
    ) as Partial<AttendanceMeta>;

    const body = stored.slice(metaEndIndex + META_SUFFIX.length).trimStart();

    return {
      meta: {
        ...DEFAULT_META,
        ...parsed,
        breakSessions: parsed.breakSessions ?? [],
      },
      notes: body || null,
    };
  } catch {
    return {
      meta: { ...DEFAULT_META },
      notes: stored,
    };
  }
}

export function getActiveBreakStart(meta: AttendanceMeta): Date | null {
  if (!meta.activeBreakStart) {
    return null;
  }

  return new Date(meta.activeBreakStart);
}

export function calculateBreakMinutes(meta: AttendanceMeta): number {
  const completed = (meta.breakSessions ?? []).reduce((total, session) => {
    if (!session.end) {
      return total;
    }

    const duration =
      (new Date(session.end).getTime() - new Date(session.start).getTime()) /
      60000;

    return total + Math.max(0, Math.round(duration));
  }, 0);

  return completed + (meta.breakMinutes ?? 0);
}
