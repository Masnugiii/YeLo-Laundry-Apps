const DEFAULT_LOCAL_CORS_ORIGINS = [
  'http://localhost:3000',
  'http://localhost:3001',
  'http://localhost:5173',
] as const;

/** Always allowed — production Admin Web on Vercel. */
const REQUIRED_PRODUCTION_CORS_ORIGINS = [
  'https://ye-lo-laundry-apps.vercel.app',
] as const;

/**
 * Parse CORS_ORIGINS and always include required production Admin origins.
 * Env may omit Vercel; defaults alone are not enough when Railway sets a
 * localhost-only CORS_ORIGINS override.
 */
export function resolveCorsOrigins(
  raw: string | undefined = process.env.CORS_ORIGINS,
): string[] {
  const fromEnv = (raw ?? '')
    .split(',')
    .map((origin) => origin.trim())
    .filter(Boolean);

  const base = fromEnv.length > 0 ? fromEnv : [...DEFAULT_LOCAL_CORS_ORIGINS];

  return Array.from(
    new Set<string>([...REQUIRED_PRODUCTION_CORS_ORIGINS, ...base]),
  );
}

export default () => ({
  app: {
    name: process.env.APP_NAME ?? 'Yelo Laundry ERP',
    env: process.env.APP_ENV ?? 'development',
    host: process.env.APP_HOST ?? '0.0.0.0',
    port: parseInt(process.env.PORT ?? process.env.APP_PORT ?? '3000', 10),
    apiPrefix: process.env.API_PREFIX ?? 'api/v1',
    corsOrigins: resolveCorsOrigins(process.env.CORS_ORIGINS),
    bodyLimit: process.env.BODY_LIMIT ?? '10mb',
  },
  database: {
    url: process.env.DATABASE_URL,
  },
  jwt: {
    secret: process.env.JWT_SECRET,
    expiresIn: process.env.JWT_EXPIRES_IN ?? '7d',
    refreshSecret: process.env.REFRESH_TOKEN_SECRET,
    refreshExpiresIn: process.env.REFRESH_TOKEN_EXPIRES_IN ?? '30d',
  },
  redis: {
    host: process.env.REDIS_HOST ?? 'localhost',
    port: parseInt(process.env.REDIS_PORT ?? '6379', 10),
  },
  dev: {
    otpPhoneWhitelist: process.env.DEV_OTP_PHONE_WHITELIST,
  },
});
