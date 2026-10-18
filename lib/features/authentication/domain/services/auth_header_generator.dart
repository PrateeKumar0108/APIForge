import 'dart:convert';
import '../../../../core/networking/request_models.dart';
import '../models/auth_config.dart';

/// Service responsible for injecting authentication headers/query params
/// and enforcing secure cross-host redirect policies.
abstract final class AuthHeaderGenerator {
  /// Injects authentication credentials from [config] into [request].
  static HttpRequestData applyAuth(HttpRequestData request, AuthConfig config) {
    if (config.type == AuthType.none) {
      return request;
    }

    final headers = List<KeyValuePair>.from(request.headers);
    final queryParams = List<KeyValuePair>.from(request.queryParams);

    switch (config.type) {
      case AuthType.none:
        break;

      case AuthType.bearer:
        final token = config.token?.trim() ?? '';
        if (token.isNotEmpty) {
          // Remove existing Authorization header if present
          headers.removeWhere((h) => h.key.toLowerCase() == 'authorization');
          headers.add(
            KeyValuePair(
              key: 'Authorization',
              value: 'Bearer $token',
              isSecret: true,
            ),
          );
        }
        break;

      case AuthType.basic:
        final username = config.username ?? '';
        final password = config.password ?? '';
        final credentials = '$username:$password';
        final encoded = base64Encode(utf8.encode(credentials));
        headers.removeWhere((h) => h.key.toLowerCase() == 'authorization');
        headers.add(
          KeyValuePair(
            key: 'Authorization',
            value: 'Basic $encoded',
            isSecret: true,
          ),
        );
        break;

      case AuthType.apiKey:
        final keyName = config.apiKeyName?.trim() ?? '';
        final keyValue = config.apiKeyValue?.trim() ?? '';
        if (keyName.isNotEmpty) {
          if (config.apiKeyLocation == ApiKeyLocation.header) {
            headers.removeWhere(
              (h) => h.key.toLowerCase() == keyName.toLowerCase(),
            );
            headers.add(
              KeyValuePair(key: keyName, value: keyValue, isSecret: true),
            );
          } else {
            queryParams.removeWhere(
              (p) => p.key.toLowerCase() == keyName.toLowerCase(),
            );
            queryParams.add(
              KeyValuePair(key: keyName, value: keyValue, isSecret: true),
            );
          }
        }
        break;
    }

    return request.copyWith(headers: headers, queryParams: queryParams);
  }

  /// Enforces safe redirect policy: strips Authorization credentials
  /// if the destination redirect host differs from the original request host.
  static Map<String, String> stripAuthOnHostChange({
    required Uri originalUri,
    required Uri redirectUri,
    required Map<String, String> headers,
  }) {
    if (originalUri.host.toLowerCase() == redirectUri.host.toLowerCase()) {
      return headers;
    }

    // Host has changed: purge sensitive authorization & cookie headers
    final sanitized = Map<String, String>.from(headers);
    sanitized.removeWhere(
      (key, _) =>
          key.toLowerCase() == 'authorization' ||
          key.toLowerCase() == 'cookie' ||
          key.toLowerCase() == 'set-cookie',
    );
    return sanitized;
  }
}
