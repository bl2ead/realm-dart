////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2022 Realm Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////

import 'dart:typed_data';

import 'package:test/test.dart' hide test, throws;
import '../lib/realm.dart';

import 'test.dart';

part 'realm_set_test.g.dart';

class _NullableBool {}

class _NullableInt {}

class _NullableString {}

class _NullableDouble {}

class _NullableDateTime {}

class _NullableObjectId {}

class _NullableUuid {}

class _NullableObjects {}

/// When changing update also `setByType`
List<Type> supportedTypes = [
  bool,
  int,
  String,
  double,
  DateTime,
  ObjectId,
  Uuid,
  RealmValue,
  RealmObject,
  _NullableBool,
  _NullableInt,
  _NullableString,
  _NullableDouble,
  _NullableDateTime,
  _NullableObjectId,
  _NullableUuid
];

@RealmModel()
class _Car {
  @PrimaryKey()
  late String make;
}

@RealmModel()
class _TestRealmSets {
  @PrimaryKey()
  late int key;

  late Set<bool> boolSet;
  late Set<int> intSet;
  late Set<String> stringSet;
  late Set<double> doubleSet;
  late Set<DateTime> dateTimeSet;
  late Set<ObjectId> objectIdSet;
  late Set<Uuid> uuidSet;
  late Set<RealmValue> mixedSet;
  late Set<_Car> objectsSet;

  late Set<bool?> nullableBoolSet;
  late Set<int?> nullableIntSet;
  late Set<String?> nullableStringSet;
  late Set<double?> nullableDoubleSet;
  late Set<DateTime?> nullableDateTimeSet;
  late Set<ObjectId?> nullableObjectIdSet;
  late Set<Uuid?> nullableUuidSet;
}

extension TestRealmSetsExtension on TestRealmSets {
  RealmSet<Object?> getSetByType(Type type) {
    switch (type) {
      case bool:
        return boolSet;
      case int:
        return intSet;
      case String:
        return stringSet;
      case double:
        return doubleSet;
      case DateTime:
        return dateTimeSet;
      case ObjectId:
        return objectIdSet;
      case Uuid:
        return uuidSet;
      case RealmValue:
        return mixedSet;
      case RealmObject:
        return objectsSet;
      case _NullableBool:
        return nullableBoolSet;
      case _NullableInt:
        return nullableIntSet;
      case _NullableString:
        return nullableStringSet;
      case _NullableDouble:
        return nullableDoubleSet;
      case _NullableDateTime:
        return nullableDateTimeSet;
      case _NullableObjectId:
        return nullableObjectIdSet;
      case _NullableUuid:
        return nullableUuidSet;
      default:
        throw RealmError("Unsupported type $type");
    }
  }
}

List<Object?> createSampleValues(Type type) {
  switch (type) {
    case bool:
      return [true, false];
    case int:
      return [-1, 0, 1];
    case String:
      return ['Tesla', 'VW', 'Audi'];
    case double:
      return [-1.1, 0.1, 1.1, 2.2, 3.3, 3.14];
    case DateTime:
      return [DateTime(2023).toUtc(), DateTime(1981).toUtc()];
    case ObjectId:
      return [ObjectId.fromTimestamp(DateTime(2023).toUtc()), ObjectId.fromTimestamp(DateTime(1981).toUtc())];
    case Uuid:
      return [Uuid.fromString("12345678123456781234567812345678"), Uuid.fromString("82345678123456781234567812345678")];
    case RealmValue:
      return [RealmValue.nullValue(), RealmValue.bool(true), RealmValue.int(1), RealmValue.string("text")];
    case RealmObject:
      return [Car("Tesla"), Car("VW"), Car("Audi")];
    case _NullableBool:
      return [...createSampleValues(bool), null];
    case _NullableInt:
      return [...createSampleValues(int), null];
    case _NullableString:
      return [...createSampleValues(String), null];
    case _NullableDouble:
      return [...createSampleValues(double), null];
    case _NullableDateTime:
      return [...createSampleValues(DateTime), null];
    case _NullableObjectId:
      return [...createSampleValues(ObjectId), null];
    case _NullableUuid:
      return [...createSampleValues(Uuid), null];
    default:
      throw RealmError("Unsupported type $type");
  }
}

Future<void> main([List<String>? args]) async {
  await setupTests(args);

  for (var type in supportedTypes) {
    test('RealmSet<$type> unmanged set add', () {
      final testSet = TestRealmSets(1);
      final set = testSet.getSetByType(type);
      final values = createSampleValues(type);

      set.add(values.first);
      expect(set.length, equals(1));
      expect(set.contains(values.first), true);

      set.remove(values.first);
      expect(set.length, equals(0));
      expect(set.contains(values.first), false);
    });

    test('RealmSet<$type> unmanged set remove', () {
      final testSet = TestRealmSets(1);
      final set = testSet.getSetByType(type);
      final values = createSampleValues(type);

      set.add(values.first);
      expect(set.length, equals(1));
      expect(set.contains(values.first), true);

      set.remove(values.first);
      expect(set.length, equals(0));
      expect(set.contains(values.first), false);
    });

    test('RealmSet<$type> unmanged set elementAt', () {
      final testSet = TestRealmSets(1);
      final set = testSet.getSetByType(type);
      final values = createSampleValues(type);

      set.add(values.first);
      expect(set.length, equals(1));
      expect(set.elementAt(0), values.first);
    });

    test('RealmSet<$type> create', () {
      var config = Configuration.local([TestRealmSets.schema, Car.schema]);
      var realm = getRealm(config);

      var testSet = TestRealmSets(1);

      realm.write(() {
        realm.add(testSet);
      });

      expect(realm.find<TestRealmSets>(1), isNotNull);

      testSet = realm.find<TestRealmSets>(1)!;
      var set = testSet.getSetByType(type);

      expect(set.length, equals(0));
    });

    test('RealmSet<$type> create from unmanaged', () {
      var config = Configuration.local([TestRealmSets.schema, Car.schema]);
      var realm = getRealm(config);

      var testSet = TestRealmSets(1);
      var set = testSet.getSetByType(type);
      var values = createSampleValues(type);

      for (var value in values) {
        set.add(value);
      }

      realm.write(() {
        realm.add(testSet);
      });

      testSet = realm.find<TestRealmSets>(1)!;
      set = testSet.getSetByType(type);
      expect(set.length, equals(values.length));

      for (var value in values) {
        expect(set.contains(value), true);
      }
    });

    test('RealmSet<$type> contains', () {
      var config = Configuration.local([TestRealmSets.schema, Car.schema]);
      var realm = getRealm(config);

      var testSet = TestRealmSets(1);
      var set = testSet.getSetByType(type);
      var values = createSampleValues(type);

      realm.write(() {
        realm.add(testSet);
      });

      set = testSet.getSetByType(type);

      expect(set.contains(values.first), false);

      realm.write(() {
        set.add(values.first);
      });

      testSet = realm.find<TestRealmSets>(1)!;
      set = testSet.getSetByType(type);
      expect(set.contains(values.first), true);
    });

    test('RealmSet<$type> add', () {
      var config = Configuration.local([TestRealmSets.schema, Car.schema]);
      var realm = getRealm(config);

      final testSet = TestRealmSets(1);

      var values = createSampleValues(type);

      realm.write(() {
        realm.add(testSet);
        var set = testSet.getSetByType(type);
        set.add(values.first);
      });

      var set = testSet.getSetByType(type);

      expect(set.contains(values.first), true);
    });

    test('RealmSet<$type> remove', () {
      var config = Configuration.local([TestRealmSets.schema, Car.schema]);
      var realm = getRealm(config);

      var testSet = TestRealmSets(1);

      realm.write(() {
        realm.add(testSet);
      });

      var set = testSet.getSetByType(type);
      var values = createSampleValues(type);

      realm.write(() {
        set.add(values.first);
      });

      expect(set.length, 1);

      realm.write(() {
        expect(set.remove(values.first), true);
      });

      expect(set.length, 0);
    });

    test('RealmSet<$type> length', () {
      var config = Configuration.local([TestRealmSets.schema, Car.schema]);
      var realm = getRealm(config);

      final testSet = TestRealmSets(1);
      realm.write(() {
        realm.add(testSet);
      });

      var set = testSet.getSetByType(type);
      var values = createSampleValues(type);

      expect(set.length, 0);

      realm.write(() {
        set.add(values.first);
      });

      expect(set.length, 1);

      realm.write(() {
        for (var value in values) {
          set.add(value);
        }
      });

      expect(set.length, values.length);
    });

    test('RealmSet<$type> elementAt', () {
      var config = Configuration.local([TestRealmSets.schema, Car.schema]);
      var realm = getRealm(config);

      final testSet = TestRealmSets(1);
      var values = createSampleValues(type);

      realm.write(() {
        realm.add(testSet);
        var set = testSet.getSetByType(type);
        set.add(values.first);
      });

      var set = testSet.getSetByType(type);

      expect(() => set.elementAt(-1), throws<RealmException>("Index out of range"));
      expect(() => set.elementAt(800), throws<RealmException>());
      expect(set.elementAt(0), values[0]);
    });

    test('RealmSet<$type> lookup', () {
      var config = Configuration.local([TestRealmSets.schema, Car.schema]);
      var realm = getRealm(config);

      final testSet = TestRealmSets(1);
      realm.write(() {
        realm.add(testSet);
      });

      var set = testSet.getSetByType(type);
      var values = createSampleValues(type);

      expect(set.lookup(values.first), null);

      realm.write(() {
        set.add(values.first);
      });

      expect(set.lookup(values.first), values.first);
    });

    test('RealmSet<$type> toSet', () {
      var config = Configuration.local([TestRealmSets.schema, Car.schema]);
      var realm = getRealm(config);

      final testSet = TestRealmSets(1);
      var set = testSet.getSetByType(type);
      var values = createSampleValues(type);
      set.add(values.first);

      realm.write(() {
        realm.add(testSet);
      });

      set = testSet.getSetByType(type);

      final newSet = set.toSet();
      expect(newSet != set, true);
      newSet.add(values[1]);
      expect(newSet.length, 2);
      expect(set.length, 1);
    });

    test('RealmSet<$type> clear', () {
      var config = Configuration.local([TestRealmSets.schema, Car.schema]);
      var realm = getRealm(config);

      final testSet = TestRealmSets(1);
      var values = createSampleValues(type);

      realm.write(() {
        realm.add(testSet);
        var set = testSet.getSetByType(type);
        for (var value in values) {
          set.add(value);
        }
      });

      var set = testSet.getSetByType(type);

      expect(set.length, values.length);

      realm.write(() {
        set.clear();
      });

      expect(set.length, 0);
    });

    test('RealmSet<$type> iterator', () {
      var config = Configuration.local([TestRealmSets.schema, Car.schema]);
      var realm = getRealm(config);

      var testSet = TestRealmSets(1);
      var set = testSet.getSetByType(type);
      var values = createSampleValues(type);

      for (var value in values) {
        set.add(value);
      }

      realm.write(() {
        realm.add(testSet);
      });

      set = testSet.getSetByType(type);
      expect(set.length, equals(values.length));

      for (var element in set) {
        expect(values.contains(element), true);
      }
    });

    test('RealmSet<$type> notifications', () async {
      var config = Configuration.local([TestRealmSets.schema, Car.schema]);
      var realm = getRealm(config);

      var testSet = TestRealmSets(1);
      realm.write(() => realm.add(testSet));

      var set = testSet.getSetByType(type);
      var values = createSampleValues(type);

      var state = 0;
      final maxSate = 2;
      final subscription = set.changes.listen((changes) {
        if (state == 0) {
          expect(changes.inserted.isEmpty, true);
          expect(changes.modified.isEmpty, true);
          expect(changes.deleted.isEmpty, true);
          expect(changes.newModified.isEmpty, true);
          expect(changes.moved.isEmpty, true);
        } else if (state == 1) {
          expect(changes.inserted, [0]); //new object at index 0
          expect(changes.modified.isEmpty, true);
          expect(changes.deleted.isEmpty, true);
          expect(changes.newModified.isEmpty, true);
          expect(changes.moved.isEmpty, true);
        } else if (state == 2) {
          expect(changes.inserted.isEmpty, true); //new object at index 0
          expect(changes.modified.isEmpty, true);
          expect(changes.deleted, [0]);
          expect(changes.newModified.isEmpty, true);
          expect(changes.moved.isEmpty, true);
        }
        state++;
      });

      await Future<void>.delayed(Duration(milliseconds: 20));
      realm.write(() {
        set.add(values.first);
      });

      await Future<void>.delayed(Duration(milliseconds: 20));
      realm.write(() {
        set.remove(values.first);
      });

      expect(state, maxSate);

      await Future<void>.delayed(Duration(milliseconds: 20));
      subscription.cancel();

      await Future<void>.delayed(Duration(milliseconds: 20));
    });
  }

  test('RealmSet<RealmObject> deleteAll', () {
    var config = Configuration.local([TestRealmSets.schema, Car.schema]);
    var realm = getRealm(config);

    var testSet = TestRealmSets(1)..objectsSet.addAll([Car("Tesla"), Car("Audi")]);

    realm.write(() {
      realm.add(testSet);
    });

    expect(realm.find<TestRealmSets>(1), isNotNull);

    testSet = realm.find<TestRealmSets>(1)!;
    expect(testSet.objectsSet.length, 2);
    expect(realm.all<Car>().length, 2);

    realm.write(() {
      testSet.objectsSet.deleteAll();
    });

    expect(testSet.objectsSet.length, 0);
    expect(realm.all<Car>().length, 0);
  });
}
