// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'embedded_objects.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

class Parent extends _Parent with RealmEntity, RealmObject {
  Parent({
    Child1? child,
    Iterable<Child1> children = const [],
  }) {
    RealmObject.set(this, 'child', child);
    RealmObject.set<RealmList<Child1>>(
        this, 'children', RealmList<Child1>(children));
  }

  Parent._();

  @override
  Child1? get child => RealmObject.get<Child1>(this, 'child') as Child1?;
  @override
  set child(covariant Child1? value) => RealmObject.set(this, 'child', value);

  @override
  RealmList<Child1> get children =>
      RealmObject.get<Child1>(this, 'children') as RealmList<Child1>;
  @override
  set children(covariant RealmList<Child1> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<Parent>> get changes =>
      RealmObject.getChanges<Parent>(this);

  @override
  Parent freeze() => RealmObject.freezeObject<Parent>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObject.registerFactory(Parent._);
    return const SchemaObject(
        Parent,
        'Parent',
        [
          SchemaProperty('child', RealmPropertyType.object,
              optional: true, linkTarget: 'Child1'),
          SchemaProperty('children', RealmPropertyType.object,
              linkTarget: 'Child1', collectionType: RealmCollectionType.list),
        ],
        RealmModelType.realmObject);
  }
}

class Child1 extends _Child1 with RealmEntity, RealmObject {
  Child1(
    String value, {
    Child2? child,
    Parent? linkToParent,
    Iterable<Child2> children = const [],
  }) {
    RealmObject.set(this, 'value', value);
    RealmObject.set(this, 'child', child);
    RealmObject.set(this, 'linkToParent', linkToParent);
    RealmObject.set<RealmList<Child2>>(
        this, 'children', RealmList<Child2>(children));
  }

  Child1._();

  @override
  String get value => RealmObject.get<String>(this, 'value') as String;
  @override
  set value(String value) => RealmObject.set(this, 'value', value);

  @override
  Child2? get child => RealmObject.get<Child2>(this, 'child') as Child2?;
  @override
  set child(covariant Child2? value) => RealmObject.set(this, 'child', value);

  @override
  RealmList<Child2> get children =>
      RealmObject.get<Child2>(this, 'children') as RealmList<Child2>;
  @override
  set children(covariant RealmList<Child2> value) =>
      throw RealmUnsupportedSetError();

  @override
  Parent? get linkToParent =>
      RealmObject.get<Parent>(this, 'linkToParent') as Parent?;
  @override
  set linkToParent(covariant Parent? value) =>
      RealmObject.set(this, 'linkToParent', value);

  @override
  Stream<RealmObjectChanges<Child1>> get changes =>
      RealmObject.getChanges<Child1>(this);

  @override
  Child1 freeze() => RealmObject.freezeObject<Child1>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObject.registerFactory(Child1._);
    return const SchemaObject(
        Child1,
        'Child1',
        [
          SchemaProperty('value', RealmPropertyType.string),
          SchemaProperty('child', RealmPropertyType.object,
              optional: true, linkTarget: 'Child2'),
          SchemaProperty('children', RealmPropertyType.object,
              linkTarget: 'Child2', collectionType: RealmCollectionType.list),
          SchemaProperty('linkToParent', RealmPropertyType.object,
              optional: true, linkTarget: 'Parent'),
        ],
        RealmModelType.embedded);
  }
}

class Child2 extends _Child2 with RealmEntity, RealmObject {
  Child2(
    bool boolProp,
    int intProp,
    double doubleProp,
    String stringProp,
    DateTime dateProp,
    ObjectId objectIdProp,
    Uuid uuidProp, {
    bool? nullableBoolProp,
    int? nullableIntProp,
    double? nullableDoubleProp,
    String? nullableStringProp,
    DateTime? nullableDateProp,
    ObjectId? nullableObjectIdProp,
    Uuid? nullableUuidProp,
  }) {
    RealmObject.set(this, 'boolProp', boolProp);
    RealmObject.set(this, 'intProp', intProp);
    RealmObject.set(this, 'doubleProp', doubleProp);
    RealmObject.set(this, 'stringProp', stringProp);
    RealmObject.set(this, 'dateProp', dateProp);
    RealmObject.set(this, 'objectIdProp', objectIdProp);
    RealmObject.set(this, 'uuidProp', uuidProp);
    RealmObject.set(this, 'nullableBoolProp', nullableBoolProp);
    RealmObject.set(this, 'nullableIntProp', nullableIntProp);
    RealmObject.set(this, 'nullableDoubleProp', nullableDoubleProp);
    RealmObject.set(this, 'nullableStringProp', nullableStringProp);
    RealmObject.set(this, 'nullableDateProp', nullableDateProp);
    RealmObject.set(this, 'nullableObjectIdProp', nullableObjectIdProp);
    RealmObject.set(this, 'nullableUuidProp', nullableUuidProp);
  }

  Child2._();

  @override
  bool get boolProp => RealmObject.get<bool>(this, 'boolProp') as bool;
  @override
  set boolProp(bool value) => RealmObject.set(this, 'boolProp', value);

  @override
  int get intProp => RealmObject.get<int>(this, 'intProp') as int;
  @override
  set intProp(int value) => RealmObject.set(this, 'intProp', value);

  @override
  double get doubleProp =>
      RealmObject.get<double>(this, 'doubleProp') as double;
  @override
  set doubleProp(double value) => RealmObject.set(this, 'doubleProp', value);

  @override
  String get stringProp =>
      RealmObject.get<String>(this, 'stringProp') as String;
  @override
  set stringProp(String value) => RealmObject.set(this, 'stringProp', value);

  @override
  DateTime get dateProp =>
      RealmObject.get<DateTime>(this, 'dateProp') as DateTime;
  @override
  set dateProp(DateTime value) => RealmObject.set(this, 'dateProp', value);

  @override
  ObjectId get objectIdProp =>
      RealmObject.get<ObjectId>(this, 'objectIdProp') as ObjectId;
  @override
  set objectIdProp(ObjectId value) =>
      RealmObject.set(this, 'objectIdProp', value);

  @override
  Uuid get uuidProp => RealmObject.get<Uuid>(this, 'uuidProp') as Uuid;
  @override
  set uuidProp(Uuid value) => RealmObject.set(this, 'uuidProp', value);

  @override
  bool? get nullableBoolProp =>
      RealmObject.get<bool>(this, 'nullableBoolProp') as bool?;
  @override
  set nullableBoolProp(bool? value) =>
      RealmObject.set(this, 'nullableBoolProp', value);

  @override
  int? get nullableIntProp =>
      RealmObject.get<int>(this, 'nullableIntProp') as int?;
  @override
  set nullableIntProp(int? value) =>
      RealmObject.set(this, 'nullableIntProp', value);

  @override
  double? get nullableDoubleProp =>
      RealmObject.get<double>(this, 'nullableDoubleProp') as double?;
  @override
  set nullableDoubleProp(double? value) =>
      RealmObject.set(this, 'nullableDoubleProp', value);

  @override
  String? get nullableStringProp =>
      RealmObject.get<String>(this, 'nullableStringProp') as String?;
  @override
  set nullableStringProp(String? value) =>
      RealmObject.set(this, 'nullableStringProp', value);

  @override
  DateTime? get nullableDateProp =>
      RealmObject.get<DateTime>(this, 'nullableDateProp') as DateTime?;
  @override
  set nullableDateProp(DateTime? value) =>
      RealmObject.set(this, 'nullableDateProp', value);

  @override
  ObjectId? get nullableObjectIdProp =>
      RealmObject.get<ObjectId>(this, 'nullableObjectIdProp') as ObjectId?;
  @override
  set nullableObjectIdProp(ObjectId? value) =>
      RealmObject.set(this, 'nullableObjectIdProp', value);

  @override
  Uuid? get nullableUuidProp =>
      RealmObject.get<Uuid>(this, 'nullableUuidProp') as Uuid?;
  @override
  set nullableUuidProp(Uuid? value) =>
      RealmObject.set(this, 'nullableUuidProp', value);

  @override
  Stream<RealmObjectChanges<Child2>> get changes =>
      RealmObject.getChanges<Child2>(this);

  @override
  Child2 freeze() => RealmObject.freezeObject<Child2>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObject.registerFactory(Child2._);
    return const SchemaObject(
        Child2,
        'Child2',
        [
          SchemaProperty('boolProp', RealmPropertyType.bool),
          SchemaProperty('intProp', RealmPropertyType.int),
          SchemaProperty('doubleProp', RealmPropertyType.double),
          SchemaProperty('stringProp', RealmPropertyType.string),
          SchemaProperty('dateProp', RealmPropertyType.timestamp),
          SchemaProperty('objectIdProp', RealmPropertyType.objectid),
          SchemaProperty('uuidProp', RealmPropertyType.uuid),
          SchemaProperty('nullableBoolProp', RealmPropertyType.bool,
              optional: true),
          SchemaProperty('nullableIntProp', RealmPropertyType.int,
              optional: true),
          SchemaProperty('nullableDoubleProp', RealmPropertyType.double,
              optional: true),
          SchemaProperty('nullableStringProp', RealmPropertyType.string,
              optional: true),
          SchemaProperty('nullableDateProp', RealmPropertyType.timestamp,
              optional: true),
          SchemaProperty('nullableObjectIdProp', RealmPropertyType.objectid,
              optional: true),
          SchemaProperty('nullableUuidProp', RealmPropertyType.uuid,
              optional: true),
        ],
        RealmModelType.embedded);
  }
}
