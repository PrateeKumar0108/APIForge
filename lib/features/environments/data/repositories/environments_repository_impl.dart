import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/storage/database/app_database.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/models/environment_entity.dart';
import '../../domain/repositories/environments_repository.dart';

/// Drift and FlutterSecureStorage implementation of [IEnvironmentsRepository].
class EnvironmentsRepositoryImpl implements IEnvironmentsRepository {
  final AppDatabase db;
  final ISecureStorageService secureStorage;

  EnvironmentsRepositoryImpl({required this.db, required this.secureStorage});

  @override
  Stream<List<EnvironmentEntity>> watchEnvironments({
    String workspaceId = 'default-workspace',
  }) {
    final query = db.select(db.environments)
      ..where((t) => t.workspaceId.equals(workspaceId))
      ..orderBy([(t) => OrderingTerm.asc(t.name)]);

    return query.watch().asyncMap((rows) async {
      final list = <EnvironmentEntity>[];
      for (final row in rows) {
        final variables = await _loadVariables(row.id);
        list.add(
          EnvironmentEntity(
            id: row.id,
            workspaceId: row.workspaceId,
            name: row.name,
            colorHex: row.colorHex,
            isDefault: row.isDefault,
            variables: variables,
            createdAt: row.createdAt,
            updatedAt: row.updatedAt,
          ),
        );
      }
      return list;
    });
  }

  @override
  Future<List<EnvironmentEntity>> getEnvironments({
    String workspaceId = 'default-workspace',
  }) async {
    final rows =
        await (db.select(db.environments)
              ..where((t) => t.workspaceId.equals(workspaceId))
              ..orderBy([(t) => OrderingTerm.asc(t.name)]))
            .get();

    final list = <EnvironmentEntity>[];
    for (final row in rows) {
      final variables = await _loadVariables(row.id);
      list.add(
        EnvironmentEntity(
          id: row.id,
          workspaceId: row.workspaceId,
          name: row.name,
          colorHex: row.colorHex,
          isDefault: row.isDefault,
          variables: variables,
          createdAt: row.createdAt,
          updatedAt: row.updatedAt,
        ),
      );
    }
    return list;
  }

  Future<List<EnvironmentVariableEntity>> _loadVariables(
    String environmentId,
  ) async {
    final rows = await (db.select(
      db.environmentVariables,
    )..where((t) => t.environmentId.equals(environmentId))).get();

    final vars = <EnvironmentVariableEntity>[];
    for (final row in rows) {
      String value = row.value;
      // If secret, decrypt/read from SecureStorage
      if (row.isSecret && row.secretRefId != null) {
        final secretVal = await secureStorage.readSecret(row.secretRefId!);
        value = secretVal ?? '';
      }

      vars.add(
        EnvironmentVariableEntity(
          id: row.id,
          key: row.key,
          value: value,
          isSecret: row.isSecret,
          secretRefId: row.secretRefId,
          isEnabled: row.isEnabled,
        ),
      );
    }
    return vars;
  }

  @override
  Future<EnvironmentEntity> createEnvironment({
    required String name,
    String colorHex = '0xFF10B981',
    String workspaceId = 'default-workspace',
    List<EnvironmentVariableEntity> variables = const [],
  }) async {
    final now = DateTime.now();
    final id = const Uuid().v4();

    await db
        .into(db.environments)
        .insert(
          EnvironmentsCompanion.insert(
            id: id,
            workspaceId: workspaceId,
            name: name,
            colorHex: Value(colorHex),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );

    for (final v in variables) {
      await saveVariable(id, v);
    }

    return EnvironmentEntity(
      id: id,
      workspaceId: workspaceId,
      name: name,
      colorHex: colorHex,
      variables: variables,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<void> updateEnvironment(EnvironmentEntity environment) async {
    await (db.update(
      db.environments,
    )..where((t) => t.id.equals(environment.id))).write(
      EnvironmentsCompanion(
        name: Value(environment.name),
        colorHex: Value(environment.colorHex),
        isDefault: Value(environment.isDefault),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> deleteEnvironment(String environmentId) async {
    await db.transaction(() async {
      // Find all secrets to clean up
      final vars = await (db.select(
        db.environmentVariables,
      )..where((t) => t.environmentId.equals(environmentId))).get();

      for (final v in vars) {
        if (v.isSecret && v.secretRefId != null) {
          await secureStorage.deleteSecret(v.secretRefId!);
        }
      }

      await (db.delete(
        db.environmentVariables,
      )..where((t) => t.environmentId.equals(environmentId))).go();
      await (db.delete(
        db.environments,
      )..where((t) => t.id.equals(environmentId))).go();
    });
  }

  @override
  Future<void> saveVariable(
    String environmentId,
    EnvironmentVariableEntity variable,
  ) async {
    String? secretRef = variable.secretRefId;
    String storedValue = variable.value;

    if (variable.isSecret) {
      secretRef ??= const Uuid().v4();
      await secureStorage.writeSecret(secretRef, variable.value);
      storedValue = ''; // Never store plaintext secret in SQLite database
    }

    final companion = EnvironmentVariablesCompanion(
      id: Value(variable.id),
      environmentId: Value(environmentId),
      key: Value(variable.key),
      value: Value(storedValue),
      isSecret: Value(variable.isSecret),
      secretRefId: Value(secretRef),
      isEnabled: Value(variable.isEnabled),
    );

    await db.into(db.environmentVariables).insertOnConflictUpdate(companion);
  }

  @override
  Future<void> deleteVariable(String variableId) async {
    final row = await (db.select(
      db.environmentVariables,
    )..where((t) => t.id.equals(variableId))).getSingleOrNull();
    if (row != null && row.isSecret && row.secretRefId != null) {
      await secureStorage.deleteSecret(row.secretRefId!);
    }
    await (db.delete(
      db.environmentVariables,
    )..where((t) => t.id.equals(variableId))).go();
  }

  @override
  Future<void> seedDefaultEnvironments({
    String workspaceId = 'default-workspace',
  }) async {
    final existing = await getEnvironments(workspaceId: workspaceId);
    if (existing.isNotEmpty) return;

    await createEnvironment(
      name: 'Local',
      colorHex: '0xFF10B981', // Emerald
      workspaceId: workspaceId,
      variables: [
        EnvironmentVariableEntity(
          key: 'baseUrl',
          value: 'http://localhost:8080',
        ),
        EnvironmentVariableEntity(key: 'apiVersion', value: 'v1'),
      ],
    );

    await createEnvironment(
      name: 'Development',
      colorHex: '0xFF3B82F6', // Blue
      workspaceId: workspaceId,
      variables: [
        EnvironmentVariableEntity(key: 'baseUrl', value: 'https://httpbin.org'),
        EnvironmentVariableEntity(
          key: 'token',
          value: 'dev-sample-token-123',
          isSecret: true,
        ),
      ],
    );

    await createEnvironment(
      name: 'Production',
      colorHex: '0xFFEF4444', // Red
      workspaceId: workspaceId,
      variables: [
        EnvironmentVariableEntity(
          key: 'baseUrl',
          value: 'https://api.github.com',
        ),
      ],
    );
  }
}
