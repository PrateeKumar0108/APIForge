import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/networking/request_models.dart';
import '../../../../core/storage/database/app_database.dart';
import '../../../authentication/domain/models/auth_config.dart';
import '../../domain/models/collection_entity.dart';
import '../../domain/repositories/collections_repository.dart';

/// Drift/SQLite implementation of [ICollectionsRepository].
class CollectionsRepositoryImpl implements ICollectionsRepository {
  final AppDatabase _db;

  CollectionsRepositoryImpl(this._db);

  @override
  Stream<List<CollectionEntity>> watchCollections({
    String workspaceId = 'default-workspace',
  }) {
    final query = _db.select(_db.collections)
      ..where((t) => t.workspaceId.equals(workspaceId))
      ..orderBy([
        (t) => OrderingTerm.asc(t.sortOrder),
        (t) => OrderingTerm.desc(t.updatedAt),
      ]);

    return query.watch().asyncMap((rows) async {
      final list = <CollectionEntity>[];
      for (final row in rows) {
        // Count requests in collection
        final countQuery = _db.savedRequests.id.count();
        final countRow =
            await (_db.selectOnly(_db.savedRequests)
                  ..addColumns([countQuery])
                  ..where(_db.savedRequests.collectionId.equals(row.id)))
                .getSingle();
        final count = countRow.read(countQuery) ?? 0;

        list.add(
          CollectionEntity(
            id: row.id,
            workspaceId: row.workspaceId,
            name: row.name,
            description: row.description,
            sortOrder: row.sortOrder,
            requestCount: count,
            createdAt: row.createdAt,
            updatedAt: row.updatedAt,
          ),
        );
      }
      return list;
    });
  }

  @override
  Future<List<CollectionEntity>> getCollections({
    String workspaceId = 'default-workspace',
  }) async {
    final rows =
        await (_db.select(_db.collections)
              ..where((t) => t.workspaceId.equals(workspaceId))
              ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
            .get();

    final list = <CollectionEntity>[];
    for (final row in rows) {
      final countQuery = _db.savedRequests.id.count();
      final countRow =
          await (_db.selectOnly(_db.savedRequests)
                ..addColumns([countQuery])
                ..where(_db.savedRequests.collectionId.equals(row.id)))
              .getSingle();
      final count = countRow.read(countQuery) ?? 0;

      list.add(
        CollectionEntity(
          id: row.id,
          workspaceId: row.workspaceId,
          name: row.name,
          description: row.description,
          sortOrder: row.sortOrder,
          requestCount: count,
          createdAt: row.createdAt,
          updatedAt: row.updatedAt,
        ),
      );
    }
    return list;
  }

  @override
  Future<CollectionEntity> createCollection({
    required String name,
    String? description,
    String workspaceId = 'default-workspace',
  }) async {
    final now = DateTime.now();
    final id = const Uuid().v4();

    await _db
        .into(_db.collections)
        .insert(
          CollectionsCompanion.insert(
            id: id,
            workspaceId: workspaceId,
            name: name,
            description: Value(description),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );

    return CollectionEntity(
      id: id,
      workspaceId: workspaceId,
      name: name,
      description: description,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<void> updateCollection(CollectionEntity collection) async {
    await (_db.update(
      _db.collections,
    )..where((t) => t.id.equals(collection.id))).write(
      CollectionsCompanion(
        name: Value(collection.name),
        description: Value(collection.description),
        sortOrder: Value(collection.sortOrder),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> deleteCollection(String collectionId) async {
    await _db.transaction(() async {
      await (_db.delete(
        _db.savedRequests,
      )..where((t) => t.collectionId.equals(collectionId))).go();
      await (_db.delete(
        _db.collections,
      )..where((t) => t.id.equals(collectionId))).go();
    });
  }

  @override
  Stream<List<SavedRequestEntity>> watchRequests(String collectionId) {
    final query = _db.select(_db.savedRequests)
      ..where((t) => t.collectionId.equals(collectionId))
      ..orderBy([
        (t) => OrderingTerm.asc(t.sortOrder),
        (t) => OrderingTerm.desc(t.updatedAt),
      ]);

    return query.watch().map((rows) => rows.map(_mapSavedRequestRow).toList());
  }

  @override
  Future<List<SavedRequestEntity>> getRequests(String collectionId) async {
    final rows =
        await (_db.select(_db.savedRequests)
              ..where((t) => t.collectionId.equals(collectionId))
              ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
            .get();

    return rows.map(_mapSavedRequestRow).toList();
  }

  @override
  Future<SavedRequestEntity> saveRequest(SavedRequestEntity request) async {
    final now = DateTime.now();
    final companion = SavedRequestsCompanion(
      id: Value(request.id),
      collectionId: Value(request.collectionId),
      folderId: Value(request.folderId),
      name: Value(request.name),
      description: Value(request.description),
      method: Value(request.method),
      url: Value(request.url),
      queryParamsJson: Value(
        SavedRequestEntity.encodeKeyValueList(request.queryParams),
      ),
      headersJson: Value(
        SavedRequestEntity.encodeKeyValueList(request.headers),
      ),
      bodyType: Value(request.bodyType.name),
      bodyContent: Value(request.bodyContent),
      formDataJson: Value(
        SavedRequestEntity.encodeKeyValueList(request.formData),
      ),
      authType: Value(request.authType),
      authConfigJson: Value(
        request.authConfig != null
            ? jsonEncode(request.authConfig!.toJson())
            : null,
      ),
      sortOrder: Value(request.sortOrder),
      createdAt: Value(request.createdAt),
      updatedAt: Value(now),
    );

    await _db.into(_db.savedRequests).insertOnConflictUpdate(companion);
    return request.copyWith(updatedAt: now);
  }

  @override
  Future<void> updateRequest(SavedRequestEntity request) async {
    await saveRequest(request);
  }

  @override
  Future<void> deleteRequest(String requestId) async {
    await (_db.delete(
      _db.savedRequests,
    )..where((t) => t.id.equals(requestId))).go();
  }

  @override
  Future<SavedRequestEntity> duplicateRequest(String requestId) async {
    final existing = await (_db.select(
      _db.savedRequests,
    )..where((t) => t.id.equals(requestId))).getSingle();
    final newId = const Uuid().v4();
    final now = DateTime.now();

    final copy = SavedRequestsCompanion.insert(
      id: newId,
      collectionId: existing.collectionId,
      folderId: Value(existing.folderId),
      name: '${existing.name} (Copy)',
      description: Value(existing.description),
      method: existing.method,
      url: existing.url,
      queryParamsJson: Value(existing.queryParamsJson),
      headersJson: Value(existing.headersJson),
      bodyType: Value(existing.bodyType),
      bodyContent: Value(existing.bodyContent),
      formDataJson: Value(existing.formDataJson),
      authType: Value(existing.authType),
      sortOrder: Value(existing.sortOrder + 1),
      createdAt: Value(now),
      updatedAt: Value(now),
    );

    await _db.into(_db.savedRequests).insert(copy);
    return _mapSavedRequestRow(
      await (_db.select(
        _db.savedRequests,
      )..where((t) => t.id.equals(newId))).getSingle(),
    );
  }

  @override
  Future<List<SavedRequestEntity>> searchRequests(String query) async {
    final term = '%${query.trim().toLowerCase()}%';
    final rows =
        await (_db.select(_db.savedRequests)..where(
              (t) =>
                  t.name.lower().like(term) |
                  t.url.lower().like(term) |
                  t.method.lower().like(term),
            ))
            .get();

    return rows.map(_mapSavedRequestRow).toList();
  }

  SavedRequestEntity _mapSavedRequestRow(SavedRequest row) {
    BodyType bodyType;
    try {
      bodyType = BodyType.values.byName(row.bodyType);
    } catch (_) {
      bodyType = BodyType.none;
    }

    AuthConfig? authConfig;
    if (row.authConfigJson != null && row.authConfigJson!.trim().isNotEmpty) {
      try {
        authConfig = AuthConfig.fromJson(
          jsonDecode(row.authConfigJson!) as Map<String, dynamic>,
        );
      } catch (_) {}
    }

    return SavedRequestEntity(
      id: row.id,
      collectionId: row.collectionId,
      folderId: row.folderId,
      name: row.name,
      description: row.description,
      method: row.method,
      url: row.url,
      queryParams: SavedRequestEntity.decodeKeyValueList(row.queryParamsJson),
      headers: SavedRequestEntity.decodeKeyValueList(row.headersJson),
      bodyType: bodyType,
      bodyContent: row.bodyContent,
      formData: SavedRequestEntity.decodeKeyValueList(row.formDataJson),
      authType: row.authType,
      authConfig: authConfig,
      sortOrder: row.sortOrder,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
