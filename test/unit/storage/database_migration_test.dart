import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apiforge/core/storage/database/app_database.dart';

void main() {
  group('Database Schema & Seeding', () {
    test('initializes schema version 1 and seeds default workspace', () async {
      final db = AppDatabase(NativeDatabase.memory());

      expect(db.schemaVersion, equals(1));

      // Trigger database creation by querying workspaces
      final workspaces = await db.select(db.workspaces).get();

      expect(workspaces.length, equals(1));
      expect(workspaces.first.id, equals('default-workspace'));
      expect(workspaces.first.name, equals('My Workspace'));

      await db.close();
    });
  });
}
