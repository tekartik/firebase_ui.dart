# firebase_ui.dart

Tekartik firebase UI helpers

## Packages

- `packages/firebase_ui_auth`: material auth screens (sign in, sign up, lost
  password, profile, email verification) on the `tekartik_firebase_auth`
  abstraction.
- `packages/firebase_flutter_ui_auth`: same interface using the native
  `firebase_ui_auth` screens.
- `packages/firebase_ui_firestore`: `FirestoreListView`,
  `FirestoreQueryBuilder` and `FirestoreDataTable` on the
  `tekartik_firebase_firestore` abstraction.

## Examples

- `example/ui_auth_sdb_example`: offline auth UI example using
  `tekartik_firebase_auth_sdb`.
- `example/ui_auth_emulator_example`: auth UI (native `firebase_ui_auth`
  screens on web/android/ios/macos, material screens over REST on
  linux/windows) and `FirestoreListView` on the Firebase emulators, with
  firestore rules and a rules test screen (`dart run tool/start_emulator.dart`).

Each package ships agent skills in its `skills/` folder
(`dart run skills@ get`).
