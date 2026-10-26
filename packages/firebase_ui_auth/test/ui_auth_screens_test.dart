import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tekartik_firebase_auth_sdb/auth_sdb.dart';
import 'package:tekartik_firebase_ui_auth/ui_auth.dart';

Widget testApp(Widget home) => MaterialApp(
  localizationsDelegates: const [
    FirebaseUiAuthServiceBasicLocalizations.delegate,
    ...GlobalMaterialLocalizations.delegates,
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

/// Whether the primary button showing [label] is enabled.
bool buttonEnabled(WidgetTester tester, String label) => tester
    .widget<FilledButton>(
      find.ancestor(of: find.text(label), matching: find.byType(FilledButton)),
    )
    .enabled;

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

    testWidgets('anonymous: welcome, then sign in', (tester) async {
      await runAuth(tester, () async {
        await auth.createUserWithEmailAndPassword(
          email: 'user@example.com',
          password: 'password1',
        );
        await auth.signOut();
        await auth.signInAnonymously();
      });
      expect(auth.currentUser?.isAnonymous, isTrue);

      // An anonymous user has no account: offered to sign in or create one.
      await tester.pumpWidget(testApp(authScreen(firebaseAuth: auth)));
      await settle(tester);
      expect(find.text('Welcome'), findsOneWidget);
      expect(find.text('Create account'), findsOneWidget);
      expect(find.text('Logout session'), findsNothing);

      // The login screen stays open for them, signing in switches account.
      await tapText(tester, 'Sign in');
      await settle(tester);
      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.textContaining('without an account'), findsOneWidget);

      await enterField(tester, 0, 'user@example.com');
      await enterField(tester, 1, 'password1');
      await tapText(tester, 'Sign in');
      await settle(tester);
      expect(find.text('Welcome back'), findsNothing);
      expect(auth.currentUser?.email, 'user@example.com');
      expect(find.text('Logout session'), findsOneWidget);
      expect(find.text('Continue'), findsNothing);
    });
  });

  group('continue', () {
    /// A "Sign in and join" button opening the auth screen to continue,
    /// [results] gets what it popped with.
    Widget joinApp(List<FirebaseUiAuthContinueResult> results) => testApp(
      Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () async {
                results.add(
                  await firebaseUiAuthServiceBasic.pushAuthScreenToContinue(
                    context,
                    firebaseAuth: auth,
                    authContinue: const FirebaseUiAuthContinue(label: 'Join'),
                  ),
                );
              },
              child: const Text('Sign in and join'),
            ),
          ),
        ),
      ),
    );

    Future<void> signIn(WidgetTester tester) async {
      await tapText(tester, 'Sign in');
      await settle(tester);
      await enterField(tester, 0, 'user@example.com');
      await enterField(tester, 1, 'password1');
      await tapText(tester, 'Sign in');
      await settle(tester);
    }

    setUp(() async {
      await auth.createUserWithEmailAndPassword(
        email: 'user@example.com',
        password: 'password1',
      );
      await auth.signOut();
    });

    testWidgets('signed in, continue', (tester) async {
      var results = <FirebaseUiAuthContinueResult>[];
      await tester.pumpWidget(joinApp(results));
      await tapText(tester, 'Sign in and join');
      await settle(tester);
      // Signed out: no way on yet.
      expect(find.text('Welcome'), findsOneWidget);
      expect(find.text('Join'), findsNothing);

      await signIn(tester);
      // Back on the auth screen, signed in, with the way on.
      expect(find.text('Logout session'), findsOneWidget);
      expect(results, isEmpty);

      await tapText(tester, 'Join');
      await settle(tester);
      expect(find.text('Sign in and join'), findsOneWidget);
      var result = results.single;
      expect(result.continued, isTrue);
      expect(result.hasAccount, isTrue);
      expect(result.user?.email, 'user@example.com');
    });

    testWidgets('signed in, back', (tester) async {
      var results = <FirebaseUiAuthContinueResult>[];
      await tester.pumpWidget(joinApp(results));
      await tapText(tester, 'Sign in and join');
      await settle(tester);
      await signIn(tester);
      expect(find.text('Join'), findsOneWidget);

      await tester.pageBack();
      await settle(tester);
      expect(find.text('Sign in and join'), findsOneWidget);
      // Signed in: the caller now offers the action itself.
      var result = results.single;
      expect(result.continued, isFalse);
      expect(result.hasAccount, isTrue);
      expect(result.user?.email, 'user@example.com');
    });

    testWidgets('signed out, back', (tester) async {
      var results = <FirebaseUiAuthContinueResult>[];
      await tester.pumpWidget(joinApp(results));
      await tapText(tester, 'Sign in and join');
      await settle(tester);
      expect(find.text('Welcome'), findsOneWidget);

      await tester.pageBack();
      await settle(tester);
      var result = results.single;
      expect(result.continued, isFalse);
      expect(result.hasAccount, isFalse);
      expect(result.user, isNull);
    });

    testWidgets('default label', (tester) async {
      await runAuth(tester, () async {
        await auth.signInWithEmailAndPassword(
          email: 'user@example.com',
          password: 'password1',
        );
      });
      await tester.pumpWidget(
        testApp(
          authScreen(
            firebaseAuth: auth,
            authContinue: const FirebaseUiAuthContinue(),
          ),
        ),
      );
      await settle(tester);
      expect(find.text('Continue'), findsOneWidget);
    });
  });

  group('anonymous user link', () {
    testWidgets('create account links the anonymous user', (tester) async {
      late String anonymousUid;
      await runAuth(tester, () async {
        anonymousUid = (await auth.signInAnonymously()).user.uid;
      });
      await tester.pumpWidget(testApp(authScreen(firebaseAuth: auth)));
      await settle(tester);
      await tapText(tester, 'Create account');
      await settle(tester);
      expect(
        find.text(
          'What you did without an account is kept in your new account',
        ),
        findsOneWidget,
      );

      await enterField(tester, 0, 'linked@example.com');
      await enterField(tester, 1, 'password1');
      await enterField(tester, 2, 'password1');
      await tapText(tester, 'Sign up');
      await settle(tester);

      // Same user, no longer anonymous; the register screen popped.
      expect(auth.currentUser?.uid, anonymousUid);
      expect(auth.currentUser?.isAnonymous, isFalse);
      expect(auth.currentUser?.email, 'linked@example.com');
      expect(find.text('Create your account'), findsNothing);
      expect(find.text('Logout session'), findsOneWidget);
    });

    testWidgets('an email in use', (tester) async {
      late String anonymousUid;
      await runAuth(tester, () async {
        await auth.createUserWithEmailAndPassword(
          email: 'taken@example.com',
          password: 'password1',
        );
        await auth.signOut();
        anonymousUid = (await auth.signInAnonymously()).user.uid;
      });
      await tester.pumpWidget(testApp(authRegisterScreen(firebaseAuth: auth)));
      await settle(tester);
      await enterField(tester, 0, 'taken@example.com');
      await enterField(tester, 1, 'password1');
      await enterField(tester, 2, 'password1');
      await tapText(tester, 'Sign up');
      await settle(tester);
      expect(
        find.text(
          'An account already exists with this email. Sign in instead.',
        ),
        findsOneWidget,
      );
      expect(auth.currentUser?.uid, anonymousUid);
      expect(auth.currentUser?.isAnonymous, isTrue);
    });

    testWidgets('link mode off: a new user', (tester) async {
      const service = FirebaseUiAuthServiceBasic(
        options: FirebaseUiAuthOptions(linkAnonymousUser: false),
      );
      late String anonymousUid;
      await runAuth(tester, () async {
        anonymousUid = (await auth.signInAnonymously()).user.uid;
      });
      await tester.pumpWidget(testApp(service.loginScreen(firebaseAuth: auth)));
      await settle(tester);
      expect(find.textContaining('without an account'), findsNothing);

      await tester.pumpWidget(
        testApp(service.registerScreen(firebaseAuth: auth)),
      );
      await settle(tester);
      expect(
        find.text('Enter your email and choose a password to get started'),
        findsOneWidget,
      );
      await enterField(tester, 0, 'new@example.com');
      await enterField(tester, 1, 'password1');
      await enterField(tester, 2, 'password1');
      await tapText(tester, 'Sign up');
      await settle(tester);
      expect(auth.currentUser?.email, 'new@example.com');
      expect(auth.currentUser?.uid, isNot(anonymousUid));
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

  group('submit after a failure', () {
    // The button is enabled again once no longer busy: retry without editing
    // a field.
    testWidgets('login', (tester) async {
      await runAuth(tester, () async {
        await auth.createUserWithEmailAndPassword(
          email: 'user@example.com',
          password: 'password1',
        );
        await auth.signOut();
      });
      await tester.pumpWidget(testApp(authLoginScreen(firebaseAuth: auth)));
      await settle(tester);
      await enterField(tester, 0, 'user@example.com');
      await enterField(tester, 1, 'wrong');
      await tapText(tester, 'Sign in');
      await settle(tester);
      expect(find.textContaining('Sign in failed'), findsOneWidget);
      expect(buttonEnabled(tester, 'Sign in'), isTrue);

      // Retry without editing: tried again (and failed again).
      await tapText(tester, 'Sign in');
      await tester.pump();
      expect(find.textContaining('Sign in failed'), findsNothing);
      await settle(tester);
      expect(find.textContaining('Sign in failed'), findsOneWidget);
      expect(buttonEnabled(tester, 'Sign in'), isTrue);
    });

    testWidgets('register', (tester) async {
      await runAuth(tester, () async {
        await auth.createUserWithEmailAndPassword(
          email: 'taken@example.com',
          password: 'password1',
        );
        await auth.signOut();
      });
      await tester.pumpWidget(testApp(authRegisterScreen(firebaseAuth: auth)));
      await settle(tester);
      await enterField(tester, 0, 'taken@example.com');
      await enterField(tester, 1, 'password1');
      await enterField(tester, 2, 'password1');
      await tapText(tester, 'Sign up');
      await settle(tester);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(auth.currentUser, isNull);
      expect(buttonEnabled(tester, 'Sign up'), isTrue);
    });

    testWidgets('lost password', (tester) async {
      await tester.pumpWidget(
        testApp(authLostPasswordScreen(firebaseAuth: auth)),
      );
      await settle(tester);
      await enterField(tester, 0, 'nobody@example.com');
      await tapText(tester, 'Send reset link');
      await settle(tester);
      expect(find.textContaining('Could not send'), findsOneWidget);
      expect(buttonEnabled(tester, 'Send reset link'), isTrue);
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
