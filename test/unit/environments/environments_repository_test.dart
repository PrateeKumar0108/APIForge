import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apiforge/core/storage/database/app_database.dart';
import 'package:apiforge/core/storage/secure_storage_service.dart';
import 'package:apiforge/features/environments/data/repositories/environments_repository_impl.dart';
import 'package:apiforge/features/environments/domain/models/environment_entity.dart';

class FakeSecureStorage implements ISecureStorageService {
  final Map<String, String> _vault = {};

  @override
  Future<void> writeSecret(String refId, String secret) async {
    _vault[refId] = secret;
  }

  @override
  Future<String?> readSecret(String refId) async {
    return _vault[refId];
  }

  @override
  Future<void> deleteSecret(String refId) async {
    _vault.remove(refId);
  }

  @override
  Future<void> deleteAllSecrets() async {
    _vault.clear();
  }
}

void main() {
  late AppDatabase db;
  late FakeSecureStorage secureStorage;
  late EnvironmentsRepositoryImpl repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    secureStorage = FakeSecureStorage();
    repo = EnvironmentsRepositoryImpl(db: db, secureStorage: secureStorage);
  });

  tearDown(() async {
    await db.close();
  });

  group('EnvironmentsRepository & Secret Storage Isolation', () {
    test(
      'creates environment and isolates secret variables into secure storage',
      () async {
        final env = await repo.createEnvironment(
          name: 'Staging',
          colorHex: '0xFFF59E0B',
          variables: [
            EnvironmentVariableEntity(
              key: 'baseUrl',
              value: 'https://staging.api.com',
            ),
            EnvironmentVariableEntity(
              key: 'jwtToken',
              value: 'secret-token-xyz',
              isSecret: true,
            ),
          ],
        );

        expect(env.id, isNotEmpty);
        expect(env.name, equals('Staging'));

        // Verify that SQLite database row contains EMPTY string for secret value
        final dbRows = await db.select(db.environmentVariables).get();
        final secretDbRow = dbRows.firstWhere((r) => r.key == 'jwtToken');
        expect(
          secretDbRow.value,
          equals(''),
          reason: 'Plaintext secret must never be stored in SQLite',
        );
        expect(secretDbRow.isSecret, isTrue);
        expect(secretDbRow.secretRefId, isNotNull);

        // Verify secret is written into secure storage
        final storedSecret = await secureStorage.readSecret(
          secretDbRow.secretRefId!,
        );
        expect(storedSecret, equals('secret-token-xyz'));

        // Retrieve via repository and verify secret is reconstituted
        final loadedEnvs = await repo.getEnvironments();
        final stagingLoaded = loadedEnvs.firstWhere((e) => e.id == env.id);
        final loadedToken = stagingLoaded.variables.firstWhere(
          (v) => v.key == 'jwtToken',
        );
        expect(loadedToken.value, equals('secret-token-xyz'));
      },
    );

    test(
      'deleting an environment deletes associated secrets from secure storage',
      () async {
        final env = await repo.createEnvironment(
          name: 'Ephemeral',
          variables: [
            EnvironmentVariableEntity(
              key: 'apiKey',
              value: 'ephemeral-secret-123',
              isSecret: true,
            ),
          ],
        );

        final dbRows = await db.select(db.environmentVariables).get();
        final refId = dbRows.first.secretRefId!;
        expect(
          await secureStorage.readSecret(refId),
          equals('ephemeral-secret-123'),
        );

        // Delete environment
        await repo.deleteEnvironment(env.id);

        // Verify SQLite is empty
        final allEnvs = await repo.getEnvironments();
        expect(allEnvs.isEmpty, isTrue);

        // Verify secure storage secret was wiped
        expect(await secureStorage.readSecret(refId), isNull);
      },
    );
  });
}
