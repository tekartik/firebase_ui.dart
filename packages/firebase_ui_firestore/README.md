# tekartik_firebase_ui_firestore

Flutter widgets showing Firestore queries: `FirestoreListView`,
`FirestoreQueryBuilder` (paginated, any layout) and `FirestoreDataTable`
(editable table). A port of FlutterFire's `firebase_ui_firestore` on the
[tekartik_firebase_firestore](https://github.com/tekartik/firebase_firestore.dart/tree/master/firestore)
abstraction: the same widgets work on the native Flutter Firestore, the REST
client and the local (sembast, sdb) backends.

## Getting started

Git package, not on pub.dev (Flutter: Android, iOS, macOS, web, Linux,
Windows, whatever the Firestore backend supports):

```yaml
dependencies:
  tekartik_firebase_ui_firestore:
    git:
      url: https://github.com/tekartik/firebase_ui.dart
      path: packages/firebase_ui_firestore
```

```dart
import 'package:flutter/material.dart';
// Re-exports package:tekartik_firebase_firestore/firestore.dart.
import 'package:tekartik_firebase_ui_firestore/firebase_ui_firestore.dart';

class UsersScreen extends StatefulWidget {
  final Firestore firestore;
  const UsersScreen({super.key, required this.firestore});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  // Built once: a new query object restarts the list (see Pitfalls).
  late final query = widget.firestore.collection('users').orderBy('name');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: FirestoreListView(
        query: query,
        emptyBuilder: (context) => const Center(child: Text('No user')),
        itemBuilder: (context, snapshot) =>
            ListTile(title: Text('${snapshot.data['name']}')),
      ),
    );
  }
}
```

The `Firestore` comes from the backend of the app, for example
`firestoreServiceFlutter.firestore(firebaseFlutter.app())`
(`tekartik_firebase_firestore_flutter`) or `newFirestoreMemory()`
(`tekartik_firebase_firestore_sembast`) in a widget test.

## When to use what

* `FirestoreListView`: a `ListView` of the documents, the next page is fetched
  when the last item is built (`pageSize`, default 10).
* `FirestoreQueryBuilder`: your own layout; its `builder` gets a snapshot with
  `isFetching`, `hasError`, `docs`, `hasMore` and `fetchMore()`.
* `FirestoreDataTable`: a paginated table of the fields named in
  `columnLabels`, with selection, deletion and an in place editor; its total
  follows the documents added and deleted.

## Pitfalls

* Build the query once (a field, `initState`), not in `build`: tekartik
  queries have no value equality, so a new `collection('x').orderBy('y')` at
  each parent rebuild restarts the listener and the pagination (the list goes
  back to its first page). A `CollectionReference` (`collection('users')`) is
  compared by path and can be built anywhere.
* `FirestoreDataTable` without `onError`: a refused delete (security rules) is
  an uncaught error.
* The table texts come from `firebase_ui_localizations`: add
  `FirebaseUILocalizations.delegate` to the app for other languages.

## Agent skills

`skills/tekartik-firebase-ui-firestore-widgets` (more examples).
