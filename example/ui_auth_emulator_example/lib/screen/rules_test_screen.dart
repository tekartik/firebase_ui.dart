import 'package:flutter/material.dart';
import 'package:tekartik_firebase_firestore/firestore.dart';
import 'package:tekartik_firebase_ui_auth/ui_auth.dart';

import '../emulator_config.dart';
import '../firebase_context.dart';

/// Operations tested on each collection.
enum RulesTestOperation {
  /// `doc.get()` on the rules test document.
  get,

  /// `collection.limit(5).get()`.
  list,

  /// `collection.add(...)`.
  create,

  /// `doc.set(...)` on the rules test document.
  put,
}

/// Outcome of one operation.
enum RulesTestOutcome {
  /// Allowed by the rules.
  allowed,

  /// Denied by the rules.
  denied,

  /// Another error (network, emulator not running...).
  error,
}

/// One result.
class RulesTestResult {
  /// Outcome.
  final RulesTestOutcome outcome;

  /// Details (error message).
  final String? details;

  /// Result.
  RulesTestResult(this.outcome, [this.details]);
}

/// Collection tested.
class RulesTestTarget {
  /// Label.
  final String label;

  /// Expected behaviour (from the rules).
  final String expectation;

  /// Collection path for the current user id (null when signed out).
  final String Function(String? uid) path;

  /// Target.
  RulesTestTarget({
    required this.label,
    required this.expectation,
    required this.path,
  });
}

/// The collections exercised by the rules test.
final rulesTestTargets = [
  RulesTestTarget(
    label: 'public_items',
    expectation: 'get/list: everyone. create/put: signed-in users.',
    path: (_) => publicItemsCollection,
  ),
  RulesTestTarget(
    label: 'users/<my uid>/items',
    expectation: 'everything: the owner only.',
    path: (uid) => userItemsCollection(uid ?? 'anonymous'),
  ),
  RulesTestTarget(
    label: 'users/other_user/items',
    expectation: 'everything denied: not the owner.',
    path: (_) => userItemsCollection('other_user'),
  ),
  RulesTestTarget(
    label: 'admin_items',
    expectation: 'get/list: signed-in users. create/put: $testUserEmail only.',
    path: (_) => adminItemsCollection,
  ),
];

/// Whether [error] is a security rules denial.
///
/// Native and REST backends throw a [FirestoreException] with the
/// `permission-denied` code; the text checks cover raw HTTP 403 errors.
bool isRulesDeniedError(Object error) {
  if (error is FirestoreException) {
    return error.code == FirestoreErrorCode.permissionDenied;
  }
  var lower = error.toString().toLowerCase();
  return lower.contains('permission') ||
      lower.contains('insufficient') ||
      lower.contains('denied') ||
      lower.contains('status: 403');
}

/// Run one operation and classify the outcome.
Future<RulesTestResult> runRulesTestOperation(
  Firestore firestore,
  String collectionPath,
  RulesTestOperation operation, {
  String? uid,
}) async {
  var collection = firestore.collection(collectionPath);
  var doc = collection.doc(rulesTestDocId);
  var data = <String, Object?>{
    'text': 'rules test ${operation.name}',
    'owner': uid,
    'updated': Timestamp.now(),
  };
  try {
    switch (operation) {
      case RulesTestOperation.get:
        await doc.get();
      case RulesTestOperation.list:
        await collection.limit(5).get();
      case RulesTestOperation.create:
        await collection.add(data);
      case RulesTestOperation.put:
        await doc.set(data, SetOptions(merge: true));
    }
    return RulesTestResult(RulesTestOutcome.allowed);
  } catch (e) {
    var text = e.toString();
    if (isRulesDeniedError(e)) {
      return RulesTestResult(RulesTestOutcome.denied, text);
    }
    return RulesTestResult(RulesTestOutcome.error, text);
  }
}

/// Screen running get/list/create/put on each collection with the current
/// user (signed in or not) and showing what the rules allow.
class RulesTestScreen extends StatefulWidget {
  /// Firebase context.
  final ExampleFirebaseContext firebaseContext;

  /// Rules test screen.
  const RulesTestScreen({super.key, required this.firebaseContext});

  @override
  State<RulesTestScreen> createState() => _RulesTestScreenState();
}

class _RulesTestScreenState extends State<RulesTestScreen> {
  final _results =
      <RulesTestTarget, Map<RulesTestOperation, RulesTestResult>>{};
  var _running = false;
  String? _ranAs;

  ExampleFirebaseContext get firebaseContext => widget.firebaseContext;

  Future<void> _runAll() async {
    setState(() {
      _running = true;
      _results.clear();
    });
    var user = firebaseContext.auth.currentUser;
    var uid = user?.uid;
    _ranAs = user == null ? 'not signed in' : (user.email ?? uid);
    for (var target in rulesTestTargets) {
      var path = target.path(uid);
      for (var operation in RulesTestOperation.values) {
        var result = await runRulesTestOperation(
          firebaseContext.firestore,
          path,
          operation,
          uid: uid,
        );
        if (!mounted) {
          return;
        }
        setState(() {
          (_results[target] ??= {})[operation] = result;
        });
      }
    }
    if (mounted) {
      setState(() {
        _running = false;
      });
    }
  }

  Widget _resultIcon(RulesTestResult? result) {
    if (result == null) {
      return const Icon(Icons.remove, color: Colors.grey);
    }
    return switch (result.outcome) {
      RulesTestOutcome.allowed => const Icon(
        Icons.check_circle,
        color: Colors.green,
      ),
      RulesTestOutcome.denied => const Icon(Icons.block, color: Colors.orange),
      RulesTestOutcome.error => const Icon(Icons.error, color: Colors.red),
    };
  }

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Rules test')),
      body: StreamBuilder<User?>(
        stream: firebaseContext.auth.onCurrentUser,
        builder: (context, snapshot) {
          var user = snapshot.data;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: ListTile(
                  leading: Icon(
                    user != null
                        ? Icons.verified_user
                        : Icons.person_off_outlined,
                  ),
                  title: Text(
                    user != null
                        ? 'Signed in as ${user.email ?? user.uid}'
                        : 'Not signed in',
                  ),
                  subtitle: Text(
                    firebaseContext.rulesEnforced
                        ? 'Rules from emulator/firestore.rules'
                        : 'Local backend: rules are not enforced',
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                icon: _running
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.play_arrow),
                label: Text(
                  _running ? 'Running...' : 'Run get/list/create/put',
                ),
                onPressed: _running ? null : _runAll,
              ),
              if (_ranAs != null) ...[
                const SizedBox(height: 8),
                Text('Last run as: $_ranAs', style: textTheme.bodySmall),
              ],
              const SizedBox(height: 16),
              for (var target in rulesTestTargets) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(target.label, style: textTheme.titleMedium),
                        Text(target.expectation, style: textTheme.bodySmall),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 16,
                          runSpacing: 8,
                          children: [
                            for (var operation in RulesTestOperation.values)
                              Tooltip(
                                message:
                                    _results[target]?[operation]?.details ?? '',
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _resultIcon(_results[target]?[operation]),
                                    const SizedBox(width: 4),
                                    Text(operation.name),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 8),
              const Text(
                'Legend: green = allowed, orange = denied by the rules, '
                'red = other error (is the emulator running?).',
              ),
            ],
          );
        },
      ),
    );
  }
}
