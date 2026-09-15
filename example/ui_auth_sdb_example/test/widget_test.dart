import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_flutter_idb/sdb.dart';
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
}
