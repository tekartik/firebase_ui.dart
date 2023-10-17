// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: subtype_of_sealed_class, must_be_immutable, avoid_implementing_value_types

import 'dart:async';

import 'package:tekartik_firebase_firestore/firestore.dart';
import 'package:tekartik_firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

typedef Snapshot = QuerySnapshot;

const bob = Person(
  firstName: 'Bob',
  address: Address(street: 'Awesome Road', city: 'FlutterFire City'),
);
const bob2 = Person(
  firstName: 'Bob #2',
  address: Address(street: 'Awesome Road', city: 'FlutterFire City'),
);

Future<void> main() async {
  setUp(() async {
    when(bobSnapshot.data).thenReturn(bob.toMap());
    when(bob2Snapshot.data).thenReturn(bob2.toMap());
  });

  testWidgets(
    'FirestoreDataTable without CellBuilder is render as expected',
    (WidgetTester tester) async {
      await tester.pumpWidget(_dataTableBuilder(query: collection));
      mockCtrl.add(mockQuerySnapshot);

      await tester.pumpAndSettle();

      final street = bob.address.street;
      final city = bob.address.city;

      final streetFinder = find.text('{street: $street, city: $city}');
      final firstNameFinder = find.text(bob.firstName);

      expect(streetFinder, findsNWidgets(2));
      expect(firstNameFinder, findsOneWidget);
    },
  );

  testWidgets(
    'FirestoreDataTable with CellBuilder is render as expected',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        _dataTableBuilder(
          query: collection,
          cellBuilder: _defaultCellBuilder,
        ),
      );

      mockCtrl.add(mockQuerySnapshot);

      await tester.pumpAndSettle();

      final cityFinder = find.text(bob.address.city);
      final streetFinder = find.text(bob.address.street);
      final firstNameFinder = find.text(bob.firstName);

      expect(cityFinder, findsNWidgets(2));
      expect(streetFinder, findsNWidgets(2));
      expect(firstNameFinder, findsOneWidget);
    },
  );

  testWidgets(
    'FirestoreDataTable with default dell dialog editor is render as expected',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        _dataTableBuilder(
          query: collection,
          cellBuilder: _defaultCellBuilder,
        ),
      );

      mockCtrl.add(mockQuerySnapshot);

      await tester.pumpAndSettle();

      final firstNameFinder = find.text(bob.firstName);
      expect(firstNameFinder, findsOneWidget);

      await tester.tap(firstNameFinder);
      await tester.pumpAndSettle();

      final dialogFinder = find.byType(Dialog);

      expect(dialogFinder, findsOneWidget);
    },
  );

  testWidgets(
    'FirestoreDataTable without default dell dialog editor is render as expected',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        _dataTableBuilder(
          query: collection,
          cellBuilder: _defaultCellBuilder,
          enableDefaultCellEditor: false,
        ),
      );

      mockCtrl.add(mockQuerySnapshot);

      await tester.pumpAndSettle();

      final firstNameFinder = find.text(bob.firstName);
      expect(firstNameFinder, findsOneWidget);

      //For some reason, we have a renderflex issue when tapping
      tester.view.physicalSize = const Size(1000, 2000);
      await tester.tap(firstNameFinder);
      await tester.pumpAndSettle();

      final dialogFinder = find.byType(Dialog);

      expect(dialogFinder, findsNothing);
    },
  );

  testWidgets(
    'FirestoreDataTable overide the default cell dialog editor is render as expected',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        _dataTableBuilder(
          query: collection,
          cellBuilder: _defaultCellBuilder,
          onTapCell: (doc, value, colKey) async {
            final person = Person.fromMap(doc.data);
            when(bobSnapshot.data).thenReturn(
              person
                  .copyWith(firstName: person.firstName.toUpperCase())
                  .toMap(),
            );

            mockCtrl.add(mockQuerySnapshot);
          },
        ),
      );

      mockCtrl.add(mockQuerySnapshot);

      await tester.pumpAndSettle();

      Finder firstNameFinder = find.text(bob.firstName);
      expect(firstNameFinder, findsOneWidget);

      //For some reason, we have a renderflex issue when tapping
      tester.view.physicalSize = const Size(1000, 2000);
      await tester.tap(firstNameFinder);
      await tester.pumpAndSettle();

      final upperCaseFinder = find.text(bob.firstName.toUpperCase());
      firstNameFinder = find.text(bob.firstName);

      expect(upperCaseFinder, findsOneWidget);
      expect(firstNameFinder, findsNothing);
    },
  );

  testWidgets(
    'FirestoreDataTable row selection is capture',
    (WidgetTester tester) async {
      //For some reason, we have a renderflex issue when tapping
      tester.view.physicalSize = const Size(1000, 2000);

      var nbItemSelected = 0;

      await tester.pumpWidget(
        _dataTableBuilder(
          query: collection,
          cellBuilder: _defaultCellBuilder,
          enableDefaultCellEditor: false,
          onSelectedRows: (selection) {
            nbItemSelected = selection.length;
          },
        ),
      );

      mockCtrl.add(mockQuerySnapshot);

      await tester.pumpAndSettle();

      final firstRowFinder = find.text(bob.firstName);
      expect(firstRowFinder, findsOneWidget);

      await tester.tap(firstRowFinder);
      await tester.pumpAndSettle();

      expect(nbItemSelected, 1);

      final secondRowFinder = find.text(bob2.firstName);
      expect(secondRowFinder, findsOneWidget);
      await tester.tap(secondRowFinder);
      await tester.pumpAndSettle();

      expect(nbItemSelected, 2);

      await tester.tap(firstRowFinder);
      await tester.tap(secondRowFinder);
      await tester.pumpAndSettle();

      expect(nbItemSelected, 0);
    },
  );
}

Widget _defaultCellBuilder(
  DocumentSnapshot doc,
  String colKey,
) {
  final person = Person.fromMap(doc.data);

  switch (ColumnKey.values.asNameMap()[colKey]) {
    case ColumnKey.firstName:
      return Text(person.firstName);
    case ColumnKey.address:
      return Row(
        children: [
          Text(person.address.street),
          Text(person.address.city),
        ],
      );
    default:
      return Container();
  }
}

Widget _dataTableBuilder({
  required Query query,
  CellBuilder? cellBuilder,
  bool enableDefaultCellEditor = true,
  OnTapCell? onTapCell,
  OnSelectedRows? onSelectedRows,
}) {
  return MaterialApp(
    home: FirestoreDataTable(
      query: query,
      columnLabels: {
        ColumnKey.firstName.name: const Text('First Name'),
        ColumnKey.address.name: const Text('Address'),
      },
      cellBuilder: cellBuilder,
      enableDefaultCellEditor: enableDefaultCellEditor,
      onTapCell: onTapCell,
      onSelectedRows: onSelectedRows,
    ),
  );
}

enum ColumnKey {
  firstName,
  address,
}

@immutable
class Person {
  const Person({
    required this.firstName,
    required this.address,
  });

  final String firstName;
  final Address address;

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'address': address.toMap(),
    };
  }

  factory Person.fromMap(Map<String, dynamic> map) {
    return Person(
      firstName: map['firstName'] ?? '',
      address: Address.fromMap(map['address']),
    );
  }

  Person copyWith({
    String? firstName,
    Address? address,
  }) {
    return Person(
      firstName: firstName ?? this.firstName,
      address: address ?? this.address,
    );
  }
}

@immutable
class Address {
  const Address({
    required this.street,
    required this.city,
  });

  final String street;
  final String city;

  Map<String, dynamic> toMap() {
    return {
      'street': street,
      'city': city,
    };
  }

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      street: map['street'] ?? '',
      city: map['city'] ?? '',
    );
  }
}

class MockFirestore extends Mock implements Firestore {}

class MockCollection extends Mock implements CollectionReference {
  @override
  Stream<QuerySnapshot> onSnapshot({
    bool includeMetadataChanges = false,
  }) {
    return super.noSuchMethod(
      Invocation.method(#snapshots, null, {
        #includeMetadataChanges: includeMetadataChanges,
      }),
      returnValue: Stream.fromIterable([
        MockQuerySnapshot(),
        MockQuerySnapshot(),
      ]),
      returnValueForMissingStub: Stream.fromIterable([
        MockQuerySnapshot(),
        MockQuerySnapshot(),
      ]),
    );
  }

  @override
  Future<int> count() {
    return super.noSuchMethod(
      Invocation.method(#count, null),
      returnValue: 2,
      returnValueForMissingStub: 2,
    );
  }

  @override
  Query limit([int? limit]) {
    return super.noSuchMethod(
      Invocation.method(
        #limit,
        [limit],
      ),
      returnValue: mockQuery,
      returnValueForMissingStub: mockQuery,
    );
  }
}

final collection = MockCollection();

class MockDocumentReference extends Mock implements DocumentReference {
  final Person person;

  MockDocumentReference(this.person);
}

class MockDocumentSnapshot extends Mock implements DocumentSnapshot {
  final Person person;

  MockDocumentSnapshot(this.person);

  @override
  DocumentReference get ref {
    return super.noSuchMethod(
      Invocation.getter(#reference),
      returnValue: MockDocumentReference(person),
      returnValueForMissingStub: MockDocumentReference(person),
    );
  }

  @override
  Map<String, Object?> get data {
    return super.noSuchMethod(
      Invocation.method(#data, null),
      returnValue: person.toMap(),
      returnValueForMissingStub: person.toMap(),
    );
  }
}

final bobSnapshot = MockDocumentSnapshot(bob);
final bob2Snapshot = MockDocumentSnapshot(bob2);

class MockQuerySnapshot extends Mock implements Snapshot {
  @override
  List<DocumentSnapshot> get docs {
    return super.noSuchMethod(
      Invocation.getter(#docs),
      returnValue: [
        bobSnapshot,
        bob2Snapshot,
      ],
      returnValueForMissingStub: [
        bobSnapshot,
        bob2Snapshot,
      ],
    );
  }
}

final mockQuerySnapshot = MockQuerySnapshot();
final mockCtrl = StreamController<Snapshot>.broadcast();

class MockQuery extends Mock implements Query {
  @override
  Stream<Snapshot> onSnapshot({
    bool? includeMetadataChanges = false,
  }) {
    return super.noSuchMethod(
      Invocation.method(#snapshots, null, {
        #includeMetadataChanges: includeMetadataChanges,
      }),
      returnValue: mockCtrl.stream,
      returnValueForMissingStub: mockCtrl.stream,
    );
  }
}

final mockQuery = MockQuery();
