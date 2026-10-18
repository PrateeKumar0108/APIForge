import 'request_models.dart';

/// Helper to sanitize sensitive credentials from diagnostics, cURL exports,
/// and log outputs.
abstract final class SecretRedactor {
  static final RegExp _sensitiveKeyRegex = RegExp(
    r'(authorization|token|secret|password|api[_-]?key|access[_-]?token|client[_-]?secret|cookie|session)',
    caseSensitive: false,
  );

  /// Checks if a header or parameter key is likely sensitive.
  static bool isSensitiveKey(String key) {
    return _sensitiveKeyRegex.hasMatch(key);
  }

  /// Redacts sensitive header values.
  static Map<String, String> redactHeaders(
    Map<String, String> headers, {
    String placeholder = '[REDACTED]',
  }) {
    final sanitized = <String, String>{};
    for (final entry in headers.entries) {
      if (isSensitiveKey(entry.key)) {
        if (entry.key.toLowerCase() == 'authorization' &&
            entry.value.startsWith('Bearer ')) {
          sanitized[entry.key] = 'Bearer $placeholder';
        } else if (entry.key.toLowerCase() == 'authorization' &&
            entry.value.startsWith('Basic ')) {
          sanitized[entry.key] = 'Basic $placeholder';
        } else {
          sanitized[entry.key] = placeholder;
        }
      } else {
        sanitized[entry.key] = entry.value;
      }
    }
    return sanitized;
  }

  /// Redacts sensitive query parameters or header KeyValuePairs.
  static List<KeyValuePair> redactKeyValuePairs(
    List<KeyValuePair> pairs, {
    String placeholder = '[REDACTED]',
  }) {
    return pairs.map((pair) {
      if (pair.isSecret || isSensitiveKey(pair.key)) {
        if (pair.key.toLowerCase() == 'authorization' &&
            pair.value.startsWith('Bearer ')) {
          return pair.copyWith(value: 'Bearer $placeholder');
        } else if (pair.key.toLowerCase() == 'authorization' &&
            pair.value.startsWith('Basic ')) {
          return pair.copyWith(value: 'Basic $placeholder');
        }
        return pair.copyWith(value: placeholder);
      }
      return pair;
    }).toList();
  }

  /// Redacts sensitive query parameters.
  static List<KeyValuePair> redactQueryParams(
    List<KeyValuePair> params, {
    String placeholder = '[REDACTED]',
  }) => redactKeyValuePairs(params, placeholder: placeholder);
}
