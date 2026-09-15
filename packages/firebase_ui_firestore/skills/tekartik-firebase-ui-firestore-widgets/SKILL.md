---
name: tekartik-firebase-ui-firestore-widgets
description: >-
  Use when displaying Firestore collections in Flutter with
  tekartik_firebase_ui_firestore: FirestoreListView, FirestoreQueryBuilder
  (paginated queries with fetchMore) and FirestoreDataTable built on the
  tekartik_firebase_firestore Query abstraction (native, REST or local
  sembast backends).
---

# tekartik_firebase_ui_firestore widgets

Port of the official `firebase_ui_firestore` widgets to the
`tekartik_firebase_firestore` abstraction: the same widgets work with the
native Flutter Firestore, the REST client or the local sembast/sdb
implementations used in tests.

## Guidelines

* Import `package:tekartik_firebase_ui_firestore/firebase_ui_firestore.dart`;
  it re-exports `package:tekartik_firebase_firestore/firestore.dart`
  (`Query`, `CollectionReference`, `DocumentSnapshot`, ...).
* `query` is a `tekartik_firebase_firestore` `Query`: a
  `CollectionReference` or a chained `where`/`orderBy`/`limit`. Obtain the
  `Firestore` from a service, for example
  `firestoreServiceFlutter.firestore(firebaseFlutter.app())` after
  `Firebase.initializeApp`, or `newFirestoreServiceSembastMemory()` style
  helpers in tests. Never use `cloud_firestore` types directly with these
  widgets.
* Prefer `FirestoreListView` for simple lists: it shows a progress indicator
  while fetching, renders `itemBuilder(context, DocumentSnapshot)` per
  document and fetches the next page automatically when the last item is
  built. Provide `emptyBuilder` and `errorBuilder` for a complete UX.
* Use `FirestoreQueryBuilder` for custom layouts (grids, slivers). Its
  `builder(context, snapshot, child)` receives a
  `FirestoreQueryBuilderSnapshot`: check `isFetching` (first page),
  `hasError`/`error`, `docs`, then call `snapshot.fetchMore()` when the last
  visible item is built and `snapshot.hasMore` is `true`. `fetchMore` is safe
  to call several times and from `build`.
* `pageSize` (default 10) controls the page size for both widgets. Keep the
  `Query` instance stable (build it once, outside `build`) or the widget
  resets and refetches the first page.
* Document data is `snapshot.data` (`Map<String, Object?>`); map it to a
  model with a `fromJson`-style constructor. Use `snapshot.ref` to update or
  delete the document.
* `FirestoreDataTable` shows a paginated editable table: `columnLabels` must
  be a `LinkedHashMap` (a map literal is fine) from field name to header
  widget; rows can be selected (`onSelectedRows`), edited in place
  (`enableDefaultCellEditor`, `onTapCell`) and deleted (`canDeleteItems`).
  Use `cellBuilder` to customize how a field is rendered.
* The table strings come from `firebase_ui_localizations`: add
  `FirebaseUILocalizations.delegate` to the `MaterialApp` delegates.
* A security rules denial surfaces as a `FirestoreException` whose `code` is
  `FirestoreErrorCode.permissionDenied` on both the native and REST backends;
  handle it in `errorBuilder`. `example/ui_auth_emulator_example` in the
  repository shows `FirestoreListView` on the Firestore emulator with rules
  and a screen testing get/list/create/put as signed-in or anonymous.

## Examples

### List view

```dart
import 'package:flutter/material.dart';
import 'package:tekartik_firebase_ui_firestore/firebase_ui_firestore.dart';

class ContactsScreen extends StatelessWidget {
  final Firestore firestore;
  const ContactsScreen({super.key, required this.firestore});

  @override
  Widget build(BuildContext context) {
    // Build the query once per build of a stable widget.
    var query = firestore.collection('users').orderBy('lastName');
    return Scaffold(
      appBar: AppBar(title: const Text('Contacts')),
      body: FirestoreListView(
        query: query,
        pageSize: 20,
        emptyBuilder: (context) => const Center(child: Text('No contact')),
        errorBuilder: (context, error, stackTrace) =>
            Center(child: Text('Error: $error')),
        itemBuilder: (context, snapshot) {
          var data = snapshot.data;
          return ListTile(
            title: Text('${data['firstName']} ${data['lastName']}'),
            subtitle: Text(data['email']?.toString() ?? ''),
            onTap: () => snapshot.ref.update({'seen': true}),
          );
        },
      ),
    );
  }
}
```

### Custom layout with manual pagination

```dart
import 'package:flutter/material.dart';
import 'package:tekartik_firebase_ui_firestore/firebase_ui_firestore.dart';

Widget buildGrid(Query query) {
  return FirestoreQueryBuilder(
    query: query,
    builder: (context, snapshot, _) {
      if (snapshot.isFetching) {
        return const Center(child: CircularProgressIndicator());
      }
      if (snapshot.hasError) {
        return Text('error ${snapshot.error}');
      }
      return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemCount: snapshot.docs.length,
        itemBuilder: (context, index) {
          if (snapshot.hasMore && index + 1 == snapshot.docs.length) {
            snapshot.fetchMore();
          }
          var doc = snapshot.docs[index];
          return Card(child: Text(doc.data['name']?.toString() ?? doc.id));
        },
      );
    },
  );
}
```

### Data table

```dart
import 'package:flutter/material.dart';
import 'package:tekartik_firebase_ui_firestore/firebase_ui_firestore.dart';

Widget buildTable(Query query) {
  return FirestoreDataTable(
    query: query,
    rowsPerPage: 20,
    canDeleteItems: false,
    columnLabels: const {
      'firstName': Text('First name'),
      'lastName': Text('Last name'),
      'email': Text('Email'),
    },
    onSelectedRows: (items) {
      debugPrint('${items.length} selected');
    },
  );
}
```
