export const DOCUMENT_RULES_KEY = 'documents.rules';

export const DOCUMENT_COMPRESSION_MODES = ['original', 'compress'] as const;
export type DocumentCompressionMode =
  (typeof DOCUMENT_COMPRESSION_MODES)[number];

export const DEFAULT_ALLOWED_MIME_TYPES = [
  'image/jpeg',
  'image/png',
  'application/pdf',
] as const;

export const DEFAULT_MAX_FILE_SIZE_BYTES = 10 * 1024 * 1024;

export interface DocumentRules {
  maxFileSizeBytes: number;
  allowedMimeTypes: string[];
  compressionMode: DocumentCompressionMode;
  ocrEnabled: boolean;
}

export const DEFAULT_DOCUMENT_RULES: DocumentRules = {
  maxFileSizeBytes: DEFAULT_MAX_FILE_SIZE_BYTES,
  allowedMimeTypes: [...DEFAULT_ALLOWED_MIME_TYPES],
  compressionMode: 'original',
  ocrEnabled: false,
};
