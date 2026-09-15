# Flutter UI auth

Native `firebase_ui_auth` screens (sign in, register, forgot password,
profile, email verification) exposed through the `FirebaseUiAuthService`
interface of `tekartik_firebase_ui_auth`.

## Setup

In your `pubspec.yaml`:

```yaml
  tekartik_firebase_flutter_ui_auth:
    git:
      url: https://github.com/tekartik/firebase_ui.dart
      path: packages/firebase_flutter_ui_auth
    version: '>=0.2.0'
```

## Usage

```dart
// Once, after Firebase.initializeApp
firebaseUiAuthServiceFlutter.configureProviders(
  firebaseAuth: firebaseAuth,
  googleAuthClientId: googleAuthClientId,
);

// Registration can be disabled
const uiAuthService = FirebaseUiAuthServiceFlutter(
  options: FirebaseUiAuthOptions(registerEnabled: false),
);
uiAuthService.authScreen(firebaseAuth: firebaseAuth);
```

See `example/ui_auth_emulator_example` in the repository for a complete app
running on the Firebase emulators, and the `skills/` folder for agent skills
(`dart run skills@ get`).
