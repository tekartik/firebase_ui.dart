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

/// Let async auth operations (and the 300ms post-action delays) complete.
///
/// The sdb backend works in the real zone: alternate real delays
/// ([WidgetTester.runAsync]) with fake clock pumps. `pumpAndSettle` is not
/// used because the busy indicator animates for as long as an operation runs.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump(const Duration(milliseconds: 200));
  }
  await tester.pump();
}

/// Run an auth operation in the real zone before pumping a screen, and let
/// the backend notifications (current user record changes) flush.
Future<void> runAuth(WidgetTester tester, Future<void> Function() action) =>
    tester.runAsync(() async {
      await action();
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });

/// Scroll to and tap the widget showing [text].
Future<void> tapText(WidgetTester tester, String text) async {
  var finder = find.text(text);
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
}

Future<void> enterField(WidgetTester tester, int index, String text) async {
  await tester.enterText(find.byType(TextField).at(index), text);
  await tester.pump();
}

void main() {
  late FirebaseAuth auth;
  setUp(() {
    auth = newFirebaseAuthSdbMemory();
  });
  tearDown(() async {
    await auth.app.delete();
  });

  group('auth screen', () {
    testWidgets('signed out', (tester) async {
      await tester.pumpWidget(testApp(authScreen(firebaseAuth: auth)));
      await settle(tester);
      expect(find.text('Welcome'), findsOneWidget);
      expect(find.text('Sign in'), findsOneWidget);
      expect(find.text('Create account'), findsOneWidget);
    });

    testWidgets('register disabled', (tester) async {
      const service = FirebaseUiAuthServiceBasic(
        options: FirebaseUiAuthOptions(
          registerEnabled: false,
          lostPasswordEnabled: false,
        ),
      );
      await tester.pumpWidget(testApp(service.authScreen(firebaseAuth: auth)));
      await settle(tester);
      expect(find.text('Create account'), findsNothing);

      await tapText(tester, 'Sign in');
      await settle(tester);
      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Sign up'), findsNothing);
      expect(find.text('Forgot password?'), findsNothing);
    });

    testWidgets('login and logout', (tester) async {
      await runAuth(tester, () async {
        await auth.createUserWithEmailAndPassword(
          email: 'user@example.com',
          password: 'password1',
        );
        await auth.signOut();
      });

      await tester.pumpWidget(testApp(authScreen(firebaseAuth: auth)));
      await settle(tester);
      await tapText(tester, 'Sign in');
      await settle(tester);
      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Forgot password?'), findsOneWidget);
      expect(find.text('Sign up'), findsOneWidget);

      // Wrong password
      await enterField(tester, 0, 'user@example.com');
      await enterField(tester, 1, 'wrong');
      await tapText(tester, 'Sign in');
      await settle(tester);
      expect(find.textContaining('Sign in failed'), findsOneWidget);

      // Good password
      await enterField(tester, 1, 'password1');
      await tapText(tester, 'Sign in');
      await settle(tester);

      // Back on the auth screen, signed in
      expect(find.text('Welcome back'), findsNothing);
      expect(find.text('user@example.com'), findsWidgets);
      expect(find.text('Account details'.toUpperCase()), findsOneWidget);
      expect(find.text('Logout session'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);

      await tapText(tester, 'Logout session');
      await settle(tester);
      expect(find.text('Welcome'), findsOneWidget);
      expect(auth.currentUser, isNull);
    });

    testWidgets('register', (tester) async {
      await tester.pumpWidget(testApp(authScreen(firebaseAuth: auth)));
      await settle(tester);
      await tapText(tester, 'Create account');
      await settle(tester);
      expect(find.text('Create your account'), findsOneWidget);

      await enterField(tester, 0, 'new@example.com');
      await enterField(tester, 1, 'password1');
      await enterField(tester, 2, 'password2');
      expect(find.text('Passwords do not match'), findsOneWidget);
      await enterField(tester, 2, 'password1');
      expect(find.text('Passwords do not match'), findsNothing);

      await tapText(tester, 'Sign up');
      await settle(tester);

      expect(auth.currentUser?.email, 'new@example.com');
      expect(find.text('Create your account'), findsNothing);
      expect(find.text('new@example.com'), findsWidgets);
    });
  });

  group('lost password', () {
    testWidgets('send reset link', (tester) async {
      await runAuth(tester, () async {
        await auth.createUserWithEmailAndPassword(
          email: 'lost@example.com',
          password: 'password1',
        );
        await auth.signOut();
      });
      await tester.pumpWidget(testApp(authLoginScreen(firebaseAuth: auth)));
      await settle(tester);
      await enterField(tester, 0, 'lost@example.com');
      await tapText(tester, 'Forgot password?');
      await settle(tester);
      expect(find.text('Forgot your password?'), findsOneWidget);
      // Email is pre-filled
      expect(find.text('lost@example.com'), findsOneWidget);

      await tapText(tester, 'Send reset link');
      await settle(tester);
      expect(find.text('Check your inbox'), findsOneWidget);
      expect(find.textContaining('lost@example.com'), findsOneWidget);

      await tapText(tester, 'Back to sign in');
      await settle(tester);
      expect(find.text('Welcome back'), findsOneWidget);
    });

    testWidgets('unknown email', (tester) async {
      await tester.pumpWidget(
        testApp(authLostPasswordScreen(firebaseAuth: auth)),
      );
      await settle(tester);
      await enterField(tester, 0, 'nobody@example.com');
      await tapText(tester, 'Send reset link');
      await settle(tester);
      expect(find.text('Check your inbox'), findsNothing);
      expect(find.textContaining('Could not send'), findsOneWidget);
    });
  });

  group('profile', () {
    testWidgets('details and email verification', (tester) async {
      await runAuth(tester, () async {
        await auth.createUserWithEmailAndPassword(
          email: 'profile@example.com',
          password: 'password1',
        );
      });
      await tester.pumpWidget(testApp(authProfileScreen(firebaseAuth: auth)));
      await settle(tester);
      expect(find.text('profile@example.com'), findsWidgets);
      expect(find.text('Email not verified'), findsOneWidget);

      // Tap the status row to open the email verification screen
      await tapText(tester, 'Email not verified');
      await settle(tester);
      expect(find.text('Verify your email'), findsOneWidget);
      // Not supported locally: an error is displayed
      await tapText(tester, 'Send verification email');
      await settle(tester);
      expect(find.textContaining('Could not send'), findsOneWidget);
    });
  });
}
