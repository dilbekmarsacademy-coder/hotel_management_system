# Release Checklist — LuxeStay

## A. Completed in repository

- [x] 90 distinct screens
- [x] Clean Architecture + Riverpod + GoRouter
- [x] Demo mode (DummyData) + Firebase mode flags
- [x] Auth abstraction, repositories, Cloud Function createBooking
- [x] Server-side pricing & coupon validation
- [x] Firestore / Storage rules + indexes
- [x] Status machines (booking / room)
- [x] PaymentProvider abstraction (Mock = demo only)
- [x] AppLogger, CrashReporter, AsyncStateView
- [x] CI workflow (`.github/workflows/ci.yml`)
- [x] GoRouter expanded for guest + admin modules
- [x] Admin More / Guest Explore dead buttons fixed
- [x] DummyData coupons + promotions for Demo lists
- [x] pubspec: removed missing local font files (uses google_fonts)
- [x] `.gitignore` for secrets and keystores
- [x] `PLATFORM_SETUP.md`

## B. Requires local Flutter SDK

```bash
cd hotel_management_system
flutter create . --project-name hotel_management_system --org com.grandluxe
# Keep existing lib/, pubspec.yaml, analysis_options.yaml when prompted

flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter build apk --debug
```

## C. Requires Firebase project

```bash
flutterfire configure
# Set AppConfig.kFirebaseEnabled = true and kUseFirebaseData = true

firebase deploy --only firestore:rules,firestore:indexes,storage
cd functions && npm install && npm run build && firebase deploy --only functions
```

## D. Requires physical device QA

- Guest booking + restaurant + services journeys
- Admin / Reception / HK / Maintenance workflows
- Offline / slow network behavior
- Rotation / lifecycle

## E. Requires store credentials / signing

- Android keystore (local only — never commit)
- Play Store / App Store accounts
- Optional Crashlytics/Sentry behind CrashReporter
- FCM platform files (`google-services.json` / `GoogleService-Info.plist`)
