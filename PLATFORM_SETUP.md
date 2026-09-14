# Platform & Release Setup

This repository is a **source-focused export**. `android/` and `ios/` may be absent until generated locally.

## 1. Generate platform folders (once)

From the project root (preserves existing `lib/`, `assets/`, `pubspec.yaml`):

```bash
flutter create . --project-name hotel_management_system --org com.grandluxe
```

If Flutter asks about overwriting files, keep existing `lib/`, `pubspec.yaml`, and `analysis_options.yaml`.

## 2. Recommended Android settings (after generate)

| Setting | Value |
|---------|--------|
| applicationId | `com.grandluxe.hotel` |
| namespace | `com.grandluxe.hotel` |
| minSdk | 23+ (Firebase / messaging) |
| targetSdk / compileSdk | current Flutter defaults |
| versionName / versionCode | from `pubspec.yaml` `1.0.0+1` |

Permissions (AndroidManifest):
- `INTERNET`
- `POST_NOTIFICATIONS` (API 33+)

Do **not** commit `key.properties`, `*.jks`, or `google-services.json` if it contains project-specific secrets you treat as private (client Firebase config is often public; still prefer not committing service-account JSON).

## 3. Recommended iOS settings

| Setting | Value |
|---------|--------|
| Bundle ID | `com.grandluxe.hotel` |
| Display name | LuxeStay |
| Deployment target | iOS 13+ |

Add URL schemes for Google Sign-In when configured.
Notification capability via Xcode when enabling FCM.

## 4. Firebase

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

Then in `lib/core/constants/app_config.dart`:

```dart
static const bool kFirebaseEnabled = true;
static const bool kUseFirebaseData = true;
```

Deploy:

```bash
firebase deploy --only firestore:rules,firestore:indexes,storage
cd functions && npm install && npm run build
firebase deploy --only functions
```

## 5. Local validation

```bash
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter build apk --debug
```

Release (after local keystore):

```bash
flutter build apk --release
flutter build appbundle --release
```

## 6. Signing

Create keystore **locally only**. Never commit it.
