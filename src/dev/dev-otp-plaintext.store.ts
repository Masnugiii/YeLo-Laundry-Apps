import { Injectable } from '@nestjs/common';

interface PlaintextEntry {
  code: string;
  expiresAt: number;
}

/**
 * In-memory OTP plaintext cache for local development only.
 * Never persisted; cleared on process restart.
 */
@Injectable()
export class DevOtpPlaintextStore {
  private readonly entries = new Map<string, PlaintextEntry>();

  remember(otpId: string, code: string, expiresAt: Date): void {
    this.entries.set(otpId, {
      code,
      expiresAt: expiresAt.getTime(),
    });
    this.purgeExpired();
  }

  get(otpId: string): string | null {
    const entry = this.entries.get(otpId);
    if (!entry) {
      return null;
    }

    if (Date.now() > entry.expiresAt) {
      this.entries.delete(otpId);
      return null;
    }

    return entry.code;
  }

  private purgeExpired(): void {
    const now = Date.now();
    for (const [otpId, entry] of this.entries.entries()) {
      if (now > entry.expiresAt) {
        this.entries.delete(otpId);
      }
    }
  }
}
