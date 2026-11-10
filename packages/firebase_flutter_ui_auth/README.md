# tekartik_firebase_flutter_ui_auth

The native Firebase UI auth screens (`firebase_ui_auth`: sign in, register,
forgot password, profile, email verification, Google sign in with
`firebase_ui_oauth_google`) behind the `FirebaseUiAuthService` interface of
`tekartik_firebase_ui_auth`. App code builds its screens through the service:
`FirebaseUiAuthServiceFlutter` (native Firebase) in production,
`FirebaseUiAuthServiceBasic` (pure Flutter screens, any `FirebaseAuth`:
local sdb/sembast, REST) elsewhere.

## Getting started

Not on pub.dev, add it as a git dependency (with the flutter auth):

```yaml
dependencies:
  tekartik_firebase_flutter_ui_auth:
    git:
      url: https://github.com/tekartik/firebase_ui.dart
      path: packages/firebase_flutter_ui_auth
  tekartik_firebase_ui_auth:
    git:
      url: https://github.com/tekartik/firebase_ui.dart
      path: packages/firebase_ui_auth
  tekartik_firebase_auth_flutter:
    git:
      url: https://github.com/tekartik/firebase_flutter
      path: auth_flutter
  tekartik_firebase_flutter:
    git:
      url: https://github.com/tekartik/firebase_flutter
      path: firebase_flutter
  firebase_core: ">=4.0.0"
  firebase_ui_localizations: ">=1.7.0"
  flutter_localizations:
    sdk: flutter
```

```dart
import 'package:firebase_core/firebase_core.dart' as native;
import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tekartik_firebase_auth_flutter/auth_flutter.dart';
import 'package:tekartik_firebase_flutter/firebase_flutter.dart';
import 'package:tekartik_firebase_flutter_ui_auth/ui_auth.dart';
import 'package:tekartik_firebase_ui_auth/ui_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // With the options of your project (flutterfire configure).
  await native.Firebase.initializeApp();
  var auth = firebaseAuthServiceFlutter.auth(firebaseFlutter.app());
  // Email/password; pass googleAuthClientId to add Google.
  firebaseUiAuthServiceFlutter.configureProviders(firebaseAuth: auth);
  runApp(
    MaterialApp(
      localizationsDelegates: const [
        FirebaseUiAuthServiceBasicLocalizations.delegate,
        FirebaseUILocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales:
          FirebaseUiAuthServiceBasicLocalizations.supportedLocales,
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      firebaseUiAuthServiceFlutter.authScreen(firebaseAuth: auth),
                ),
              ),
              child: const Text('Account'),
            ),
          ),
        ),
      ),
    ),
  );
}
```

`authScreen()` is the shared account screen of `tekartik_firebase_ui_auth`
(welcome, sign in / create account, account details); it opens the native
screens of this package. `loginScreen()`, `registerScreen()`,
`lostPasswordScreen()`, `profileScreen()` and `emailVerificationScreen()` are
the native screens alone: sign in and register pop once signed in with an
account, profile and email verification on sign out.

## Platforms

The platforms of `firebase_auth` and `firebase_ui_auth`: Android, iOS, macOS
and the web. Not Linux and Windows (no native Firebase Auth there): use
`FirebaseUiAuthServiceBasic` with a REST or local `FirebaseAuth` (the
repository example `example/ui_auth_emulator_example` switches on the
platform).

## What to know

* The `FirebaseAuth` must come from `tekartik_firebase_auth_flutter` (the
  screens use its `nativeInstance`).
* `configureProviders` is lazy: the providers are configured by the first
  auth screen, so Google Sign-In does not start (nor set its `g_state` cookie
  on the web) before the user opens one. Do not build `firebase_ui_auth`
  screens directly, go through the service.
* Options: `FirebaseUiAuthServiceFlutter(options:
  FirebaseUiAuthOptions(registerEnabled: false))` hides the register switch
  of the sign in screen and the create account button of the auth screen.
* "Sign in and join" flows: `authScreen(authContinue: ...)`, see the
  `tekartik_firebase_ui_auth` README.
* Web, GDPR: `google_sign_in_web` still loads Google's script
  (`https://accounts.google.com/gsi/client`) at startup, before `main`: no
  cookie, but the request reaches Google, so list it in the app's privacy
  policy.
* Emulators: `auth.nativeInstance.useAuthEmulator(host, port,
  automaticHostMapping: true)` right after creating the auth, see
  `example/ui_auth_emulator_example` in the repository.

See the `skills/` folder for agent skills (`dart run skills@ get`).
