import 'dart:convert';
import 'package:drift/drift.dart';
import '../../../../core/networking/secret_redactor.dart';
import '../../../../core/storage/database/app_database.dart';
import '../../domain/models/history_entry_entity.dart';
import '../../domain/repositories/i_history_repository.dart';

/// SQLite-backed implementation of [IHistoryRepository] with privacy sanitization
/// and automated FIFO retention pruning.
class HistoryRepositoryImpl implements IHistoryRepository {
  final AppDatabase _db;

  HistoryRepositoryImpl(this._db);

  @override
  Future<void> logEntry(
    HistoryEntryEntity entry, {
    bool persistBody = false,
    int maxRetention = 100,
  }) async {
    // 1. Sanitize request headers
    final sanitizedHeaders = SecretRedactor.redactKeyValuePairs(
      entry.requestHeaders,
    );

    // 2. Sanitize response headers (mask Set-Cookie or sensitive tokens)
    final sanitizedResponseHeaders = <String, List<String>>{};
    for (final headerEntry in entry.responseHeaders.entries) {
      if (SecretRedactor.isSensitiveKey(headerEntry.key)) {
        sanitizedResponseHeaders[headerEntry.key] = ['[REDACTED]'];
      } else {
        sanitizedResponseHeaders[headerEntry.key] = headerEntry.value;
      }
    }

    // 3. Request body persistence is strictly opt-in
    final storedBody = persistBody ? entry.bodyContent : null;

    final companion = RequestHistoryEntriesCompanion.insert(
      id: entry.id,
      method: entry.method,
      url: entry.url,
      statusCode: entry.statusCode,
      statusMessage: Value(entry.statusMessage),
      durationMs: entry.durationMs,
      contentLengthBytes: Value(entry.contentLengthBytes),
      headersJson: Value(
        jsonEncode(sanitizedHeaders.map((e) => e.toJson()).toList()),
      ),
      responseHeadersJson: Value(jsonEncode(sanitizedResponseHeaders)),
      bodyContent: Value(storedBody),
      executedAt: Value(entry.executedAt),
    );

    await _db.into(_db.requestHistoryEntries).insert(companion);

    // 4. FIFO Retention Enforcement
    await pruneOldEntries(maxRetention: maxRetention);
  }

  @override
  Stream<List<HistoryEntryEntity>> watchHistory({int limit = 100}) {
    final query = _db.select(_db.requestHistoryEntries)
      ..orderBy([(t) => OrderingTerm.desc(t.executedAt)])
      ..limit(limit);

    return query.watch().map((rows) => rows.map(_toEntity).toList());
  }

  @override
  Future<List<HistoryEntryEntity>> getHistory({int limit = 100}) async {
    final query = _db.select(_db.requestHistoryEntries)
      ..orderBy([(t) => OrderingTerm.desc(t.executedAt)])
      ..limit(limit);

    final rows = await query.get();
    return rows.map(_toEntity).toList();
  }

  @override
  Future<void> deleteEntry(String id) async {
    await (_db.delete(
      _db.requestHistoryEntries,
    )..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<void> clearAllHistory() async {
    await _db.delete(_db.requestHistoryEntries).go();
  }

  @override
  Future<void> pruneOldEntries({int maxRetention = 100}) async {
    if (maxRetention <= 0) return;

    final excessRows =
        await (_db.select(_db.requestHistoryEntries)
              ..orderBy([(t) => OrderingTerm.desc(t.executedAt)])
              ..limit(500, offset: maxRetention))
            .get();

    if (excessRows.isNotEmpty) {
      final idsToDelete = excessRows.map((r) => r.id).toList();
      await (_db.delete(
        _db.requestHistoryEntries,
      )..where((t) => t.id.isIn(idsToDelete))).go();
    }
  }

  HistoryEntryEntity _toEntity(RequestHistoryEntry row) {
    return HistoryEntryEntity(
      id: row.id,
      method: row.method,
      url: row.url,
      statusCode: row.statusCode,
      statusMessage: row.statusMessage,
      durationMs: row.durationMs,
      contentLengthBytes: row.contentLengthBytes,
      requestHeaders: HistoryEntryEntity.decodeHeaders(row.headersJson),
      responseHeaders: HistoryEntryEntity.decodeResponseHeaders(
        row.responseHeadersJson,
      ),
      bodyContent: row.bodyContent,
      executedAt: row.executedAt,
    );
  }
}
