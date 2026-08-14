# OTP Production Setup

**Status:** EXTERNAL DEPENDENCY for SMS/WhatsApp delivery  
**Last updated:** 2026-08-10

---

## Current architecture

| Step | Location | Behavior |
|------|----------|----------|
| Generate OTP | `src/auth/otp/otp.service.ts` | `randomInt(100000, 999999)`, bcrypt-hashed before storage |
| Persist | `OtpRepository` / `otp_codes` table | Purpose (`login` / `register`), expiry, attempt counter |
| Expire | 300 seconds (`OTP_EXPIRY_SECONDS`) | Marked expired on verify if past `expiresAt` |
| Verify | `POST /auth/otp/verify`, `POST /auth/customer/register` | bcrypt compare, max 5 attempts |
| Rate limit | 3 requests / 15 minutes per phone | HTTP 429 |
| Delivery | **Not integrated** | Dev: OTP logged at `debug` level when `APP_ENV !== 'production'` |

---

## Production placeholders

```env
OTP_PROVIDER=<WHATSAPP_OR_SMS_PROVIDER>
OTP_API_KEY=<PRODUCTION_SECRET>
OTP_SENDER=<SENDER_ID_OR_PHONE>
OTP_TEMPLATE_ID=<TEMPLATE_ID_IF_REQUIRED>
OTP_WEBHOOK_SECRET=<IF_PROVIDER_USES_DELIVERY_WEBHOOKS>
WHATSAPP_API_KEY=<PRODUCTION_SECRET>
WHATSAPP_BASE_URL=<PROVIDER_API_URL>
```

---

## Integration point

After OTP generation in `OtpService.sendOtp()`, invoke the provider adapter to deliver the code. **Do not** return plaintext OTP in API responses in production.

---

## Security verification (Sprint 12)

- Plaintext OTP is **never** logged when `APP_ENV=production`.
- OTP stored as bcrypt hash only.
- JWT / refresh tokens are not logged by OTP service.
- Failed verification increments attempts; lockout after 5 tries.

---

## Anti-abuse

- Per-phone rate limiting (existing)
- OTP expiry (existing)
- Attempt cap (existing)
- **NEEDS BUSINESS/LEGAL DECISION:** CAPTCHA, device fingerprinting, IP throttling

---

## Customer flows

1. `POST /auth/otp/send` — login or register purpose
2. `POST /auth/otp/verify` — existing customers
3. `POST /auth/customer/register` — new customers with profile fields

Production sender purchase and template approval remain **EXTERNAL DEPENDENCIES**.
