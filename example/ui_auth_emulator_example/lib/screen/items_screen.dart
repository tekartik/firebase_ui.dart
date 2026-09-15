import 'package:flutter/material.dart';
import 'package:tekartik_firebase_auth/auth.dart';
import 'package:tekartik_firebase_ui_firestore/firebase_ui_firestore.dart';

import '../emulator_config.dart';
import '../firebase_context.dart';

/// Public items listed with [FirestoreListView] (readable by everyone,
/// writable by signed-in users, see emulator/firestore.rules).
class ItemsScreen extends StatelessWidget {
  /// Firebase context.
  final ExampleFirebaseContext firebaseContext;

  /// Items screen.
  const ItemsScreen({super.key, required this.firebaseContext});

  Future<void> _add(BuildContext context) async {
    var user = firebaseContext.auth.currentUser;
    try {
      await firebaseContext.firestore.collection(publicItemsCollection).add({
        'text': 'Item ${DateTime.now().toIso8601String()}',
        'owner': user?.uid,
        'ownerEmail': user?.email,
        'created': Timestamp.now(),
      });
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var query = firebaseContext.firestore
        .collection(publicItemsCollection)
        .orderBy('created', descending: true);
    return Scaffold(
      appBar: AppBar(title: const Text('Public items')),
      body: FirestoreListView(
        query: query,
        pageSize: 20,
        emptyBuilder: (context) =>
            const Center(child: Text('No item yet, add one!')),
        errorBuilder: (context, error, stackTrace) =>
            Center(child: Text('Error: $error')),
        itemBuilder: (context, snapshot) {
          var data = snapshot.data;
          var created = data['created'];
          return ListTile(
            title: Text(data['text']?.toString() ?? snapshot.ref.id),
            subtitle: Text(
              '${data['ownerEmail'] ?? data['owner'] ?? 'anonymous'}'
              '${created is Timestamp ? ' - ${created.toDateTime()}' : ''}',
            ),
          );
        },
      ),
      floatingActionButton: StreamBuilder<User?>(
        stream: firebaseContext.auth.onCurrentUser,
        builder: (context, snapshot) {
          var signedIn = snapshot.data != null;
          return FloatingActionButton.extended(
            onPressed: signedIn
                ? () {
                    _add(context);
                  }
                : null,
            backgroundColor: signedIn ? null : Theme.of(context).disabledColor,
            icon: const Icon(Icons.add),
            label: Text(signedIn ? 'Add item' : 'Sign in to add'),
          );
        },
      ),
    );
  }
}
