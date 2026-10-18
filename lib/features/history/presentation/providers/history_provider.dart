import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../collections/presentation/providers/collections_provider.dart';
import '../../data/repositories/history_repository_impl.dart';
import '../../domain/models/history_entry_entity.dart';
import '../../domain/repositories/i_history_repository.dart';

/// Provider for the request history repository.
final historyRepositoryProvider = Provider<IHistoryRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return HistoryRepositoryImpl(db);
});

/// Maximum number of history entries retained (default 100).
final historyRetentionLimitProvider = StateProvider<int>((ref) => 100);

/// Setting: Whether to persist request bodies in SQLite history (default: false for privacy).
final historyPersistRequestBodyProvider = StateProvider<bool>((ref) => false);

/// Stream of all history records ordered by executedAt descending.
final historyListProvider = StreamProvider<List<HistoryEntryEntity>>((ref) {
  final repo = ref.watch(historyRepositoryProvider);
  final limit = ref.watch(historyRetentionLimitProvider);
  return repo.watchHistory(limit: limit);
});
