# UI auth

Email/password authentication screens for Flutter built on the
`tekartik_firebase_auth` abstraction: sign in, sign up (optional), lost
password, profile and email verification. Works with any backend (native
Flutter, REST, local sdb/sembast). English and French included.

## Setup

In your `pubspec.yaml`:

```yaml
  tekartik_firebase_ui_auth:
    git:
      url: https://github.com/tekartik/firebase_ui.dart
      path: packages/firebase_ui_auth
    version: '>=0.2.0'
```

Add the localization delegate to your `MaterialApp`:

```dart
MaterialApp(
  localizationsDelegates: const [
    FirebaseUiAuthServiceBasicLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: FirebaseUiAuthServiceBasicLocalizations.supportedLocales,
  ...
)
```

## Usage

```dart
// Default service (registration and lost password enabled)
var uiAuthService = firebaseUiAuthServiceBasic;

// Or customize the features
const uiAuthService = FirebaseUiAuthServiceBasic(
  options: FirebaseUiAuthOptions(registerEnabled: false),
);

Navigator.of(context).push(
  MaterialPageRoute<void>(
    builder: (_) => uiAuthService.authScreen(firebaseAuth: firebaseAuth),
  ),
);
```

Screens: `authScreen`, `loginScreen`, `registerScreen`, `lostPasswordScreen`,
`profileScreen`, `emailVerificationScreen`.

The design follows the app `ColorScheme` (use
`ThemeData(colorSchemeSeed: Color(0xFF5B4FE9))` for the reference look).

See `example/ui_auth_sdb_example` in the repository for a complete offline
example using `tekartik_firebase_auth_sdb`, and the `skills/` folder for
agent skills (`dart run skills@ get`).
