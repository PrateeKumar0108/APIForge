import 'package:drift/drift.dart';

/// Workspaces table: top-level grouping for collections and environments.
class Workspaces extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get description => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Collections table: groups folders and saved requests.
class Collections extends Table {
  TextColumn get id => text()();
  TextColumn get workspaceId =>
      text().references(Workspaces, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get description => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Folders table: nested organization within collections.
class Folders extends Table {
  TextColumn get id => text()();
  TextColumn get collectionId =>
      text().references(Collections, #id, onDelete: KeyAction.cascade)();
  TextColumn get parentFolderId =>
      text().nullable().references(Folders, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// SavedRequests table: persisted API request specifications.
class SavedRequests extends Table {
  TextColumn get id => text()();
  TextColumn get collectionId =>
      text().references(Collections, #id, onDelete: KeyAction.cascade)();
  TextColumn get folderId =>
      text().nullable().references(Folders, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text().withLength(min: 1, max: 150)();
  TextColumn get description => text().nullable()();
  TextColumn get method => text().withLength(min: 1, max: 10)();
  TextColumn get url => text()();
  TextColumn get queryParamsJson => text().withDefault(const Constant('[]'))();
  TextColumn get headersJson => text().withDefault(const Constant('[]'))();
  TextColumn get bodyType => text().withDefault(const Constant('none'))();
  TextColumn get bodyContent => text().withDefault(const Constant(''))();
  TextColumn get formDataJson => text().withDefault(const Constant('[]'))();
  TextColumn get authType => text().withDefault(const Constant('none'))();
  TextColumn get authConfigJson => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Environments table: Local, Staging, Production, etc.
class Environments extends Table {
  TextColumn get id => text()();
  TextColumn get workspaceId =>
      text().references(Workspaces, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text().withLength(min: 1, max: 80)();
  TextColumn get colorHex => text().withDefault(const Constant('0xFF10B981'))();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// EnvironmentVariables table: variables and secure secrets.
class EnvironmentVariables extends Table {
  TextColumn get id => text()();
  TextColumn get environmentId =>
      text().references(Environments, #id, onDelete: KeyAction.cascade)();
  TextColumn get key => text().withLength(min: 1, max: 100)();
  TextColumn get value => text().withDefault(const Constant(''))();
  BoolColumn get isSecret => boolean().withDefault(const Constant(false))();
  TextColumn get secretRefId => text().nullable()();
  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

/// RequestHistoryEntries table: request/response audit logs.
class RequestHistoryEntries extends Table {
  TextColumn get id => text()();
  TextColumn get method => text()();
  TextColumn get url => text()();
  IntColumn get statusCode => integer()();
  TextColumn get statusMessage => text().withDefault(const Constant(''))();
  IntColumn get durationMs => integer()();
  IntColumn get contentLengthBytes =>
      integer().withDefault(const Constant(0))();
  TextColumn get headersJson => text().withDefault(const Constant('[]'))();
  TextColumn get responseHeadersJson =>
      text().withDefault(const Constant('{}'))();
  TextColumn get bodyContent => text().nullable()();
  DateTimeColumn get executedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
