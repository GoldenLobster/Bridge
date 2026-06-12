import 'package:drift/drift.dart';

class Devices extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get platform => text()();
  TextColumn get ip => text()();
  IntColumn get port => integer()();
  DateTimeColumn get lastSeen => dateTime()();
  BoolColumn get isPaired => boolean()();

  @override
  Set<Column> get primaryKey => {id};
}

class Transfers extends Table {
  TextColumn get id => text()();
  TextColumn get deviceId => text()();
  TextColumn get fileName => text()();
  IntColumn get fileSize => integer()();
  TextColumn get direction => text()();
  TextColumn get status => text()();
  DateTimeColumn get timestamp => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Notifications extends Table {
  TextColumn get id => text()();
  TextColumn get deviceId => text()();
  TextColumn get app => text()();
  TextColumn get title => text()();
  TextColumn get body => text()();
  DateTimeColumn get timestamp => dateTime()();
  BoolColumn get dismissed => boolean()();

  @override
  Set<Column> get primaryKey => {id};
}

class Messages extends Table {
  TextColumn get id => text()();
  TextColumn get deviceId => text()();
  TextColumn get address => text()();
  TextColumn get body => text()();
  TextColumn get direction => text()();
  DateTimeColumn get timestamp => dateTime()();
  BoolColumn get readStatus => boolean()();

  @override
  Set<Column> get primaryKey => {id};
}

class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
