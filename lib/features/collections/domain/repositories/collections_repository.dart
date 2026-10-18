import '../models/collection_entity.dart';

/// Contract for persisting and managing collections, folders, and saved requests.
abstract interface class ICollectionsRepository {
  Stream<List<CollectionEntity>> watchCollections({
    String workspaceId = 'default-workspace',
  });
  Future<List<CollectionEntity>> getCollections({
    String workspaceId = 'default-workspace',
  });
  Future<CollectionEntity> createCollection({
    required String name,
    String? description,
    String workspaceId = 'default-workspace',
  });
  Future<void> updateCollection(CollectionEntity collection);
  Future<void> deleteCollection(String collectionId);

  Stream<List<SavedRequestEntity>> watchRequests(String collectionId);
  Future<List<SavedRequestEntity>> getRequests(String collectionId);
  Future<SavedRequestEntity> saveRequest(SavedRequestEntity request);
  Future<void> updateRequest(SavedRequestEntity request);
  Future<void> deleteRequest(String requestId);
  Future<SavedRequestEntity> duplicateRequest(String requestId);
  Future<List<SavedRequestEntity>> searchRequests(String query);
}
