import 'dart:convert';
import '../../../../core/networking/request_models.dart';
import '../../../authentication/domain/models/auth_config.dart';
import 'import_result.dart';

/// Parses Postman Collection v2.1 JSON specifications safely.
///
/// Security constraints:
/// - Explicitly ignores and discards executable test and pre-request scripts.
/// - Limits recursive folder traversal depth to prevent stack overflow.
/// - Validates structures and handles missing/partial fields gracefully.
abstract final class PostmanCollectionParser {
  static const int maxTraversalDepth = 10;

  /// Parses a Postman v2.1 collection JSON string into an [ImportResult].
  /// Throws [FormatException] if the JSON is invalid or missing the required Postman structure.
  static ImportResult parse(String rawJson) {
    dynamic decoded;
    try {
      decoded = jsonDecode(rawJson);
    } catch (e) {
      throw FormatException('Invalid JSON payload: $e');
    }

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Expected top-level JSON object.');
    }

    // 1. Validate Info Object
    final info = decoded['info'];
    if (info is! Map<String, dynamic>) {
      throw const FormatException(
        'Missing required Postman "info" descriptor.',
      );
    }

    final collectionName =
        (info['name'] as String?)?.trim() ?? 'Imported Collection';
    String? collectionDescription;
    if (info['description'] is String) {
      collectionDescription = info['description'] as String;
    } else if (info['description'] is Map &&
        info['description']['content'] is String) {
      collectionDescription = info['description']['content'] as String;
    }

    // 2. Validate Items Array
    final items = decoded['item'];
    if (items is! List) {
      throw const FormatException(
        'Postman collection contains no valid "item" array.',
      );
    }

    final warnings = <String>[];
    final requests = <ImportedRequest>[];

    _traverseItems(
      items: items,
      requests: requests,
      warnings: warnings,
      currentFolderName: null,
      depth: 0,
    );

    return ImportResult(
      collectionName: collectionName,
      collectionDescription: collectionDescription,
      requests: requests,
      warnings: warnings,
    );
  }

  static void _traverseItems({
    required List<dynamic> items,
    required List<ImportedRequest> requests,
    required List<String> warnings,
    required String? currentFolderName,
    required int depth,
  }) {
    if (depth > maxTraversalDepth) {
      warnings.add(
        'Maximum folder recursion depth ($maxTraversalDepth) reached; deeper items skipped.',
      );
      return;
    }

    for (final rawItem in items) {
      if (rawItem is! Map<String, dynamic>) continue;

      // Notice: "event" and "script" fields are intentionally NOT parsed or evaluated.

      final itemName =
          (rawItem['name'] as String?)?.trim() ?? 'Untitled Request';

      // Check if this item is a folder containing sub-items
      if (rawItem.containsKey('item') && rawItem['item'] is List) {
        final subFolderName = currentFolderName != null
            ? '$currentFolderName / $itemName'
            : itemName;
        _traverseItems(
          items: rawItem['item'] as List,
          requests: requests,
          warnings: warnings,
          currentFolderName: subFolderName,
          depth: depth + 1,
        );
      }

      // Check if this item represents a request
      if (rawItem.containsKey('request')) {
        final rawRequest = rawItem['request'];
        try {
          final importedReq = _parseRequest(
            name: itemName,
            rawRequest: rawRequest,
            folderName: currentFolderName,
            warnings: warnings,
          );
          if (importedReq != null) {
            requests.add(importedReq);
          }
        } catch (e) {
          warnings.add('Failed to parse request "$itemName": $e');
        }
      }
    }
  }

  static ImportedRequest? _parseRequest({
    required String name,
    required dynamic rawRequest,
    required String? folderName,
    required List<String> warnings,
  }) {
    if (rawRequest is String) {
      // Simplified Postman request shorthand: "request": "https://api.example.com"
      return ImportedRequest(
        name: name,
        method: 'GET',
        url: rawRequest,
        folderName: folderName,
      );
    }

    if (rawRequest is! Map<String, dynamic>) {
      warnings.add('Request "$name" has unsupported format.');
      return null;
    }

    // 1. Method
    final method = ((rawRequest['method'] as String?) ?? 'GET').toUpperCase();

    // 2. URL and Query Params
    String url = '';
    final queryParams = <KeyValuePair>[];

    final urlData = rawRequest['url'];
    if (urlData is String) {
      url = urlData;
    } else if (urlData is Map<String, dynamic>) {
      url = (urlData['raw'] as String?) ?? '';
      if (urlData['query'] is List) {
        for (final q in urlData['query'] as List) {
          if (q is Map<String, dynamic>) {
            final key = (q['key'] as String?) ?? '';
            final val = (q['value'] as String?) ?? '';
            final disabled = q['disabled'] == true;
            if (key.isNotEmpty || val.isNotEmpty) {
              queryParams.add(
                KeyValuePair(key: key, value: val, isEnabled: !disabled),
              );
            }
          }
        }
      }
    }

    // 3. Headers
    final headers = <KeyValuePair>[];
    if (rawRequest['header'] is List) {
      for (final h in rawRequest['header'] as List) {
        if (h is Map<String, dynamic>) {
          final key = (h['key'] as String?) ?? '';
          final val = (h['value'] as String?) ?? '';
          final disabled = h['disabled'] == true;
          if (key.isNotEmpty) {
            headers.add(
              KeyValuePair(key: key, value: val, isEnabled: !disabled),
            );
          }
        }
      }
    }

    // 4. Body
    BodyType bodyType = BodyType.none;
    String bodyContent = '';
    final formData = <KeyValuePair>[];

    if (rawRequest['body'] is Map<String, dynamic>) {
      final bodyMap = rawRequest['body'] as Map<String, dynamic>;
      final mode = (bodyMap['mode'] as String?)?.toLowerCase();

      if (mode == 'raw') {
        bodyType = BodyType.json;
        bodyContent = (bodyMap['raw'] as String?) ?? '';
      } else if (mode == 'urlencoded' || mode == 'formdata') {
        bodyType = BodyType.formUrlEncoded;
        final listKey = mode == 'urlencoded' ? 'urlencoded' : 'formdata';
        if (bodyMap[listKey] is List) {
          for (final f in bodyMap[listKey] as List) {
            if (f is Map<String, dynamic>) {
              final key = (f['key'] as String?) ?? '';
              final val = (f['value'] as String?) ?? '';
              final disabled = f['disabled'] == true;
              formData.add(
                KeyValuePair(key: key, value: val, isEnabled: !disabled),
              );
            }
          }
        }
      }
    }

    // 5. Auth
    AuthConfig authConfig = const AuthConfig(type: AuthType.none);
    if (rawRequest['auth'] is Map<String, dynamic>) {
      final authMap = rawRequest['auth'] as Map<String, dynamic>;
      final type = (authMap['type'] as String?)?.toLowerCase();

      if (type == 'bearer') {
        String token = '';
        if (authMap['bearer'] is List) {
          for (final b in authMap['bearer'] as List) {
            if (b is Map && b['key'] == 'token') {
              token = (b['value'] as String?) ?? '';
            }
          }
        }
        authConfig = AuthConfig(type: AuthType.bearer, token: token);
      } else if (type == 'basic') {
        String username = '';
        String password = '';
        if (authMap['basic'] is List) {
          for (final b in authMap['basic'] as List) {
            if (b is Map && b['key'] == 'username') {
              username = (b['value'] as String?) ?? '';
            }
            if (b is Map && b['key'] == 'password') {
              password = (b['value'] as String?) ?? '';
            }
          }
        }
        authConfig = AuthConfig(
          type: AuthType.basic,
          username: username,
          password: password,
        );
      } else if (type == 'apikey') {
        String key = '';
        String val = '';
        ApiKeyLocation location = ApiKeyLocation.header;
        if (authMap['apikey'] is List) {
          for (final a in authMap['apikey'] as List) {
            if (a is Map && a['key'] == 'key') {
              key = (a['value'] as String?) ?? '';
            }
            if (a is Map && a['key'] == 'value') {
              val = (a['value'] as String?) ?? '';
            }
            if (a is Map && a['key'] == 'in' && a['value'] == 'query') {
              location = ApiKeyLocation.query;
            }
          }
        }
        authConfig = AuthConfig(
          type: AuthType.apiKey,
          apiKeyName: key,
          apiKeyValue: val,
          apiKeyLocation: location,
        );
      }
    }

    // 6. Description
    String? description;
    if (rawRequest['description'] is String) {
      description = rawRequest['description'] as String;
    }

    return ImportedRequest(
      name: name,
      description: description,
      method: method,
      url: url,
      queryParams: queryParams,
      headers: headers,
      bodyType: bodyType,
      bodyContent: bodyContent,
      formData: formData,
      authConfig: authConfig,
      folderName: folderName,
    );
  }
}
