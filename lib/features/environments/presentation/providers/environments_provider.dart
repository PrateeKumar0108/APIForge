import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../collections/presentation/providers/collections_provider.dart';
import '../../data/repositories/environments_repository_impl.dart';
import '../../domain/models/environment_entity.dart';
import '../../domain/repositories/environments_repository.dart';

/// Provider for secure credentials storage.
final secureStorageServiceProvider = Provider<ISecureStorageService>((ref) {
  return SecureStorageService();
});

/// Provider for environments repository.
final environmentsRepositoryProvider = Provider<IEnvironmentsRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final storage = ref.watch(secureStorageServiceProvider);
  return EnvironmentsRepositoryImpl(db: db, secureStorage: storage);
});

/// Reactive stream of available environments. Automatically seeds defaults on first run.
final environmentsListProvider = StreamProvider<List<EnvironmentEntity>>((ref) {
  final repo = ref.watch(environmentsRepositoryProvider);
  // Asynchronously seed standard defaults if not present
  repo.seedDefaultEnvironments();
  return repo.watchEnvironments();
});

/// Currently selected active environment ID. Null indicates "No Environment".
final activeEnvironmentIdProvider = StateProvider<String?>((ref) => null);

/// Resolves the currently active [EnvironmentEntity] object.
final activeEnvironmentProvider = Provider<EnvironmentEntity?>((ref) {
  final activeId = ref.watch(activeEnvironmentIdProvider);
  if (activeId == null) return null;

  final environmentsAsync = ref.watch(environmentsListProvider);
  return environmentsAsync.valueOrNull
      ?.where((env) => env.id == activeId)
      .firstOrNull;
});
