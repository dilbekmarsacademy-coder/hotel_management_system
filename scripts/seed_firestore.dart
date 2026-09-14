/// DEV-ONLY Firestore seeder.
///
/// Usage (with Firebase configured + emulators or a DEV project):
///   dart run scripts/seed_firestore.dart
///
/// NEVER run against production without explicit confirmation.
/// Does not auto-run on app start.
///
/// This script is structured for manual execution. Import DummyData
/// patterns and write documents with merge:true to avoid duplicates
/// when re-run (idempotent by fixed document IDs).

// ignore_for_file: avoid_print

void main(List<String> args) {
  print('''
╔══════════════════════════════════════════════════════════╗
║  LuxeStay Firestore Seeder (DEV ONLY)                    ║
╠══════════════════════════════════════════════════════════╣
║  Collections to seed:                                    ║
║   - rooms                                                ║
║   - services                                             ║
║   - restaurantMenu                                       ║
║   - promotions                                           ║
║   - coupons                                              ║
║   - staff (metadata only, no Auth accounts)              ║
║                                                          ║
║  Prerequisites:                                          ║
║   1. flutterfire configure                               ║
║   2. AppConfig.kFirebaseEnabled = true                   ║
║   3. Prefer Firebase Emulator Suite                      ║
║                                                          ║
║  Implementation note:                                    ║
║  Wire Firebase.initializeApp + DummyData export here     ║
║  when running against a real/emulator backend.           ║
║  Document IDs should match DummyData IDs for merge.      ║
╚══════════════════════════════════════════════════════════╝
''');

  if (args.contains('--help')) {
    print('Flags: --help | --dry-run');
    return;
  }

  final dryRun = args.contains('--dry-run');
  print(dryRun
      ? '[dry-run] Would seed rooms, services, menu, promotions, coupons.'
      : '''
To implement live seeding:
  1. Import firebase_core, cloud_firestore, DummyData
  2. Initialize Firebase
  3. For each DummyData.rooms → rooms.doc(id).set(toJson(), SetOptions(merge: true))
  4. Repeat for services, menuItems, promotions, coupons
  5. Log counts written
''');
}
