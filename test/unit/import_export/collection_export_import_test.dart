import 'dart:convert';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apiforge/core/networking/request_models.dart';
import 'package:apiforge/core/storage/database/app_database.dart';
import 'package:apiforge/features/authentication/domain/models/auth_config.dart';
import 'package:apiforge/features/collections/data/repositories/collections_repository_impl.dart';
import 'package:apiforge/features/collections/domain/models/collection_entity.dart';
import 'package:apiforge/features/environments/domain/models/environment_entity.dart';
import 'package:apiforge/features/import_export/domain/services/collection_export_service.dart';
import 'package:apiforge/features/import_export/domain/services/collection_import_service.dart';

void main() {
  late AppDatabase db;
  late CollectionsRepositoryImpl repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = CollectionsRepositoryImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('CollectionExportService Tests', () {
    test(
      'exports collection to APIForge JSON v1 format and redacts sensitive credentials',
      () {
        final collection = CollectionEntity(
          id: 'col-1',
          workspaceId: 'default-workspace',
          name: 'Stripe Payments',
          description: 'Charges, refunds and webhooks',
          sortOrder: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final requests = [
          SavedRequestEntity(
            id: 'req-1',
            collectionId: 'col-1',
            name: 'Create Payment Intent',
            method: 'POST',
            url: 'https://api.stripe.com/v1/payment_intents',
            headers: [
              KeyValuePair(
                key: 'Content-Type',
                value: 'application/x-www-form-urlencoded',
              ),
              KeyValuePair(
                key: 'Authorization',
                value: 'Bearer sk_live_secret12345',
              ),
            ],
            queryParams: [KeyValuePair(key: 'customer', value: 'cus_999')],
            bodyType: BodyType.formUrlEncoded,
            formData: [
              KeyValuePair(key: 'amount', value: '5000'),
              KeyValuePair(key: 'currency', value: 'usd'),
            ],
            authType: 'bearer',
            authConfig: const AuthConfig(
              type: AuthType.bearer,
              token: 'sk_live_secret12345',
            ),
            sortOrder: 0,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        final jsonString = CollectionExportService.exportCollection(
          collection: collection,
          requests: requests,
        );

        expect(jsonString, isNotEmpty);
        final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
        expect(decoded['format'], equals('apiforge'));
        expect(decoded['version'], equals(1));
        expect(decoded['collection']['name'], equals('Stripe Payments'));

        final exportedReq =
            (decoded['collection']['requests'] as List).first
                as Map<String, dynamic>;
        expect(exportedReq['name'], equals('Create Payment Intent'));

        // Check header sanitization
        final headers = exportedReq['headers'] as List;
        final authHeader = headers.firstWhere(
          (h) => h['key'] == 'Authorization',
        );
        expect(authHeader['value'], equals('Bearer [REDACTED]'));

        // Check authConfig sanitization
        final authConfig = exportedReq['authConfig'] as Map<String, dynamic>;
        expect(authConfig['token'], equals('[REDACTED]'));
      },
    );

    test('exports environment and redacts secret variables', () {
      final env = EnvironmentEntity(
        id: 'env-prod',
        workspaceId: 'default-workspace',
        name: 'Production',
        colorHex: '0xFFEF4444',
        isDefault: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final vars = <EnvironmentVariableEntity>[
        EnvironmentVariableEntity(
          id: 'v-1',
          key: 'baseUrl',
          value: 'https://api.production.com',
          isSecret: false,
          isEnabled: true,
        ),
        EnvironmentVariableEntity(
          id: 'v-2',
          key: 'jwtSecret',
          value: 'my-super-secret-jwt-key',
          isSecret: true,
          isEnabled: true,
        ),
      ];

      final jsonString = CollectionExportService.exportEnvironment(
        environment: env,
        variables: vars,
      );

      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      expect(decoded['format'], equals('apiforge'));
      final exportedVars = decoded['environment']['variables'] as List;

      final publicVar = exportedVars.firstWhere((v) => v['key'] == 'baseUrl');
      expect(publicVar['value'], equals('https://api.production.com'));

      final secretVar = exportedVars.firstWhere((v) => v['key'] == 'jwtSecret');
      expect(secretVar['value'], equals('[SECRET_REDACTED]'));
    });
  });

  group('CollectionImportService Tests', () {
    test('parses APIForge JSON v1 and persists into SQLite', () async {
      final apiForgeJson = jsonEncode({
        'format': 'apiforge',
        'version': 1,
        'collection': {
          'name': 'Imported Store API',
          'description': 'Product endpoints',
          'requests': [
            {
              'name': 'Get Products',
              'method': 'GET',
              'url': 'https://fakestoreapi.com/products',
              'queryParams': [
                {'key': 'limit', 'value': '5', 'isEnabled': true},
              ],
              'headers': [
                {
                  'key': 'Accept',
                  'value': 'application/json',
                  'isEnabled': true,
                },
              ],
              'bodyType': 'none',
              'bodyContent': '',
            },
            {
              'name': 'Add Product',
              'method': 'POST',
              'url': 'https://fakestoreapi.com/products',
              'bodyType': 'json',
              'bodyContent': '{"title": "New Shoes", "price": 49.99}',
            },
          ],
        },
      });

      final importResult = CollectionImportService.parseCollection(
        apiForgeJson,
      );
      expect(importResult.collectionName, equals('Imported Store API'));
      expect(importResult.requests.length, equals(2));
      expect(importResult.requests.first.name, equals('Get Products'));
      expect(importResult.requests.first.queryParams.length, equals(1));
      expect(importResult.requests.last.bodyType, equals(BodyType.json));

      // Persist into database
      final createdCollection =
          await CollectionImportService.persistImportedCollection(
            repository: repo,
            importResult: importResult,
          );

      expect(createdCollection.id, isNotEmpty);
      expect(createdCollection.name, equals('Imported Store API'));

      final persistedRequests = await repo.getRequests(createdCollection.id);
      expect(persistedRequests.length, equals(2));
      expect(persistedRequests.first.name, equals('Get Products'));
      expect(persistedRequests.last.name, equals('Add Product'));
      expect(
        persistedRequests.last.bodyContent,
        equals('{"title": "New Shoes", "price": 49.99}'),
      );
    });

    test('rejects unsupported APIForge format versions', () {
      final invalidVersionJson = jsonEncode({
        'format': 'apiforge',
        'version': 99,
        'collection': {'name': 'Future Spec'},
      });

      expect(
        () => CollectionImportService.parseCollection(invalidVersionJson),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
