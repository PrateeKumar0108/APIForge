import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../../core/networking/request_models.dart';
import '../../../authentication/domain/models/auth_config.dart';

/// Domain representation of a Collection.
@immutable
class CollectionEntity {
  final String id;
  final String workspaceId;
  final String name;
  final String? description;
  final int sortOrder;
  final int requestCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CollectionEntity({
    required this.id,
    required this.workspaceId,
    required this.name,
    this.description,
    this.sortOrder = 0,
    this.requestCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  CollectionEntity copyWith({
    String? name,
    String? description,
    int? sortOrder,
    int? requestCount,
    DateTime? updatedAt,
  }) {
    return CollectionEntity(
      id: id,
      workspaceId: workspaceId,
      name: name ?? this.name,
      description: description ?? this.description,
      sortOrder: sortOrder ?? this.sortOrder,
      requestCount: requestCount ?? this.requestCount,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Domain representation of a saved API request.
@immutable
class SavedRequestEntity {
  final String id;
  final String collectionId;
  final String? folderId;
  final String name;
  final String? description;
  final String method;
  final String url;
  final List<KeyValuePair> queryParams;
  final List<KeyValuePair> headers;
  final BodyType bodyType;
  final String bodyContent;
  final List<KeyValuePair> formData;
  final String authType;
  final AuthConfig? authConfig;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SavedRequestEntity({
    required this.id,
    required this.collectionId,
    this.folderId,
    required this.name,
    this.description,
    required this.method,
    required this.url,
    this.queryParams = const [],
    this.headers = const [],
    this.bodyType = BodyType.none,
    this.bodyContent = '',
    this.formData = const [],
    this.authType = 'none',
    this.authConfig,
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Converts this entity into executable [HttpRequestData].
  HttpRequestData toHttpRequestData() {
    return HttpRequestData(
      id: id,
      name: name,
      method: method,
      url: url,
      queryParams: queryParams,
      headers: headers,
      bodyType: bodyType,
      bodyContent: bodyContent,
      formData: formData,
    );
  }

  /// Converts [HttpRequestData] into a [SavedRequestEntity] bound to a collection.
  factory SavedRequestEntity.fromHttpRequestData({
    required HttpRequestData request,
    required String collectionId,
    String? folderId,
  }) {
    final now = DateTime.now();
    return SavedRequestEntity(
      id: request.id,
      collectionId: collectionId,
      folderId: folderId,
      name: request.name,
      method: request.method,
      url: request.url,
      queryParams: request.queryParams,
      headers: request.headers,
      bodyType: request.bodyType,
      bodyContent: request.bodyContent,
      formData: request.formData,
      createdAt: now,
      updatedAt: now,
    );
  }

  SavedRequestEntity copyWith({
    String? name,
    String? description,
    String? method,
    String? url,
    List<KeyValuePair>? queryParams,
    List<KeyValuePair>? headers,
    BodyType? bodyType,
    String? bodyContent,
    List<KeyValuePair>? formData,
    String? authType,
    int? sortOrder,
    DateTime? updatedAt,
  }) {
    return SavedRequestEntity(
      id: id,
      collectionId: collectionId,
      folderId: folderId,
      name: name ?? this.name,
      description: description ?? this.description,
      method: method ?? this.method,
      url: url ?? this.url,
      queryParams: queryParams ?? this.queryParams,
      headers: headers ?? this.headers,
      bodyType: bodyType ?? this.bodyType,
      bodyContent: bodyContent ?? this.bodyContent,
      formData: formData ?? this.formData,
      authType: authType ?? this.authType,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Serializers for JSON columns
  static String encodeKeyValueList(List<KeyValuePair> list) {
    return jsonEncode(list.map((e) => e.toJson()).toList());
  }

  static List<KeyValuePair> decodeKeyValueList(String rawJson) {
    if (rawJson.trim().isEmpty) return [];
    try {
      final decoded = jsonDecode(rawJson) as List<dynamic>;
      return decoded
          .map((e) => KeyValuePair.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
