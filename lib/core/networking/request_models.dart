import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

/// Key-value pair used for query parameters, headers, and form-urlencoded fields.
@immutable
class KeyValuePair {
  final String id;
  final String key;
  final String value;
  final bool isEnabled;
  final bool isSecret;

  KeyValuePair({
    String? id,
    required this.key,
    required this.value,
    this.isEnabled = true,
    this.isSecret = false,
  }) : id = id ?? const Uuid().v4();

  KeyValuePair copyWith({
    String? key,
    String? value,
    bool? isEnabled,
    bool? isSecret,
  }) {
    return KeyValuePair(
      id: id,
      key: key ?? this.key,
      value: value ?? this.value,
      isEnabled: isEnabled ?? this.isEnabled,
      isSecret: isSecret ?? this.isSecret,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'key': key,
    'value': value,
    'isEnabled': isEnabled,
    'isSecret': isSecret,
  };

  factory KeyValuePair.fromJson(Map<String, dynamic> json) {
    return KeyValuePair(
      id: json['id'] as String?,
      key: json['key'] as String? ?? '',
      value: json['value'] as String? ?? '',
      isEnabled: json['isEnabled'] as bool? ?? true,
      isSecret: json['isSecret'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KeyValuePair &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          key == other.key &&
          value == other.value &&
          isEnabled == other.isEnabled &&
          isSecret == other.isSecret;

  @override
  int get hashCode => Object.hash(id, key, value, isEnabled, isSecret);
}

/// Supported HTTP request payload body types.
enum BodyType {
  none,
  json,
  text,
  formUrlEncoded;

  String get displayName {
    switch (this) {
      case BodyType.none:
        return 'none';
      case BodyType.json:
        return 'raw (JSON)';
      case BodyType.text:
        return 'raw (Text)';
      case BodyType.formUrlEncoded:
        return 'x-www-form-urlencoded';
    }
  }

  String? get contentType {
    switch (this) {
      case BodyType.none:
        return null;
      case BodyType.json:
        return 'application/json; charset=utf-8';
      case BodyType.text:
        return 'text/plain; charset=utf-8';
      case BodyType.formUrlEncoded:
        return 'application/x-www-form-urlencoded';
    }
  }
}

/// Immutable configuration of an HTTP request ready for execution.
@immutable
class HttpRequestData {
  final String id;
  final String name;
  final String method;
  final String url;
  final List<KeyValuePair> queryParams;
  final List<KeyValuePair> headers;
  final BodyType bodyType;
  final String bodyContent;
  final List<KeyValuePair> formData;
  final int timeoutSeconds;

  HttpRequestData({
    String? id,
    this.name = 'Untitled Request',
    required this.method,
    required this.url,
    this.queryParams = const [],
    this.headers = const [],
    this.bodyType = BodyType.none,
    this.bodyContent = '',
    this.formData = const [],
    this.timeoutSeconds = 30,
  }) : id = id ?? const Uuid().v4();

  /// Converts enabled query parameters into a Dart map.
  Map<String, String> get enabledQueryParams {
    final map = <String, String>{};
    for (final param in queryParams) {
      if (param.isEnabled && param.key.trim().isNotEmpty) {
        map[param.key.trim()] = param.value;
      }
    }
    return map;
  }

  /// Converts enabled headers into a Dart map.
  Map<String, String> get enabledHeaders {
    final map = <String, String>{};
    for (final header in headers) {
      if (header.isEnabled && header.key.trim().isNotEmpty) {
        map[header.key.trim()] = header.value;
      }
    }
    return map;
  }

  /// Converts enabled form URL encoded fields into a Dart map.
  Map<String, String> get enabledFormData {
    final map = <String, String>{};
    for (final field in formData) {
      if (field.isEnabled && field.key.trim().isNotEmpty) {
        map[field.key.trim()] = field.value;
      }
    }
    return map;
  }

  HttpRequestData copyWith({
    String? id,
    String? name,
    String? method,
    String? url,
    List<KeyValuePair>? queryParams,
    List<KeyValuePair>? headers,
    BodyType? bodyType,
    String? bodyContent,
    List<KeyValuePair>? formData,
    int? timeoutSeconds,
  }) {
    return HttpRequestData(
      id: id ?? this.id,
      name: name ?? this.name,
      method: method ?? this.method,
      url: url ?? this.url,
      queryParams: queryParams ?? this.queryParams,
      headers: headers ?? this.headers,
      bodyType: bodyType ?? this.bodyType,
      bodyContent: bodyContent ?? this.bodyContent,
      formData: formData ?? this.formData,
      timeoutSeconds: timeoutSeconds ?? this.timeoutSeconds,
    );
  }
}

/// Represents an HTTP response with timing, status, headers, and parsed payload.
@immutable
class HttpResponseData {
  final int statusCode;
  final String statusMessage;
  final Map<String, List<String>> headers;
  final String body;
  final int durationMs;
  final int contentLengthBytes;
  final String? contentType;
  final DateTime timestamp;

  const HttpResponseData({
    required this.statusCode,
    required this.statusMessage,
    required this.headers,
    required this.body,
    required this.durationMs,
    required this.contentLengthBytes,
    this.contentType,
    required this.timestamp,
  });

  bool get isSuccess => statusCode >= 200 && statusCode < 300;
  bool get isClientError => statusCode >= 400 && statusCode < 500;
  bool get isServerError => statusCode >= 500;

  /// Returns true if the body is valid JSON.
  bool get isJson {
    if (body.trim().isEmpty) return false;
    try {
      jsonDecode(body);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Returns formatted JSON string if payload is JSON, otherwise original body.
  String get formattedBody {
    if (body.trim().isEmpty) return '';
    try {
      final decoded = jsonDecode(body);
      return const JsonEncoder.withIndent('  ').convert(decoded);
    } catch (_) {
      return body;
    }
  }

  /// Formatted size in B, KB, or MB.
  String get formattedSize {
    if (contentLengthBytes < 1024) {
      return '$contentLengthBytes B';
    } else if (contentLengthBytes < 1024 * 1024) {
      return '${(contentLengthBytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(contentLengthBytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
  }

  /// Formatted duration in ms or seconds.
  String get formattedDuration {
    if (durationMs < 1000) {
      return '$durationMs ms';
    }
    return '${(durationMs / 1000).toStringAsFixed(2)} s';
  }
}
