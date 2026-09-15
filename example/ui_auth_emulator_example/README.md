# ui_auth_emulator_example

Example of `tekartik_firebase_ui_auth`, `tekartik_firebase_flutter_ui_auth`
and `tekartik_firebase_ui_firestore` running against the local Firebase
emulators with a placeholder project (`demo-placeholder-ui-auth`, no
credentials needed).

| Platform | Backend | Auth screens |
|---|---|---|
| web, android, ios, macos | native Firebase (`firebase_core`, `firebase_auth`, `cloud_firestore`) | native `firebase_ui_auth` through `FirebaseUiAuthServiceFlutter` |
| linux, windows | REST (`tekartik_firebase_rest`) | material screens of `tekartik_firebase_ui_auth` |

## Run

Start the emulators (needs the firebase CLI and java):

```bash
dart run tool/start_emulator.dart
```

The emulator UI is at http://localhost:4000. Then, in another terminal:

```bash
flutter run -d chrome    # dart run tool/run_chrome.dart
flutter run -d linux     # dart run tool/run_linux.dart (REST backend)
flutter run -d android   # dart run tool/run_android.dart
```

On the Android emulator `localhost` is mapped to `10.0.2.2` automatically and
cleartext HTTP is enabled in the manifest. ios/macos were generated but not
built here (macOS has the network client entitlement).

## What it shows

- Home: backend in use, current user, "Sign in as test user"
  (`test.user@example.com` / `test1234`, created on first use).
- Authentication / login screens of the ui auth service.
- Public items: `FirestoreListView` on the `public_items` collection with an
  "Add item" button (signed-in users only).
- Rules test: runs `get`, `list`, `create` and `put` on `public_items`,
  `users/<uid>/items`, `users/other_user/items` and `admin_items` and shows
  what `emulator/firestore.rules` allows for the current user (signed in or
  not). `admin_items` is only writable by the hardcoded test user.

## Tests

- `flutter test test/widget_test.dart`: widget test on in-memory backends
  (rules not enforced).
- `flutter test test/rules_emulator_test.dart`: checks the rules through the
  REST backend; skipped unless the emulators are running.
