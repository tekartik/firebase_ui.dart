# ui_auth_sdb_example

Example of `tekartik_firebase_ui_auth` (email/password login, registration,
lost password and profile screens) running fully offline on a local
`tekartik_firebase_auth_sdb` backend.

Users are stored in a local sdb database (IndexedDB on the web, sembast
elsewhere) so you can create an account, sign out and sign in again.

The platform folders are not committed: after a fresh clone run
`dart run tool/create_platforms.dart` (it runs `flutter create` for web and
linux), then:

```bash
flutter run -d chrome
flutter run -d linux
```

The home screen lets you toggle the registration and lost password features
(`FirebaseUiAuthOptions`) before opening the auth screens.
