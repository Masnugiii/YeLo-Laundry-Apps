import { BadRequestException } from '@nestjs/common';
import { DocumentRules } from '../types/document-rules.types';

export interface DocumentUploadValidationInput {
  mimeType: string;
  fileSizeBytes: number;
}

export interface DocumentUploadValidationResult {
  valid: boolean;
  errors: string[];
}

export function validateDocumentUpload(
  rules: DocumentRules,
  input: DocumentUploadValidationInput,
): DocumentUploadValidationResult {
  const errors: string[] = [];

  if (input.fileSizeBytes > rules.maxFileSizeBytes) {
    errors.push(
      `File size ${input.fileSizeBytes} exceeds maximum ${rules.maxFileSizeBytes} bytes`,
    );
  }

  if (!rules.allowedMimeTypes.includes(input.mimeType)) {
    errors.push(`MIME type ${input.mimeType} is not allowed`);
  }

  return {
    valid: errors.length === 0,
    errors,
  };
}

export function assertValidDocumentUpload(
  rules: DocumentRules,
  input: DocumentUploadValidationInput,
): void {
  const result = validateDocumentUpload(rules, input);
  if (!result.valid) {
    throw new BadRequestException({
      message: 'Document upload validation failed',
      errors: result.errors,
    });
  }
}
