import { Injectable } from '@nestjs/common';
import { AuditLogService } from '../../admin/audit-log.service';

const SENSITIVE_KEY_PATTERN =
  /password|token|secret|credential|api[_-]?key|authorization/i;

@Injectable()
export class MasterDataAuditService {
  constructor(private readonly auditLogService: AuditLogService) {}

  async logConfigUpdated(params: {
    employeeId: string;
    module: string;
    referenceId?: string;
    before: unknown;
    after: unknown;
  }): Promise<void> {
    await this.auditLogService.record({
      employeeId: params.employeeId,
      module: params.module,
      action: 'config_updated',
      referenceId: params.referenceId,
      description: JSON.stringify({
        before: this.sanitizeMetadata(params.before),
        after: this.sanitizeMetadata(params.after),
      }),
    });
  }

  async logChange(params: {
    employeeId: string;
    module: string;
    action: string;
    referenceId?: string;
    before?: unknown;
    after?: unknown;
  }): Promise<void> {
    await this.auditLogService.record({
      employeeId: params.employeeId,
      module: params.module,
      action: params.action,
      referenceId: params.referenceId,
      description: JSON.stringify({
        ...(params.before !== undefined && {
          before: this.sanitizeMetadata(params.before),
        }),
        ...(params.after !== undefined && {
          after: this.sanitizeMetadata(params.after),
        }),
      }),
    });
  }

  private sanitizeMetadata(value: unknown): unknown {
    if (value === null || value === undefined) {
      return value;
    }

    if (Array.isArray(value)) {
      return value.map((item) => this.sanitizeMetadata(item));
    }

    if (typeof value === 'object') {
      const record = value as Record<string, unknown>;
      const sanitized: Record<string, unknown> = {};

      for (const [key, nested] of Object.entries(record)) {
        if (SENSITIVE_KEY_PATTERN.test(key)) {
          sanitized[key] = '[REDACTED]';
          continue;
        }
        sanitized[key] = this.sanitizeMetadata(nested);
      }

      return sanitized;
    }

    return value;
  }
}
