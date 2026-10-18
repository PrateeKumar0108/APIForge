import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Workspaces,
    Collections,
    Folders,
    SavedRequests,
    Environments,
    EnvironmentVariables,
    RequestHistoryEntries,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'apiforge_db',
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    );
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      // Seed default workspace
      await into(workspaces).insert(
        WorkspacesCompanion.insert(
          id: 'default-workspace',
          name: 'My Workspace',
          description: const Value('Default personal API testing workspace.'),
          createdAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ),
      );
    },
    beforeOpen: (details) async {
      // Enable SQLite Foreign Key cascades
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
