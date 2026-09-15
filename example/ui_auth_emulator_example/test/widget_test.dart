import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_firebase_ui_auth_emulator_example/main.dart';

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
}
