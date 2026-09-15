---
name: tekartik-firebase-ui-auth-screens
description: >-
  Use when adding sign-in, sign-up (register), lost password, profile or
  email verification screens to a Flutter app with tekartik_firebase_ui_auth:
  FirebaseUiAuthService, FirebaseUiAuthOptions, localization delegates,
  theming and navigation between the screens.
---

# tekartik_firebase_ui_auth screens

Material screens (email/password) built on the `tekartik_firebase_auth`
abstraction. They work with any `FirebaseAuth` backend: native Flutter
(`tekartik_firebase_auth_flutter`), REST, or the local sdb/sembast backends
used for tests and offline apps.

## Guidelines

* Import only `package:tekartik_firebase_ui_auth/ui_auth.dart`. It re-exports
  `package:tekartik_firebase_auth/auth.dart` (`FirebaseAuth`, `User`, ...).
* Always add `FirebaseUiAuthServiceBasicLocalizations.delegate` to the
  `localizationsDelegates` of your `MaterialApp`, together with the
  `GlobalMaterialLocalizations`, `GlobalWidgetsLocalizations` and
  `GlobalCupertinoLocalizations` delegates. English and French are supported
  (`FirebaseUiAuthServiceBasicLocalizations.supportedLocales`). Without the
  delegate the screens fall back to English.
* Build screens through a `FirebaseUiAuthService`, never by instantiating the
  screen widgets directly. Use the `firebaseUiAuthServiceBasic` constant, or
  `FirebaseUiAuthServiceBasic(options: ...)` to customize the features.
* Prefer passing `firebaseAuth:` explicitly to every screen builder. When
  omitted, `FirebaseAuth.instance` (the default app) is used.
* Push the returned widget with `Navigator.push`; the screens are full
  `Scaffold`s and manage their own navigation:
  * `authScreen()` is the entry point: welcome page when signed out (sign in,
    optional create account), user header + account details + logout when
    signed in.
  * `loginScreen()` pops with the signed-in `User` once the sign-in succeeds
    and links to the register and lost password screens.
  * `registerScreen()` pops once the account is created (the user is signed
    in). `lostPasswordScreen(email:)` sends a password reset email.
  * `profileScreen()` and `emailVerificationScreen()` pop when the user signs
    out (or gets verified).
* Use `FirebaseUiAuthOptions` to turn features off:
  `registerEnabled: false` hides "Sign up"/"Create account",
  `lostPasswordEnabled: false` hides "Forgot password?". Both default to
  `true`.
* The lost password screen calls `FirebaseAuth.sendPasswordResetEmail`. Local
  backends (sdb, sembast, sim, local) only check that the email exists and
  send nothing; backends that do not support it throw and the screen shows
  the localized error.
* Email verification calls `FirebaseAuth.sendEmailVerification` which only
  the native Flutter backend supports; the basic screen shows an error
  otherwise.
* The design follows the app `ColorScheme`: set
  `ThemeData(colorSchemeSeed: Color(0xFF5B4FE9))` for the reference violet
  look. Dark themes are supported. `AuthUiTheme.of(context)` exposes the
  derived tokens if you build companion widgets.
* Reuse the exported widgets `AuthUserHeaderCard` and
  `AuthAccountDetailsSection` to show the current user elsewhere in the app.
* `AuthScreenBloc` (exported) exposes the current user as a `ValueStream`
  state and wraps the auth operations; reuse it with `BlocProvider` if you
  write a custom screen.
* To add a string: edit both `lib/src/l10n/app_en.arb` and `app_fr.arb`
  (same keys) then run `flutter gen-l10n` in the package
  (`dart run tool/genl10n.dart`). The generated `app_localizations*.dart`
  files are committed.
* Do not use this package for the native `firebase_ui_auth` screens: that is
  `tekartik_firebase_flutter_ui_auth` (`FirebaseUiAuthServiceFlutter`), which
  implements the same `FirebaseUiAuthService` interface.

## Examples

### App setup

```dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tekartik_firebase_ui_auth/ui_auth.dart';

MaterialApp buildApp({required FirebaseAuth firebaseAuth}) {
  return MaterialApp(
    theme: ThemeData(colorSchemeSeed: const Color(0xFF5B4FE9)),
    localizationsDelegates: const [
      FirebaseUiAuthServiceBasicLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: FirebaseUiAuthServiceBasicLocalizations.supportedLocales,
    home: HomeScreen(firebaseAuth: firebaseAuth),
  );
}
```

### Opening the auth screen (register disabled)

```dart
import 'package:flutter/material.dart';
import 'package:tekartik_firebase_ui_auth/ui_auth.dart';

/// Admin app: nobody can self register.
const uiAuthService = FirebaseUiAuthServiceBasic(
  options: FirebaseUiAuthOptions(registerEnabled: false),
);

Future<void> openAuth(BuildContext context, FirebaseAuth firebaseAuth) async {
  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => uiAuthService.authScreen(firebaseAuth: firebaseAuth),
    ),
  );
}

/// Sign-in only: completes with the user or null if cancelled.
Future<User?> requestSignIn(
  BuildContext context,
  FirebaseAuth firebaseAuth,
) async {
  return await Navigator.of(context).push<User?>(
    MaterialPageRoute(
      builder: (_) => uiAuthService.loginScreen(firebaseAuth: firebaseAuth),
    ),
  );
}
```

### Reacting to the current user

```dart
import 'package:flutter/material.dart';
import 'package:tekartik_firebase_ui_auth/ui_auth.dart';

class UserBadge extends StatelessWidget {
  final FirebaseAuth firebaseAuth;
  const UserBadge({super.key, required this.firebaseAuth});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: firebaseAuth.onCurrentUser,
      builder: (context, snapshot) {
        var user = snapshot.data;
        if (user == null) {
          return const Text('Not signed in');
        }
        return AuthUserHeaderCard(user: user);
      },
    );
  }
}
```

### Custom service (override one screen)

```dart
import 'package:flutter/widgets.dart';
import 'package:tekartik_firebase_ui_auth/ui_auth.dart';

class MyUiAuthService extends FirebaseUiAuthServiceBasic {
  const MyUiAuthService() : super(options: const FirebaseUiAuthOptions());

  @override
  Widget profileScreen({FirebaseAuth? firebaseAuth}) =>
      MyProfileScreen(firebaseAuth: firebaseAuth ?? FirebaseAuth.instance);
}
```
