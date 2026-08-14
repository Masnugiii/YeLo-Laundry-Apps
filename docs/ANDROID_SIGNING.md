# Android Production Signing

**Last updated:** 2026-08-10  
**Applies to:** Staff (`android/`) and Customer (`customer_app/android/`)

---

## Overview

Release builds use **debug signing** when `key.properties` is absent (local development).  
Production store upload requires a **release keystore** configured locally or in CI — never committed to git.

---

## Create a production keystore (owner action)

```bash
keytool -genkey -v \
  -keystore ~/secure/yelo-release.keystore \
  -alias yelo-release \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000
```

Store the keystore outside the repository (password manager + encrypted backup).

---

## Configure `key.properties`

Copy the example file in each Android project:

```bash
# Staff
cp android/key.properties.example android/key.properties

# Customer
cp customer_app/android/key.properties.example customer_app/android/key.properties
```

Edit `key.properties` (placeholders only in example):

```properties
storeFile=/absolute/path/to/yelo-release.keystore
storePassword=<PRODUCTION_SECRET>
keyAlias=yelo-release
keyPassword=<PRODUCTION_SECRET>
```

---

## Git safety

Verified gitignored:

- `android/key.properties` (via `android/.gitignore`)
- `customer_app/android/key.properties` (via `customer_app/android/.gitignore`)
- `**/*.keystore`, `**/*.jks`

**Never commit** keystore files or passwords.

---

## Build release AAB

### Staff

```bash
flutter build appbundle --release \
  --dart-define=API_BASE_URL=https://api.example.com/api/v1
```

### Customer

```bash
cd customer_app
flutter build appbundle --release \
  --dart-define=API_BASE_URL=https://api.example.com/api/v1
```

Without `key.properties`, release AAB is signed with debug keys (local verification only).

---

## CI/CD notes

- Inject `key.properties` from secret store at build time
- Or base64-decode keystore in CI and write to ephemeral path
- Restrict secret access to release pipeline role

---

## Key rotation

1. Generate new keystore / upload key (Play App Signing)
2. Update `key.properties` in secure storage
3. Rebuild and upload new AAB
4. Document rotation date in change log

Google Play App Signing allows upload key rotation; follow Play Console guidance.

---

## Status

| Item | Sprint 13 |
|------|-----------|
| `key.properties.example` | READY (Staff + Customer) |
| Gradle reads signing safely | READY |
| Debug builds without keystore | PASS |
| Production keystore on disk | **OWNER ACTION REQUIRED** |
