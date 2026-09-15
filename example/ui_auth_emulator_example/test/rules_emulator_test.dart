@TestOn('vm')
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_firebase_auth/auth.dart';
import 'package:tekartik_firebase_ui_auth_emulator_example/emulator_config.dart';
import 'package:tekartik_firebase_ui_auth_emulator_example/firebase_context.dart';
import 'package:tekartik_firebase_ui_auth_emulator_example/screen/rules_test_screen.dart';

/// Checks the firestore rules through the REST backend.
///
/// Skipped unless the emulators are running (`dart run tool/start_emulator.dart`).
Future<bool> _emulatorRunning() async {
  try {
    var socket = await Socket.connect(
      emulatorHost,
      firestoreEmulatorPort,
      timeout: const Duration(seconds: 1),
    );
    socket.destroy();
    return true;
  } catch (_) {
    return false;
  }
}

Future<void> main() async {
  if (!await _emulatorRunning()) {
    test(
      'emulator not running',
      () {},
      skip: 'start the emulators with `dart run tool/start_emulator.dart`',
    );
    return;
  }
  late ExampleFirebaseContext context;
  setUpAll(() async {
    context = await initExampleFirebaseContextRest();
  });
  tearDownAll(() async {
    await context.dispose();
  });

  Future<Map<RulesTestOperation, RulesTestOutcome>> run(
    String collectionPath,
  ) async {
    var uid = context.auth.currentUser?.uid;
    var results = <RulesTestOperation, RulesTestOutcome>{};
    for (var operation in RulesTestOperation.values) {
      var result = await runRulesTestOperation(
        context.firestore,
        collectionPath,
        operation,
        uid: uid,
      );
      results[operation] = result.outcome;
      expect(
        result.outcome,
        isNot(RulesTestOutcome.error),
        reason: '$collectionPath ${operation.name}: ${result.details}',
      );
    }
    return results;
  }

  const allowed = RulesTestOutcome.allowed;
  const denied = RulesTestOutcome.denied;

  test('not signed in', () async {
    await context.auth.signOut();
    expect(await run(publicItemsCollection), {
      RulesTestOperation.get: allowed,
      RulesTestOperation.list: allowed,
      RulesTestOperation.create: denied,
      RulesTestOperation.put: denied,
    });
    expect((await run(userItemsCollection('other_user'))).values.toSet(), {
      denied,
    });
    expect((await run(adminItemsCollection)).values.toSet(), {denied});
  });

  test('signed in as the test user', () async {
    await context.signInAsTestUser();
    var uid = context.auth.currentUser!.uid;
    expect((await run(publicItemsCollection)).values.toSet(), {allowed});
    expect((await run(userItemsCollection(uid))).values.toSet(), {allowed});
    expect((await run(userItemsCollection('other_user'))).values.toSet(), {
      denied,
    });
    expect((await run(adminItemsCollection)).values.toSet(), {allowed});
  });

  test('signed in as another user', () async {
    await context.auth.signOut();
    await context.auth.signInOrUpWithEmailAndPassword(
      email: 'other.user@example.com',
      password: 'test1234',
    );
    expect(await run(adminItemsCollection), {
      RulesTestOperation.get: allowed,
      RulesTestOperation.list: allowed,
      RulesTestOperation.create: denied,
      RulesTestOperation.put: denied,
    });
    await context.auth.signOut();
  });
}
