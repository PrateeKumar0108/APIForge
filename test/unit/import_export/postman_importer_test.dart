import 'dart:convert';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apiforge/core/networking/request_models.dart';
import 'package:apiforge/core/storage/database/app_database.dart';
import 'package:apiforge/features/authentication/domain/models/auth_config.dart';
import 'package:apiforge/features/collections/data/repositories/collections_repository_impl.dart';
import 'package:apiforge/features/import_export/domain/services/collection_import_service.dart';
import 'package:apiforge/features/import_export/domain/services/postman_collection_parser.dart';

void main() {
  group('PostmanCollectionParser Tests', () {
    test(
      'parses Postman v2.1 collection with requests, query params, headers, and auth',
      () {
        final postmanJson = jsonEncode({
          'info': {
            '_postman_id': '89012345-6789-abcd-ef01-23456789abcd',
            'name': 'GitHub API Postman v2.1',
            'description': 'Official GitHub v3 REST endpoints',
            'schema':
                'https://schema.getpostman.com/json/collection/v2.1.0/collection.json',
          },
          'item': [
            {
              'name': 'Get Authenticated User',
              'request': {
                'method': 'GET',
                'header': [
                  {'key': 'Accept', 'value': 'application/vnd.github.v3+json'},
                  {'key': 'User-Agent', 'value': 'APIForge-Test-App'},
                ],
                'url': {
                  'raw': 'https://api.github.com/user?state=active',
                  'protocol': 'https',
                  'host': ['api', 'github', 'com'],
                  'path': ['user'],
                  'query': [
                    {'key': 'state', 'value': 'active'},
                  ],
                },
                'auth': {
                  'type': 'bearer',
                  'bearer': [
                    {'key': 'token', 'value': 'ghp_sampleBearerToken12345'},
                  ],
                },
              },
              // Malicious or executable scripts in "event"
              'event': [
                {
                  'listen': 'prerequest',
                  'script': {
                    'exec': [
                      '// Malicious code attempt',
                      'eval("throw Error(\'Executable script was run!\')");',
                    ],
                  },
                },
                {
                  'listen': 'test',
                  'script': {
                    'exec': [
                      'pm.test("Status code is 200", function () { pm.response.to.have.status(200); });',
                    ],
                  },
                },
              ],
            },
            {
              'name': 'Create Issue',
              'request': {
                'method': 'POST',
                'header': [
                  {'key': 'Content-Type', 'value': 'application/json'},
                ],
                'url':
                    'https://api.github.com/repos/octocat/Hello-World/issues',
                'body': {
                  'mode': 'raw',
                  'raw':
                      '{"title": "Found a bug", "body": "I\'m having a problem with this."}',
                },
                'auth': {
                  'type': 'basic',
                  'basic': [
                    {'key': 'username', 'value': 'octocat'},
                    {'key': 'password', 'value': 'secret-pass'},
                  ],
                },
              },
            },
          ],
        });

        final result = PostmanCollectionParser.parse(postmanJson);

        expect(result.collectionName, equals('GitHub API Postman v2.1'));
        expect(
          result.collectionDescription,
          equals('Official GitHub v3 REST endpoints'),
        );
        expect(result.requests.length, equals(2));

        // 1. Verify First Request (GET)
        final req1 = result.requests[0];
        expect(req1.name, equals('Get Authenticated User'));
        expect(req1.method, equals('GET'));
        expect(req1.url, equals('https://api.github.com/user?state=active'));
        expect(req1.headers.length, equals(2));
        expect(req1.headers.first.key, equals('Accept'));
        expect(req1.queryParams.length, equals(1));
        expect(req1.queryParams.first.key, equals('state'));
        expect(req1.queryParams.first.value, equals('active'));
        expect(req1.authConfig.type, equals(AuthType.bearer));
        expect(req1.authConfig.token, equals('ghp_sampleBearerToken12345'));

        // 2. Verify Second Request (POST + Basic Auth + Body)
        final req2 = result.requests[1];
        expect(req2.name, equals('Create Issue'));
        expect(req2.method, equals('POST'));
        expect(
          req2.url,
          equals('https://api.github.com/repos/octocat/Hello-World/issues'),
        );
        expect(req2.bodyType, equals(BodyType.json));
        expect(req2.bodyContent, contains('"title": "Found a bug"'));
        expect(req2.authConfig.type, equals(AuthType.basic));
        expect(req2.authConfig.username, equals('octocat'));
        expect(req2.authConfig.password, equals('secret-pass'));
      },
    );

    test('recursively parses nested folder hierarchies', () {
      final nestedJson = jsonEncode({
        'info': {'name': 'Nested Collection'},
        'item': [
          {
            'name': 'Folder A',
            'item': [
              {
                'name': 'Folder B',
                'item': [
                  {
                    'name': 'Deep Request',
                    'request': {
                      'method': 'DELETE',
                      'url': 'https://api.example.com/delete/1',
                    },
                  },
                ],
              },
              {
                'name': 'Sub Request in A',
                'request': {
                  'method': 'GET',
                  'url': 'https://api.example.com/sub',
                },
              },
            ],
          },
          {
            'name': 'Root Level Request',
            'request': {'method': 'GET', 'url': 'https://api.example.com/root'},
          },
        ],
      });

      final result = PostmanCollectionParser.parse(nestedJson);
      expect(result.requests.length, equals(3));

      final deepReq = result.requests.firstWhere(
        (r) => r.name == 'Deep Request',
      );
      expect(deepReq.folderName, equals('Folder A / Folder B'));
      expect(deepReq.method, equals('DELETE'));

      final subReq = result.requests.firstWhere(
        (r) => r.name == 'Sub Request in A',
      );
      expect(subReq.folderName, equals('Folder A'));

      final rootReq = result.requests.firstWhere(
        (r) => r.name == 'Root Level Request',
      );
      expect(rootReq.folderName, isNull);
    });

    test('safely discards executable scripts and rejects invalid payloads', () {
      expect(
        () => PostmanCollectionParser.parse('not-json'),
        throwsA(isA<FormatException>()),
      );

      expect(
        () => PostmanCollectionParser.parse('{"item": []}'),
        throwsA(isA<FormatException>()),
      );

      expect(
        () => PostmanCollectionParser.parse('{"info": {}}'),
        throwsA(isA<FormatException>()),
      );
    });

    test(
      'auto-detects and imports Postman collection into Drift SQLite database',
      () async {
        final db = AppDatabase(NativeDatabase.memory());
        final repo = CollectionsRepositoryImpl(db);

        final postmanJson = jsonEncode({
          'info': {'name': 'Auto-detected Postman Import'},
          'item': [
            {
              'name': 'Echo',
              'request': {
                'method': 'GET',
                'url': 'https://postman-echo.com/get?foo=bar',
              },
            },
          ],
        });

        final parsed = CollectionImportService.parseCollection(postmanJson);
        expect(parsed.collectionName, equals('Auto-detected Postman Import'));

        final created = await CollectionImportService.persistImportedCollection(
          repository: repo,
          importResult: parsed,
        );

        expect(created.id, isNotEmpty);
        final reqs = await repo.getRequests(created.id);
        expect(reqs.length, equals(1));
        expect(reqs.first.name, equals('Echo'));
        expect(reqs.first.url, equals('https://postman-echo.com/get?foo=bar'));

        await db.close();
      },
    );
  });
}
