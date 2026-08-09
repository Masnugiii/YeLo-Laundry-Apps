export type JobType = 'PICKUP' | 'DELIVERY';

export type ApiPickupStatus =
  | 'REQUESTED'
  | 'ASSIGNED'
  | 'ON_THE_WAY'
  | 'ARRIVED'
  | 'PICKED_UP'
  | 'RECEIVED';

export type ApiDeliveryStatus =
  | 'WAITING'
  | 'ASSIGNED'
  | 'ON_THE_WAY'
  | 'ARRIVED'
  | 'DELIVERED'
  | 'FAILED';

export interface TrackingPoint {
  latitude: number;
  longitude: number;
  speed?: number;
  recordedAt: string;
}

export interface JobProof {
  photoUrl?: string;
  receiverName?: string;
  notes?: string;
  completedAt?: string;
  employeeId?: string;
}

export interface JobRoute {
  estimatedDistanceKm?: number;
  estimatedDurationMinutes?: number;
  tripStartedAt?: string;
  tripEndedAt?: string;
}

export interface JobMeta {
  assignedByEmployeeId?: string;
  displayStatus?: string;
  proof?: JobProof;
  route?: JobRoute;
  tracking?: TrackingPoint[];
}

const META_PREFIX = '<!--JOB_META:';
const META_SUFFIX = '-->';

export function encodeJobNotes(
  meta: JobMeta,
  notes?: string | null,
): string | null {
  const body = notes?.trim() ?? '';

  if (!Object.keys(meta).length && !body) {
    return null;
  }

  return `${META_PREFIX}${JSON.stringify(meta)}${META_SUFFIX}${body ? `\n${body}` : ''}`;
}

export function decodeJobNotes(stored: string | null | undefined): {
  meta: JobMeta;
  notes: string | null;
} {
  if (!stored?.startsWith(META_PREFIX)) {
    return { meta: {}, notes: stored ?? null };
  }

  const metaEndIndex = stored.indexOf(META_SUFFIX);

  if (metaEndIndex === -1) {
    return { meta: {}, notes: stored };
  }

  try {
    const parsed = JSON.parse(
      stored.slice(META_PREFIX.length, metaEndIndex),
    ) as JobMeta;
    const body = stored.slice(metaEndIndex + META_SUFFIX.length).trimStart();

    return {
      meta: {
        ...parsed,
        tracking: parsed.tracking ?? [],
      },
      notes: body || null,
    };
  } catch {
    return { meta: {}, notes: stored };
  }
}

export function appendTrackingPoint(
  meta: JobMeta,
  point: TrackingPoint,
): JobMeta {
  return {
    ...meta,
    tracking: [...(meta.tracking ?? []), point],
  };
}
