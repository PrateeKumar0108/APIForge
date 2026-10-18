import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../../../../core/networking/request_models.dart';
import '../../../authentication/domain/models/auth_config.dart';
import '../../../collections/domain/models/collection_entity.dart';
import '../../../collections/domain/repositories/collections_repository.dart';
import 'import_result.dart';
import 'postman_collection_parser.dart';

/// Orchestrates parsing, format detection, and database persistence for collection imports.
abstract final class CollectionImportService {
  /// Detects whether [rawJson] is an APIForge JSON v1 or Postman Collection v2.1,
  /// validates it, and returns the parsed [ImportResult].
  static ImportResult parseCollection(String rawJson) {
    dynamic decoded;
    try {
      decoded = jsonDecode(rawJson);
    } catch (e) {
      throw FormatException('Malformed JSON: $e');
    }

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Expected top-level JSON object.');
    }

    // Check if APIForge JSON v1
    if (decoded['format'] == 'apiforge') {
      return _parseApiForgeV1(decoded);
    }

    // Check if Postman Collection v2.1
    if (decoded.containsKey('info') && decoded.containsKey('item')) {
      return PostmanCollectionParser.parse(rawJson);
    }

    throw const FormatException(
      'Unrecognized collection format. Please provide an APIForge JSON v1 or Postman v2.1 collection.',
    );
  }

  /// Persists the parsed [ImportResult] into SQLite using [ICollectionsRepository].
  /// Returns the created [CollectionEntity].
  static Future<CollectionEntity> persistImportedCollection({
    required ICollectionsRepository repository,
    required ImportResult importResult,
    String? customCollectionName,
  }) async {
    final name = (customCollectionName?.trim().isNotEmpty == true)
        ? customCollectionName!.trim()
        : importResult.collectionName;

    // 1. Create top-level collection
    final collection = await repository.createCollection(
      name: name,
      description: importResult.collectionDescription,
    );

    // 2. Insert all requests into the collection
    for (int i = 0; i < importResult.requests.length; i++) {
      final req = importResult.requests[i];
      final savedRequest = SavedRequestEntity(
        id: const Uuid().v4(),
        collectionId: collection.id,
        name: req.name,
        description: req.description,
        method: req.method,
        url: req.url,
        queryParams: req.queryParams,
        headers: req.headers,
        bodyType: req.bodyType,
        bodyContent: req.bodyContent,
        formData: req.formData,
        authType: req.authConfig.type.name,
        authConfig: req.authConfig,
        sortOrder: i,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.saveRequest(savedRequest);
    }

    return collection;
  }

  static ImportResult _parseApiForgeV1(Map<String, dynamic> json) {
    final version = json['version'];
    if (version != 1) {
      throw FormatException(
        'Unsupported APIForge version: $version. Expected version 1.',
      );
    }

    final collectionMap = json['collection'];
    if (collectionMap is! Map<String, dynamic>) {
      throw const FormatException(
        'Missing "collection" object in APIForge JSON.',
      );
    }

    final name =
        (collectionMap['name'] as String?)?.trim() ?? 'Imported Collection';
    final description = collectionMap['description'] as String?;

    final requestsList = collectionMap['requests'];
    final requests = <ImportedRequest>[];
    final warnings = <String>[];

    if (requestsList is List) {
      for (final r in requestsList) {
        if (r is! Map<String, dynamic>) continue;
        try {
          final reqName = (r['name'] as String?)?.trim() ?? 'Untitled Request';
          final method = ((r['method'] as String?) ?? 'GET').toUpperCase();
          final url = (r['url'] as String?) ?? '';

          // Query Params
          final queryParams = <KeyValuePair>[];
          if (r['queryParams'] is List) {
            for (final q in r['queryParams'] as List) {
              if (q is Map<String, dynamic>) {
                queryParams.add(
                  KeyValuePair(
                    key: (q['key'] as String?) ?? '',
                    value: (q['value'] as String?) ?? '',
                    isEnabled: q['isEnabled'] != false,
                    isSecret: q['isSecret'] == true,
                  ),
                );
              }
            }
          }

          // Headers
          final headers = <KeyValuePair>[];
          if (r['headers'] is List) {
            for (final h in r['headers'] as List) {
              if (h is Map<String, dynamic>) {
                headers.add(
                  KeyValuePair(
                    key: (h['key'] as String?) ?? '',
                    value: (h['value'] as String?) ?? '',
                    isEnabled: h['isEnabled'] != false,
                    isSecret: h['isSecret'] == true,
                  ),
                );
              }
            }
          }

          // Body
          final bodyTypeStr = (r['bodyType'] as String?) ?? 'none';
          final bodyType = BodyType.values.firstWhere(
            (b) => b.name == bodyTypeStr,
            orElse: () => BodyType.none,
          );
          final bodyContent = (r['bodyContent'] as String?) ?? '';

          // FormData
          final formData = <KeyValuePair>[];
          if (r['formData'] is List) {
            for (final f in r['formData'] as List) {
              if (f is Map<String, dynamic>) {
                formData.add(
                  KeyValuePair(
                    key: (f['key'] as String?) ?? '',
                    value: (f['value'] as String?) ?? '',
                    isEnabled: f['isEnabled'] != false,
                  ),
                );
              }
            }
          }

          // Auth
          AuthConfig authConfig = const AuthConfig(type: AuthType.none);
          if (r['authConfig'] is Map<String, dynamic>) {
            final authMap = r['authConfig'] as Map<String, dynamic>;
            final typeStr = authMap['type'] as String? ?? 'none';
            final authType = AuthType.values.firstWhere(
              (t) => t.name == typeStr,
              orElse: () => AuthType.none,
            );

            if (authType == AuthType.bearer) {
              authConfig = AuthConfig(
                type: AuthType.bearer,
                token: authMap['token'] as String?,
              );
            } else if (authType == AuthType.basic) {
              authConfig = AuthConfig(
                type: AuthType.basic,
                username: authMap['username'] as String?,
                password: authMap['password'] as String?,
              );
            } else if (authType == AuthType.apiKey) {
              final locStr =
                  authMap['apiKeyLocation'] ?? authMap['apiKeyAddTo'];
              authConfig = AuthConfig(
                type: AuthType.apiKey,
                apiKeyName: authMap['apiKeyName'] as String?,
                apiKeyValue: authMap['apiKeyValue'] as String?,
                apiKeyLocation: locStr == 'query'
                    ? ApiKeyLocation.query
                    : ApiKeyLocation.header,
              );
            }
          }

          requests.add(
            ImportedRequest(
              name: reqName,
              description: r['description'] as String?,
              method: method,
              url: url,
              queryParams: queryParams,
              headers: headers,
              bodyType: bodyType,
              bodyContent: bodyContent,
              formData: formData,
              authConfig: authConfig,
            ),
          );
        } catch (e) {
          warnings.add('Error parsing request: $e');
        }
      }
    }

    return ImportResult(
      collectionName: name,
      collectionDescription: description,
      requests: requests,
      warnings: warnings,
    );
  }
}
