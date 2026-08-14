export default () => ({
  app: {
    name: process.env.APP_NAME ?? 'Yelo Laundry ERP',
    env: process.env.APP_ENV ?? 'development',
    host: process.env.APP_HOST ?? '0.0.0.0',
    port: parseInt(process.env.APP_PORT ?? '3000', 10),
    apiPrefix: process.env.API_PREFIX ?? 'api/v1',
    corsOrigins: (process.env.CORS_ORIGINS ??
      'http://localhost:3000,http://localhost:3001,http://localhost:5173')
      .split(',')
      .map((origin) => origin.trim())
      .filter(Boolean),
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
