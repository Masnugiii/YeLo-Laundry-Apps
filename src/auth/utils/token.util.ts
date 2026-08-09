import { randomBytes } from 'crypto';

const DURATION_MULTIPLIERS: Record<string, number> = {
  s: 1000,
  m: 60_000,
  h: 3_600_000,
  d: 86_400_000,
};

export function parseDurationToMs(duration: string): number {
  const match = duration.match(/^(\d+)([smhd])$/);
  if (!match) {
    return 30 * 86_400_000;
  }

  const value = Number.parseInt(match[1], 10);
  const unit = match[2];

  return value * (DURATION_MULTIPLIERS[unit] ?? 86_400_000);
}

export function generateRefreshToken(sessionId: string): string {
  const secret = randomBytes(32).toString('hex');
  return `${sessionId}.${secret}`;
}

export function extractSessionId(refreshToken: string): string | null {
  const dotIndex = refreshToken.indexOf('.');
  if (dotIndex === -1) {
    return null;
  }

  return refreshToken.slice(0, dotIndex);
}
