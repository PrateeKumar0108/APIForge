import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/database/app_database.dart';
import '../../data/repositories/collections_repository_impl.dart';
import '../../domain/models/collection_entity.dart';
import '../../domain/repositories/collections_repository.dart';

/// Singleton provider for the Drift AppDatabase.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

/// Provider for the collections repository.
final collectionsRepositoryProvider = Provider<ICollectionsRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return CollectionsRepositoryImpl(db);
});

/// Stream of all collections in the default workspace.
final collectionsListProvider = StreamProvider<List<CollectionEntity>>((ref) {
  final repo = ref.watch(collectionsRepositoryProvider);
  return repo.watchCollections();
});

/// Active collection search query state.
final collectionSearchQueryProvider = StateProvider<String>((ref) => '');

/// Stream of requests contained within a specific collection.
final collectionRequestsProvider =
    StreamProvider.family<List<SavedRequestEntity>, String>((
      ref,
      collectionId,
    ) {
      final repo = ref.watch(collectionsRepositoryProvider);
      return repo.watchRequests(collectionId);
    });
