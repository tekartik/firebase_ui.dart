---
name: tekartik-firebase-ui-auth-testing
description: >-
  Use when writing Flutter widget tests or offline demos for screens built with
  tekartik_firebase_ui_auth: in-memory sdb auth backend, pumping the screens
  with the localization delegates, driving sign-in/register/lost password
  flows and waiting for the async auth operations.
---

# Testing tekartik_firebase_ui_auth screens

## Guidelines

* Use the local sdb backend from `tekartik_firebase_auth_sdb` as a
  `dev_dependency`: `newFirebaseAuthSdbMemory()` returns a fresh in-memory
  `FirebaseAuth` supporting `createUserWithEmailAndPassword`,
  `signInWithEmailAndPassword`, `signOut` and `sendPasswordResetEmail`
  (which only checks that the user exists). Delete the app in `tearDown`
  (`await auth.app.delete()`).
* Always pass `firebaseAuth:` to the screen builders in tests; never rely on
  `FirebaseAuth.instance`.
* Wrap the screen in a `MaterialApp` with the
  `FirebaseUiAuthServiceBasicLocalizations.delegate` and the global
  delegates so the English strings are the ones you assert on.
* The screens run auth calls asynchronously and add a 300 ms delay after
  sign-in/sign-out. `pumpAndSettle` alone can stop early: pump a few times
  with a duration (for example 5 × 200 ms) then `pumpAndSettle`.
* Locate fields with `find.byType(TextField).at(index)` (order: email,
  password, confirm password) and buttons by their English label
  (`Sign in`, `Sign up`, `Send reset link`, `Logout session`). App bar titles
  are upper-cased (`ACCOUNT ACCESS`), so they never clash with button labels.
* `find.text` skips offstage widgets, so after a screen pops the underlying
  screen is the one being asserted on.
* Email verification is not supported by the local backends: the basic
  screen shows `Could not send the verification email.`; assert on that
  rather than on a success.

## Examples

### Test harness

```dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_firebase_auth_sdb/auth_sdb.dart';
import 'package:tekartik_firebase_ui_auth/ui_auth.dart';

Widget testApp(Widget home) => MaterialApp(
  localizationsDelegates: const [
    FirebaseUiAuthServiceBasicLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: FirebaseUiAuthServiceBasicLocalizations.supportedLocales,
  home: home,
);

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
  await tester.pumpAndSettle();
}

void main() {
  late FirebaseAuth auth;
  setUp(() => auth = newFirebaseAuthSdbMemory());
  tearDown(() => auth.app.delete());

  testWidgets('login', (tester) async {
    await auth.createUserWithEmailAndPassword(
      email: 'user@example.com',
      password: 'password1',
    );
    await auth.signOut();

    await tester.pumpWidget(testApp(authScreen(firebaseAuth: auth)));
    await settle(tester);
    await tester.tap(find.text('Sign in'));
    await settle(tester);

    await tester.enterText(find.byType(TextField).at(0), 'user@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'password1');
    await tester.tap(find.text('Sign in'));
    await settle(tester);

    expect(auth.currentUser?.email, 'user@example.com');
    expect(find.text('Logout session'), findsOneWidget);
  });
}
```

### Offline demo app

```dart
import 'package:tekartik_app_flutter_idb/sdb.dart';
import 'package:tekartik_firebase_auth_sdb/auth_sdb.dart';
import 'package:tekartik_firebase_local/firebase_local.dart';
import 'package:tekartik_firebase_ui_auth/ui_auth.dart';

/// Persistent local auth (IndexedDB on the web, sembast elsewhere).
FirebaseAuth initLocalAuth() {
  var app = newFirebaseAppLocal(
    options: FirebaseAppOptions(projectId: 'my-local-project'),
  );
  var authService = FirebaseAuthServiceSdb(
    sdbFactory: getSdbFactory(packageName: 'com.example.my_app'),
  );
  return authService.auth(app);
}
```
