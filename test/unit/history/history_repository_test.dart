import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apiforge/core/networking/request_models.dart';
import 'package:apiforge/core/storage/database/app_database.dart';
import 'package:apiforge/features/history/data/repositories/history_repository_impl.dart';
import 'package:apiforge/features/history/domain/models/history_entry_entity.dart';

void main() {
  late AppDatabase db;
  late HistoryRepositoryImpl repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = HistoryRepositoryImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('HistoryRepository Tests', () {
    test(
      'logs entry and auto-redacts sensitive Authorization header',
      () async {
        final entry = HistoryEntryEntity(
          id: 'hist-1',
          method: 'POST',
          url: 'https://api.example.com/checkout',
          statusCode: 201,
          statusMessage: 'Created',
          durationMs: 145,
          contentLengthBytes: 512,
          requestHeaders: [
            KeyValuePair(key: 'Content-Type', value: 'application/json'),
            KeyValuePair(
              key: 'Authorization',
              value: 'Bearer secret_token_xyz',
            ),
            KeyValuePair(key: 'X-API-KEY', value: 'super-secret-key-123'),
          ],
          responseHeaders: const {
            'content-type': ['application/json'],
            'set-cookie': ['session_id=12345'],
          },
          bodyContent: '{"order_id": 99}',
          executedAt: DateTime.now(),
        );

        await repo.logEntry(entry, persistBody: false);

        final history = await repo.getHistory();
        expect(history.length, equals(1));
        final logged = history.first;
        expect(logged.statusCode, equals(201));
        expect(logged.statusMessage, equals('Created'));
        expect(logged.durationMs, equals(145));

        // Check header redaction
        final authHeader = logged.requestHeaders.firstWhere(
          (h) => h.key == 'Authorization',
        );
        expect(authHeader.value, equals('Bearer [REDACTED]'));

        final apiKeyHeader = logged.requestHeaders.firstWhere(
          (h) => h.key == 'X-API-KEY',
        );
        expect(apiKeyHeader.value, equals('[REDACTED]'));

        // Check response set-cookie redaction
        expect(logged.responseHeaders['set-cookie'], equals(['[REDACTED]']));

        // Check default bodyContent is null when persistBody is false
        expect(logged.bodyContent, isNull);
      },
    );

    test('persists body when persistBody is true', () async {
      final entry = HistoryEntryEntity(
        id: 'hist-persist-body',
        method: 'POST',
        url: 'https://api.example.com/data',
        statusCode: 200,
        statusMessage: 'OK',
        durationMs: 80,
        contentLengthBytes: 24,
        requestHeaders: const [],
        responseHeaders: const {},
        bodyContent: '{"opt_in": true}',
        executedAt: DateTime.now(),
      );

      await repo.logEntry(entry, persistBody: true);

      final history = await repo.getHistory();
      expect(history.first.bodyContent, equals('{"opt_in": true}'));
    });

    test('enforces FIFO retention trimming', () async {
      final baseTime = DateTime.now();

      // Log 4 entries with maxRetention = 2
      for (int i = 1; i <= 4; i++) {
        await repo.logEntry(
          HistoryEntryEntity(
            id: 'hist-$i',
            method: 'GET',
            url: 'https://api.example.com/item/$i',
            statusCode: 200,
            statusMessage: 'OK',
            durationMs: 10 * i,
            contentLengthBytes: 100,
            requestHeaders: const [],
            responseHeaders: const {},
            executedAt: baseTime.add(Duration(minutes: i)),
          ),
          maxRetention: 2,
        );
      }

      final history = await repo.getHistory();
      expect(history.length, equals(2));
      // Should retain only the newest 2 entries (hist-4 and hist-3)
      expect(
        history.map((e) => e.id).toList(),
        containsAll(['hist-4', 'hist-3']),
      );
      expect(history.map((e) => e.id).toList(), isNot(contains('hist-1')));
      expect(history.map((e) => e.id).toList(), isNot(contains('hist-2')));
    });

    test('deletes individual entry and clears all history', () async {
      await repo.logEntry(
        HistoryEntryEntity(
          id: 'hist-del-1',
          method: 'GET',
          url: 'https://api.example.com/one',
          statusCode: 200,
          statusMessage: 'OK',
          durationMs: 50,
          contentLengthBytes: 10,
          requestHeaders: const [],
          responseHeaders: const {},
          executedAt: DateTime.now(),
        ),
      );

      await repo.logEntry(
        HistoryEntryEntity(
          id: 'hist-del-2',
          method: 'GET',
          url: 'https://api.example.com/two',
          statusCode: 200,
          statusMessage: 'OK',
          durationMs: 60,
          contentLengthBytes: 20,
          requestHeaders: const [],
          responseHeaders: const {},
          executedAt: DateTime.now(),
        ),
      );

      var history = await repo.getHistory();
      expect(history.length, equals(2));

      await repo.deleteEntry('hist-del-1');
      history = await repo.getHistory();
      expect(history.length, equals(1));
      expect(history.first.id, equals('hist-del-2'));

      await repo.clearAllHistory();
      history = await repo.getHistory();
      expect(history, isEmpty);
    });

    test('converts history entry to executable HttpRequestData for replay', () {
      final entry = HistoryEntryEntity(
        id: 'hist-replay',
        method: 'PUT',
        url: 'https://api.example.com/users/42',
        statusCode: 200,
        statusMessage: 'OK',
        durationMs: 95,
        contentLengthBytes: 120,
        requestHeaders: [
          KeyValuePair(key: 'Accept', value: 'application/json'),
        ],
        responseHeaders: const {},
        bodyContent: '{"status": "active"}',
        executedAt: DateTime.now(),
      );

      final replayData = entry.toHttpRequestData();
      expect(replayData.method, equals('PUT'));
      expect(replayData.url, equals('https://api.example.com/users/42'));
      expect(replayData.bodyType, equals(BodyType.json));
      expect(replayData.bodyContent, equals('{"status": "active"}'));
      expect(replayData.headers.length, equals(1));
      expect(replayData.headers.first.key, equals('Accept'));
    });
  });
}
