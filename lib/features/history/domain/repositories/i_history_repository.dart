import '../models/history_entry_entity.dart';

/// Contract for request history audit logs and replay management.
abstract interface class IHistoryRepository {
  /// Inserts a newly executed request history entry, applying sensitive header
  /// redaction and pruning excess records beyond [maxRetention].
  Future<void> logEntry(
    HistoryEntryEntity entry, {
    bool persistBody = false,
    int maxRetention = 100,
  });

  /// Continuously watches request history entries ordered by execution time descending.
  Stream<List<HistoryEntryEntity>> watchHistory({int limit = 100});

  /// Fetches a one-time snapshot of recent history entries.
  Future<List<HistoryEntryEntity>> getHistory({int limit = 100});

  /// Deletes an individual history entry by id.
  Future<void> deleteEntry(String id);

  /// Clears all recorded history.
  Future<void> clearAllHistory();

  /// Prunes records older than the newest [maxRetention] entries.
  Future<void> pruneOldEntries({int maxRetention = 100});
}
