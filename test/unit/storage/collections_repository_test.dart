import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apiforge/core/networking/request_models.dart';
import 'package:apiforge/core/storage/database/app_database.dart';
import 'package:apiforge/features/collections/data/repositories/collections_repository_impl.dart';
import 'package:apiforge/features/collections/domain/models/collection_entity.dart';

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

  group('CollectionsRepository CRUD & Cascade Deletions', () {
    test('creates and retrieves a collection from SQLite', () async {
      final collection = await repo.createCollection(
        name: 'GitHub API v3',
        description: 'Endpoints for GitHub users, repos, and issues',
      );

      expect(collection.id, isNotEmpty);
      expect(collection.name, equals('GitHub API v3'));
      expect(
        collection.description,
        equals('Endpoints for GitHub users, repos, and issues'),
      );

      final allCollections = await repo.getCollections();
      expect(allCollections.length, equals(1));
      expect(allCollections.first.name, equals('GitHub API v3'));
    });

    test('saves requests and queries them by collection', () async {
      final collection = await repo.createCollection(name: 'Payments API');

      final request1 = SavedRequestEntity(
        id: 'req-1',
        collectionId: collection.id,
        name: 'Create Stripe Charge',
        method: 'POST',
        url: 'https://api.stripe.com/v1/charges',
        headers: [
          KeyValuePair(key: 'Authorization', value: 'Bearer sk_test_123'),
        ],
        queryParams: [KeyValuePair(key: 'currency', value: 'usd')],
        bodyType: BodyType.json,
        bodyContent: '{"amount":2000}',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repo.saveRequest(request1);

      final requests = await repo.getRequests(collection.id);
      expect(requests.length, equals(1));
      expect(requests.first.name, equals('Create Stripe Charge'));
      expect(requests.first.headers.length, equals(1));
      expect(requests.first.headers.first.key, equals('Authorization'));
      expect(requests.first.queryParams.length, equals(1));
      expect(requests.first.bodyType, equals(BodyType.json));
    });

    test('duplicates request with new id and (Copy) label', () async {
      final collection = await repo.createCollection(name: 'Users');
      final original = SavedRequestEntity(
        id: 'orig-1',
        collectionId: collection.id,
        name: 'Fetch Profile',
        method: 'GET',
        url: 'https://api.example.com/me',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repo.saveRequest(original);
      final duplicate = await repo.duplicateRequest('orig-1');

      expect(duplicate.id, isNot(equals('orig-1')));
      expect(duplicate.name, equals('Fetch Profile (Copy)'));
      expect(duplicate.url, equals('https://api.example.com/me'));

      final all = await repo.getRequests(collection.id);
      expect(all.length, equals(2));
    });

    test('searches requests by name, url, or method', () async {
      final collection = await repo.createCollection(name: 'Search Test');

      await repo.saveRequest(
        SavedRequestEntity(
          id: 'search-1',
          collectionId: collection.id,
          name: 'List Orders',
          method: 'GET',
          url: 'https://shop.example.com/orders',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      await repo.saveRequest(
        SavedRequestEntity(
          id: 'search-2',
          collectionId: collection.id,
          name: 'Create Customer',
          method: 'POST',
          url: 'https://crm.example.com/customers',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      final byName = await repo.searchRequests('orders');
      expect(byName.length, equals(1));
      expect(byName.first.id, equals('search-1'));

      final byMethod = await repo.searchRequests('POST');
      expect(byMethod.length, equals(1));
      expect(byMethod.first.id, equals('search-2'));
    });

    test(
      'deleting a collection cascades and removes all contained requests',
      () async {
        final collection = await repo.createCollection(name: 'Temporary');

        await repo.saveRequest(
          SavedRequestEntity(
            id: 'child-req-1',
            collectionId: collection.id,
            name: 'Temporary Request 1',
            method: 'GET',
            url: 'https://example.com/temp1',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        await repo.saveRequest(
          SavedRequestEntity(
            id: 'child-req-2',
            collectionId: collection.id,
            name: 'Temporary Request 2',
            method: 'DELETE',
            url: 'https://example.com/temp2',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        var childRequests = await repo.getRequests(collection.id);
        expect(childRequests.length, equals(2));

        // Delete the parent collection
        await repo.deleteCollection(collection.id);

        // Verify collection is deleted
        final collections = await repo.getCollections();
        expect(collections.isEmpty, isTrue);

        // Verify cascade deleted the children
        childRequests = await repo.getRequests(collection.id);
        expect(childRequests.isEmpty, isTrue);
      },
    );
  });
}
