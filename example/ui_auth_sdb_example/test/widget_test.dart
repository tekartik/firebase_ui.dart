import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tekartik_app_flutter_idb/sdb.dart';
import 'package:tekartik_firebase_ui_auth/ui_auth.dart';
import 'package:tekartik_firebase_ui_auth_sdb_example/main.dart';

/// The sdb backend works in the real zone: alternate real delays with pumps.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump(const Duration(milliseconds: 200));
  }
  await tester.pump();
}

void main() {
  testWidgets('home screen renders', (tester) async {
    var firebaseAuth = initFirebaseAuthSdb(sdbFactory: sdbFactoryMemory);
    await tester.pumpWidget(ExampleApp(firebaseAuth: firebaseAuth));
    await settle(tester);
    expect(find.text('Not signed in'), findsOneWidget);
    expect(find.text('Authentication screen'), findsOneWidget);

    await tester.tap(find.text('Authentication screen'));
    await settle(tester);
    expect(find.text('Welcome'), findsOneWidget);
    expect(find.byType(FilledButton), findsWidgets);
    await tester.runAsync(() => firebaseAuth.app.delete());
  });

  group('sign in and join', () {
    late FirebaseAuth firebaseAuth;

    Future<void> tapVisible(WidgetTester tester, Finder finder) async {
      await tester.ensureVisible(finder);
      await tester.pump();
      await tester.tap(finder);
      await settle(tester);
    }

    /// Opens the auth screen from "Sign in and join" and signs in.
    Future<void> signIn(WidgetTester tester) async {
      await tester.runAsync(() async {
        await firebaseAuth.createUserWithEmailAndPassword(
          email: 'user@example.com',
          password: 'password1',
        );
        await firebaseAuth.signOut();
      });
      await tester.pumpWidget(ExampleApp(firebaseAuth: firebaseAuth));
      await settle(tester);
      await tapVisible(tester, find.text('Sign in and join'));
      await tapVisible(tester, find.text('Sign in'));
      await tester.enterText(find.byType(TextField).at(0), 'user@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'password1');
      await tester.pump();
      await tapVisible(tester, find.text('Sign in'));
    }

    setUp(() {
      firebaseAuth = initFirebaseAuthSdb(sdbFactory: newSdbFactoryMemory());
    });

    testWidgets('join from the auth screen', (tester) async {
      await signIn(tester);
      await tapVisible(tester, find.text('Join'));
      expect(find.text('Joined'), findsOneWidget);
      await tester.runAsync(() => firebaseAuth.app.delete());
    });

    testWidgets('back, then join', (tester) async {
      await signIn(tester);
      await tester.pageBack();
      await settle(tester);
      // Signed in: "Join" instead of "Sign in and join".
      expect(find.text('Joined'), findsNothing);
      expect(find.text('Sign in and join'), findsNothing);
      await tapVisible(tester, find.widgetWithText(FilledButton, 'Join'));
      expect(find.text('Joined'), findsOneWidget);
      await tester.runAsync(() => firebaseAuth.app.delete());
    });
  });
}
