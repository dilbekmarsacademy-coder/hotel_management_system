# LuxeStay — Grand Luxe Hotel Management System

Professional Flutter hotel management application: **Guest app + Admin/Staff operations**.

- **90 distinct professional screens**
- Clean Architecture · Riverpod · GoRouter · Repository pattern
- **Demo mode** (DummyData, no Firebase required)
- **Firebase mode** (Auth, Firestore, Storage, FCM-ready)

---

## Requirements

- Flutter SDK ≥ 3.2
- Dart ≥ 3.2
- Android Studio / Xcode for device builds
- Optional: Firebase project for production data

---

## Quick start (Demo mode)

```bash
cd hotel_management_system
flutter pub get
flutter run
```

Demo mode is the **default**. No Firebase project is required.

### Demo logins (email convention)

| Email contains | Role |
|----------------|------|
| `admin@…` | Admin |
| `manager@…` | Manager |
| `reception@…` | Receptionist |
| `house@…` | Housekeeping |
| `restaurant@…` / `kitchen@…` | Restaurant Staff |
| `maint@…` | Maintenance |
| any other | Guest |

Password: any string ≥ 6 characters (e.g. `password123`).

---

## Project structure

```
lib/
  core/           # theme, constants, domain status machines, errors
  data/
    models/
    repositories/ # interfaces + Dummy implementations
      firebase/   # Firebase implementations
    services/     # Auth, Availability, Storage, Notifications, Bootstrap
    converters/   # Firestore serialization helpers
    dummy_data/
  features/       # Guest + Admin UI screens
  providers/      # Riverpod
  routing/        # GoRouter
```

**Data flow:** UI → Riverpod providers → Repository interface → Dummy **or** Firebase.

---

## Firebase setup

1. Create a Firebase project.
2. Enable **Authentication** (Email/Password, Google).
3. Create **Firestore** and **Storage**.
4. From the app root:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

5. In `lib/core/constants/app_config.dart`:

```dart
static const bool kFirebaseEnabled = true;
static const bool kUseFirebaseData = true;
```

6. Deploy rules and indexes:

```bash
firebase deploy --only firestore:rules,firestore:indexes
```

Files:

- `firestore/firestore.rules`
- `firestore/firestore.indexes.json`

7. **Roles:** set `users/{uid}.role` in Firestore (admin only).  
   Registration always creates **guest**. Never trust client-supplied roles.

---

## Emulator Suite (optional)

```dart
// app_config.dart
static const bool kUseEmulators = true;
```

```bash
firebase emulators:start --only auth,firestore,storage
flutter run
```

---

## Dev seeder

```bash
dart run scripts/seed_firestore.dart --help
```

**DEV only.** Idempotent design (merge by DummyData IDs). Never auto-runs in production.

---

## Tests

```bash
flutter test
```

Coverage includes:

- Availability / date overlap / checkout boundary
- Maintenance blocking
- Pricing & coupon math
- Booking & room status machines

---

## Build

```bash
flutter analyze
flutter test
flutter build apk --debug
```

---

## Production notes

| Concern | Approach |
|---------|----------|
| Double booking | `AvailabilityService` + re-check in `BookingTransactionService`; prefer Cloud Function transaction for atomicity |
| Roles | Firestore `users.role` only; rules block self-elevation |
| Payments | `PaymentProvider` abstraction; client cannot set Paid without trusted path |
| Coupons | Server-side validation + usageCount; do not trust client discount |
| Room/Booking state | `RoomStatusMachine` / `BookingStatusMachine` |
| Secrets | Never embed service-account keys in the Flutter app |

---

## Architecture diagram

```
┌─────────────┐     ┌──────────────┐     ┌─────────────────────┐
│  UI Screens │────▶│   Riverpod   │────▶│ Repository Interface│
└─────────────┘     └──────────────┘     └──────────┬──────────┘
                                                    │
                         ┌──────────────────────────┴──────────┐
                         ▼                                     ▼
                  DummyRepository                      FirebaseRepository
                  (offline demo)                       (production)
```

---

## License

Proprietary — Grand Luxe / LuxeStay demo project.


---

## Cloud Functions (production booking)

Server-side `createBooking` validates pricing, coupons, and availability inside a Firestore transaction.

```bash
cd functions
npm install
npm run build
firebase deploy --only functions
```

Flutter uses `CloudBookingClient`:
- **Demo** → `BookingTransactionService` (local)
- **Firebase** → callable `createBooking`

Client-submitted totals and discounts are **ignored**; the server recalculates.

## Storage rules

```bash
firebase deploy --only storage
```

File: `storage.rules` (image-only, 5 MB max, path-scoped).

## FCM

Requires platform setup (`GoogleService-Info.plist` / `google-services.json`).
`FcmService` no-ops when Firebase is disabled.
