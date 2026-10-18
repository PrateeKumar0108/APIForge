import 'package:flutter_test/flutter_test.dart';
import 'package:apiforge/core/networking/request_models.dart';
import 'package:apiforge/features/authentication/domain/models/auth_config.dart';
import 'package:apiforge/features/authentication/domain/services/auth_header_generator.dart';

void main() {
  group('AuthHeaderGenerator', () {
    test('injects Bearer token into Authorization header', () {
      final request = HttpRequestData(
        method: 'GET',
        url: 'https://api.example.com/protected',
      );

      const config = AuthConfig(
        type: AuthType.bearer,
        token: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.test',
      );

      final result = AuthHeaderGenerator.applyAuth(request, config);

      final authHeader = result.headers.firstWhere(
        (h) => h.key == 'Authorization',
      );
      expect(
        authHeader.value,
        equals('Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.test'),
      );
      expect(authHeader.isSecret, isTrue);
    });

    test('encodes username and password into Basic base64 header', () {
      final request = HttpRequestData(
        method: 'GET',
        url: 'https://api.example.com/admin',
      );

      const config = AuthConfig(
        type: AuthType.basic,
        username: 'admin',
        password: 'password123',
      );

      final result = AuthHeaderGenerator.applyAuth(request, config);

      final authHeader = result.headers.firstWhere(
        (h) => h.key == 'Authorization',
      );
      // base64('admin:password123') == 'YWRtaW46cGFzc3dvcmQxMjM='
      expect(authHeader.value, equals('Basic YWRtaW46cGFzc3dvcmQxMjM='));
      expect(authHeader.isSecret, isTrue);
    });

    test('injects API Key into headers when location is header', () {
      final request = HttpRequestData(
        method: 'GET',
        url: 'https://api.example.com/data',
      );

      const config = AuthConfig(
        type: AuthType.apiKey,
        apiKeyName: 'X-API-Key',
        apiKeyValue: 'key_live_abcdef123',
        apiKeyLocation: ApiKeyLocation.header,
      );

      final result = AuthHeaderGenerator.applyAuth(request, config);

      final header = result.headers.firstWhere((h) => h.key == 'X-API-Key');
      expect(header.value, equals('key_live_abcdef123'));
      expect(header.isSecret, isTrue);
    });

    test('injects API Key into query parameters when location is query', () {
      final request = HttpRequestData(
        method: 'GET',
        url: 'https://api.example.com/data',
      );

      const config = AuthConfig(
        type: AuthType.apiKey,
        apiKeyName: 'api_key',
        apiKeyValue: 'key_query_789',
        apiKeyLocation: ApiKeyLocation.query,
      );

      final result = AuthHeaderGenerator.applyAuth(request, config);

      final param = result.queryParams.firstWhere((p) => p.key == 'api_key');
      expect(param.value, equals('key_query_789'));
      expect(param.isSecret, isTrue);
    });

    test(
      'enforces safe redirect policy: strips authorization when redirect host differs',
      () {
        final original = Uri.parse('https://secure.internal.com/v1/resource');
        final redirectCrossHost = Uri.parse('https://thirdparty-cdn.com/file');
        final redirectSameHost = Uri.parse(
          'https://secure.internal.com/v2/resource',
        );

        final headers = {
          'Accept': 'application/json',
          'Authorization': 'Bearer confidential-token',
          'Cookie': 'sessionId=abc123xyz',
        };

        // Cross-host redirect MUST purge Authorization and Cookie
        final crossHostResult = AuthHeaderGenerator.stripAuthOnHostChange(
          originalUri: original,
          redirectUri: redirectCrossHost,
          headers: headers,
        );

        expect(crossHostResult.containsKey('Authorization'), isFalse);
        expect(crossHostResult.containsKey('Cookie'), isFalse);
        expect(crossHostResult['Accept'], equals('application/json'));

        // Same-host redirect preserves Authorization
        final sameHostResult = AuthHeaderGenerator.stripAuthOnHostChange(
          originalUri: original,
          redirectUri: redirectSameHost,
          headers: headers,
        );

        expect(
          sameHostResult['Authorization'],
          equals('Bearer confidential-token'),
        );
      },
    );
  });
}
