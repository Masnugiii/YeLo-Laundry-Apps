import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../database/prisma/prisma.service';
import {
  DEFAULT_DOCUMENT_RULES,
  DOCUMENT_COMPRESSION_MODES,
  DOCUMENT_RULES_KEY,
  DocumentCompressionMode,
  DocumentRules,
} from '../types/document-rules.types';

@Injectable()
export class DocumentRulesService {
  constructor(private readonly prisma: PrismaService) {}

  async getRules(): Promise<DocumentRules> {
    const setting = await this.prisma.systemSetting.findUnique({
      where: { settingKey: DOCUMENT_RULES_KEY },
      select: { settingValue: true },
    });

    if (!setting) {
      return { ...DEFAULT_DOCUMENT_RULES };
    }

    return this.normalize(JSON.parse(setting.settingValue) as Partial<DocumentRules>);
  }

  async updateRules(dto: Partial<DocumentRules>): Promise<DocumentRules> {
    const current = await this.getRules();
    const next = this.normalize({ ...current, ...dto });

    await this.prisma.systemSetting.upsert({
      where: { settingKey: DOCUMENT_RULES_KEY },
      create: {
        settingKey: DOCUMENT_RULES_KEY,
        settingValue: JSON.stringify(next),
        description: 'Document upload rules',
      },
      update: { settingValue: JSON.stringify(next) },
    });

    return next;
  }

  private normalize(input: Partial<DocumentRules>): DocumentRules {
    const compressionMode = DOCUMENT_COMPRESSION_MODES.includes(
      input.compressionMode as DocumentCompressionMode,
    )
      ? (input.compressionMode as DocumentCompressionMode)
      : DEFAULT_DOCUMENT_RULES.compressionMode;

    return {
      maxFileSizeBytes:
        typeof input.maxFileSizeBytes === 'number' &&
        input.maxFileSizeBytes > 0
          ? input.maxFileSizeBytes
          : DEFAULT_DOCUMENT_RULES.maxFileSizeBytes,
      allowedMimeTypes:
        Array.isArray(input.allowedMimeTypes) &&
        input.allowedMimeTypes.length > 0
          ? input.allowedMimeTypes
          : [...DEFAULT_DOCUMENT_RULES.allowedMimeTypes],
      compressionMode,
      ocrEnabled:
        typeof input.ocrEnabled === 'boolean'
          ? input.ocrEnabled
          : DEFAULT_DOCUMENT_RULES.ocrEnabled,
    };
  }
}
