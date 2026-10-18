import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../../core/networking/request_models.dart';

/// Domain representation of an executed request history record.
@immutable
class HistoryEntryEntity {
  final String id;
  final String method;
  final String url;
  final int statusCode;
  final String statusMessage;
  final int durationMs;
  final int contentLengthBytes;
  final List<KeyValuePair> requestHeaders;
  final Map<String, List<String>> responseHeaders;
  final String? bodyContent;
  final DateTime executedAt;

  const HistoryEntryEntity({
    required this.id,
    required this.method,
    required this.url,
    required this.statusCode,
    required this.statusMessage,
    required this.durationMs,
    required this.contentLengthBytes,
    required this.requestHeaders,
    required this.responseHeaders,
    this.bodyContent,
    required this.executedAt,
  });

  /// Formatted duration string (ms or s).
  String get formattedDuration {
    if (durationMs < 1000) {
      return '$durationMs ms';
    }
    return '${(durationMs / 1000).toStringAsFixed(2)} s';
  }

  /// Formatted size string.
  String get formattedSize {
    if (contentLengthBytes < 1024) {
      return '$contentLengthBytes B';
    } else if (contentLengthBytes < 1024 * 1024) {
      return '${(contentLengthBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(contentLengthBytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  /// Converts history record into an executable [HttpRequestData] for one-click replay.
  HttpRequestData toHttpRequestData() {
    return HttpRequestData(
      name: 'Replayed: $method $url',
      method: method,
      url: url,
      headers: requestHeaders,
      bodyType: bodyContent != null && bodyContent!.trim().isNotEmpty
          ? BodyType.json
          : BodyType.none,
      bodyContent: bodyContent ?? '',
    );
  }

  static List<KeyValuePair> decodeHeaders(String rawJson) {
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

  static Map<String, List<String>> decodeResponseHeaders(String rawJson) {
    if (rawJson.trim().isEmpty) return {};
    try {
      final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
      final result = <String, List<String>>{};
      decoded.forEach((key, val) {
        if (val is List) {
          result[key] = val.map((e) => e.toString()).toList();
        } else {
          result[key] = [val.toString()];
        }
      });
      return result;
    } catch (_) {
      return {};
    }
  }
}
