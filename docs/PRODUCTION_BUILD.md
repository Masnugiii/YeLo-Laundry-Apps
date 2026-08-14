# Production Build Guide

**Project:** Yelo Laundry ERP  
**Last updated:** 2026-08-10

---

## Backend

```bash
npm ci
npx prisma migrate deploy
npm run build
npm run start:prod
```

Health check: `GET /health` (outside API prefix).

---

## Admin Web

Set environment before build:

```bash
export NEXT_PUBLIC_API_BASE_URL=https://api.example.com/api/v1
cd admin-web
npm ci
npm run build
npm run start
```

Do **not** ship production with the default `http://localhost:3000/api/v1`.

---

## Customer Android (release AAB)

```bash
cd customer_app
flutter pub get
flutter build appbundle --release \
  --dart-define=API_BASE_URL=https://api.example.com/api/v1
```

- **Application ID:** `com.yelolaundry.yelo_laundry_customer`
- **Output:** `customer_app/build/app/outputs/bundle/release/app-release.aab`
- Configure release signing in `android/app/build.gradle.kts` before store upload (currently debug signing for local release builds).
- **Google Maps:** set `google.maps.api.key` in `android/local.properties` or `GOOGLE_MAPS_API_KEY` env.

### Customer Android (debug smoke)

```bash
flutter build apk --debug
```

---

## Staff Android (release AAB)

```bash
flutter pub get
flutter build appbundle --release \
  --dart-define=API_BASE_URL=https://api.example.com/api/v1
```

- **Application ID (current):** `com.example.yelo_laundry_erp` — change to production package name before public/private store listing.
- **Output:** `build/app/outputs/bundle/release/app-release.aab`

---

## Customer iOS (release)

```bash
cd customer_app
flutter pub get
flutter build ipa --release \
  --dart-define=API_BASE_URL=https://api.example.com/api/v1
```

- **Display name:** Yelo Laundry Customer
- Configure signing in Xcode / Apple Developer account (**EXTERNAL DEPENDENCY**).
- Review `ios/Runner/Info.plist` for location/maps usage descriptions.

---

## Staff iOS (release)

```bash
flutter pub get
flutter build ipa --release \
  --dart-define=API_BASE_URL=https://api.example.com/api/v1
```

Private / enterprise distribution per organization Apple setup (**EXTERNAL DEPENDENCY**).

---

## Sprint 12 verification (local)

| Target | Command | Result |
|--------|---------|--------|
| Backend | `npm run build` | PASS |
| Backend tests | `npm test` | 81/81 PASS |
| Admin | `npm run build` | PASS |
| Customer | `flutter analyze` | 0 errors (info/warnings only) |
| Customer | `flutter test` | PASS |
| Customer | `flutter build apk --debug` | PASS |
| Customer | `flutter build appbundle --release` | PASS |
| Staff | `flutter analyze` | 0 errors (info/warnings only) |
| Staff | `flutter test` | PASS |
| Staff | `flutter build apk --debug` | PASS |
| Staff | `flutter build appbundle --release` | PASS |

Replace `https://api.example.com` with the real production API URL at deploy time.
