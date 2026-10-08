import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tekartik_firebase_ui_auth_emulator_example/main.dart';
import 'package:tekartik_firebase_ui_auth_emulator_example/theme/example_theme.dart';

import 'local_context.dart';

/// Local backends work in the real zone: alternate real delays with pumps.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump(const Duration(milliseconds: 200));
  }
  await tester.pump();
}

Future<void> tapText(WidgetTester tester, String text) async {
  var finder = find.text(text);
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
}

void main() {
  testWidgets('home, items and rules test screens', (tester) async {
    var firebaseContext = initExampleFirebaseContextLocal();
    await tester.pumpWidget(ExampleApp(firebaseContext: firebaseContext));
    await settle(tester);
    expect(find.text('Not signed in'), findsOneWidget);

    // Sign in as the test user
    await tapText(tester, 'Sign in as test user');
    await settle(tester);
    expect(find.text('test.user@example.com'), findsOneWidget);

    // Items screen (empty)
    await tapText(tester, 'Public items (FirestoreListView)');
    await settle(tester);
    expect(find.text('No item yet, add one!'), findsOneWidget);
    await tapText(tester, 'Add item');
    await settle(tester);
    expect(find.text('No item yet, add one!'), findsNothing);
    expect(find.byType(ListTile), findsOneWidget);
    await tester.pageBack();
    await settle(tester);

    // Rules test screen: local backend, everything is allowed
    await tapText(tester, 'Rules test');
    await settle(tester);
    await tapText(tester, 'Run get/list/create/put');
    await settle(tester);
    expect(find.byIcon(Icons.check_circle), findsNWidgets(16));
    expect(find.byIcon(Icons.error), findsNothing);
    await tester.pageBack();
    await settle(tester);

    // Auth screen of the basic ui service
    await tapText(tester, 'Authentication screen');
    await settle(tester);
    expect(find.text('Logout session'), findsOneWidget);

    await tester.runAsync(() => firebaseContext.dispose());
  });

  testWidgets('auth screens gallery and themes', (tester) async {
    Color primary(Finder finder) =>
        Theme.of(tester.element(finder)).colorScheme.primary;

    var firebaseContext = initExampleFirebaseContextLocal();
    await tester.pumpWidget(ExampleApp(firebaseContext: firebaseContext));
    await settle(tester);
    await tapText(tester, 'Auth screens gallery (themes)');
    await settle(tester);
    expect(find.text('Violet light'), findsOneWidget);
    expect(find.text('Demo content'), findsOneWidget);
    // The previews show the screens on the demo accounts.
    expect(find.text('Good morning, Camille'), findsOneWidget);
    expect(find.text('Welcome'), findsWidgets);

    // One tap: same theme in dark
    await tester.tap(find.text('Next theme'));
    await settle(tester);
    expect(find.text('Violet dark'), findsOneWidget);
    expect(
      Theme.of(tester.element(find.text('Violet dark'))).brightness,
      Brightness.dark,
    );

    // Pick another theme, the brightness is kept
    await tester.tap(find.text('Teal'));
    await settle(tester);
    expect(find.text('Teal dark'), findsOneWidget);
    expect(
      primary(find.text('Teal dark')),
      exampleThemes[1].colorScheme(Brightness.dark).primary,
    );

    // Open a screen, its button cycles the themes too
    await tester.tap(find.text('authScreen, signed out'), warnIfMissed: false);
    await settle(tester);
    expect(find.text('Sign in to access your account'), findsOneWidget);
    await tester.tap(find.byType(FloatingActionButton));
    await settle(tester);
    expect(
      primary(find.text('Sign in to access your account')),
      exampleThemes[2].colorScheme(Brightness.light).primary,
    );

    // Back to home, the demo accounts are deleted
    await tester.pageBack();
    await settle(tester);
    expect(find.text('Coral light'), findsOneWidget);
    // (the previews have back buttons too)
    tester.state<NavigatorState>(find.byType(Navigator).first).pop();
    await settle(tester);
    expect(find.text('Auth screens gallery (themes)'), findsOneWidget);

    await tester.runAsync(() => firebaseContext.dispose());
  });
}
