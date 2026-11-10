import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tekartik_firebase_firestore_sembast/firestore_sembast.dart';
import 'package:tekartik_firebase_ui_firestore/firebase_ui_firestore.dart';

void main() {
  /// The sembast memory firestore runs on timers: advance the fake clock.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 50; i++) {
      await tester.pump(const Duration(milliseconds: 1));
    }
  }

  List<String?> texts() => find
      .byType(Text)
      .evaluate()
      .map((element) => (element.widget as Text).data)
      .toList();

  testWidgets('FirestoreDataTable total follows the added and deleted rows', (
    tester,
  ) async {
    var firestore = newFirestoreMemory();
    var collection = firestore.collection('people');
    Future<void> write(Future<void> Function() action) async {
      var future = action();
      await settle(tester);
      await future;
    }

    await write(() => collection.doc('a').set({'name': 'a'}));
    await write(() => collection.doc('b').set({'name': 'b'}));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: FirestoreDataTable(
              query: collection,
              columnLabels: {'name': const Text('Name')},
            ),
          ),
        ),
      ),
    );
    await settle(tester);
    expect(texts(), containsAll(['a', 'b', '1–2 of 2']));

    await write(() => collection.doc('c').set({'name': 'c'}));
    await settle(tester);
    expect(texts(), containsAll(['a', 'b', 'c', '1–3 of 3']));

    await write(() => collection.doc('a').delete());
    await settle(tester);
    expect(texts(), containsAll(['b', 'c', '1–2 of 2']));
    expect(texts(), isNot(contains('a')));

    await tester.pumpWidget(Container());
    await settle(tester);
  });
}
