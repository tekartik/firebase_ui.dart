---
name: tekartik-firebase-flutter-ui-auth-setup
description: >-
  Use when wiring the native Firebase UI auth screens (firebase_ui_auth
  SignInScreen, RegisterScreen, ForgotPasswordScreen, ProfileScreen) into a
  Flutter app through tekartik_firebase_flutter_ui_auth: provider
  configuration, FirebaseUiAuthServiceFlutter, options and localization.
---

# tekartik_firebase_flutter_ui_auth setup

Adapter exposing the official `firebase_ui_auth` / `firebase_ui_oauth_google`
screens behind the `FirebaseUiAuthService` interface of
`tekartik_firebase_ui_auth`, so app code can switch between the native
screens (production) and the pure Flutter screens (local/offline backends)
without changes.

## Guidelines

* Only use this package with a `FirebaseAuth` created by
  `tekartik_firebase_auth_flutter` (it needs `nativeInstance`). For local
  sdb/sembast/REST backends use `FirebaseUiAuthServiceBasic` from
  `tekartik_firebase_ui_auth` instead.
* Call `firebaseUiAuthServiceFlutter.configureProviders(...)` once, after
  `Firebase.initializeApp` and before showing any screen. Pass
  `googleAuthClientId` to add Google sign-in, `noEmailPassword: true` to drop
  the email provider.
* Keep a single `FirebaseUiAuthService` variable in the app (for example
  `globalAuthFlutterUiService`) assigned to `firebaseUiAuthServiceFlutter`
  (native) or `firebaseUiAuthServiceBasic` (local) depending on the flavor,
  and build every screen through it.
* Use `FirebaseUiAuthServiceFlutter(options: FirebaseUiAuthOptions(...))`
  to customize: `registerEnabled: false` hides the native "Register" switch
  of the sign-in screen and the create account button of the auth screen.
* `authScreen()` is the shared material auth screen (welcome / account
  details) from `tekartik_firebase_ui_auth`; `loginScreen()`,
  `registerScreen()`, `lostPasswordScreen()`, `profileScreen()` and
  `emailVerificationScreen()` are the native screens. They pop by themselves
  on sign-in / sign-out.
* Add both localization delegates to the `MaterialApp`:
  `FirebaseUiAuthServiceBasicLocalizations.delegate` (auth screen) and
  `FirebaseUILocalizations.delegate` from `firebase_ui_localizations`
  (native screens), plus the global material delegates.
* Do not import `firebase_ui_auth` screens directly in app code; go through
  the service so the local flavor keeps working.

## Examples

### Initialization

```dart
import 'package:firebase_core/firebase_core.dart' as native;
import 'package:flutter/material.dart';
import 'package:tekartik_firebase_auth_flutter/auth_flutter.dart';
import 'package:tekartik_firebase_flutter/firebase_flutter.dart';
import 'package:tekartik_firebase_flutter_ui_auth/ui_auth.dart';
import 'package:tekartik_firebase_ui_auth/ui_auth.dart';

late FirebaseAuth globalFirebaseAuth;
FirebaseUiAuthService globalAuthFlutterUiService = firebaseUiAuthServiceFlutter;

Future<void> initFirebase() async {
  await native.Firebase.initializeApp();
  var app = firebaseFlutter.app();
  globalFirebaseAuth = authServiceFlutter.auth(app);
  globalAuthFlutterUiService = const FirebaseUiAuthServiceFlutter(
    options: FirebaseUiAuthOptions(registerEnabled: false),
  );
  (globalAuthFlutterUiService as FirebaseUiAuthServiceFlutter)
      .configureProviders(
        firebaseAuth: globalFirebaseAuth,
        googleAuthClientId: 'xxx.apps.googleusercontent.com',
      );
}

Future<void> openAuth(BuildContext context) => Navigator.of(context).push(
  MaterialPageRoute<void>(
    builder: (_) =>
        globalAuthFlutterUiService.authScreen(firebaseAuth: globalFirebaseAuth),
  ),
);
```

### Localization

```dart
import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tekartik_firebase_ui_auth/ui_auth.dart';

const localizationsDelegates = [
  FirebaseUiAuthServiceBasicLocalizations.delegate,
  FirebaseUILocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];
```
