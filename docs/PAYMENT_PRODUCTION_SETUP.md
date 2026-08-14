# Payment Production Setup

**Status:** EXTERNAL DEPENDENCY — no live payment gateway integrated in Sprint 12  
**Last updated:** 2026-08-10

---

## Supported payment methods (application)

| Method | Scope | Notes |
|--------|-------|-------|
| `YELO_WALLET` | Customer app, staff POS | Internal ledger; no external webhook |
| Bank transfer | Customer checkout | Admin-configured account details (`customer_payment_config`) |
| QRIS | Customer checkout | Admin-configured QR image/payload |
| Cash / staff methods | Staff app | Recorded via finance module |

Wallet top-up uses manual confirmation flow — no automated gateway webhook yet.

---

## Production placeholders (do not commit values)

```env
PAYMENT_PROVIDER=<PROVIDER_NAME>
PAYMENT_MERCHANT_ID=<PRODUCTION_SECRET>
PAYMENT_API_KEY=<PRODUCTION_SECRET>
PAYMENT_SECRET=<PRODUCTION_SECRET>
PAYMENT_WEBHOOK_SECRET=<PRODUCTION_SECRET>
PAYMENT_WEBHOOK_URL=https://api.example.com/api/v1/payments/webhook
PAYMENT_CALLBACK_URL=<CUSTOMER_RETURN_URL>
PAYMENT_RETURN_URL=<CUSTOMER_RETURN_URL>
```

---

## Architecture flow (future gateway)

```
INITIATE (customer/staff creates payment intent)
    → PROVIDER (redirect / VA / QR from gateway)
    → WEBHOOK (provider POST to backend)
    → SIGNATURE VALIDATION (HMAC / provider scheme)
    → IDEMPOTENCY CHECK (payment reference / event id)
    → PAYMENT CONFIRMATION (update Payment + Order)
    → ORDER/WALLET UPDATE (balance, order payment status)
    → NOTIFICATION (payment.success / payment.failed)
```

Current implementation stops at staff/customer `PaymentService.create()` with internal status updates and in-app notifications. **No production webhook endpoint is registered.**

---

## Admin configuration (today)

- Settings → Payment: QRIS and bank transfer details
- Settings → Payment methods: enable/disable methods
- Customer app reads config via `/customer-app/payment-config`

---

## Idempotency (current)

- Duplicate payment references throw `DUPLICATE_PAYMENT` in `PaymentService.create()`.
- Wallet mutations use reference numbers from numbering service.

---

## Production checklist (when provider is available)

1. Obtain merchant approval and sandbox credentials
2. Implement webhook controller with signature validation
3. Store secrets in deployment environment only
4. Register public HTTPS webhook URL
5. Test idempotent replay of webhook events
6. Verify order completion blocked until paid (existing rule)
7. Monitor payment failure rate (see `MONITORING_RUNBOOK.md`)

**Payment production PASS is not claimed in Sprint 12.**
