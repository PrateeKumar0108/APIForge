import 'package:flutter_test/flutter_test.dart';
import 'package:apiforge/core/networking/request_models.dart';
import 'package:apiforge/core/networking/secret_redactor.dart';

void main() {
  group('SecretRedactor', () {
    test('masks Bearer tokens in Authorization header', () {
      final headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer super-secret-jwt-token-12345',
      };

      final sanitized = SecretRedactor.redactHeaders(headers);

      expect(sanitized['Accept'], equals('application/json'));
      expect(sanitized['Authorization'], equals('Bearer [REDACTED]'));
    });

    test('masks Basic credentials in Authorization header', () {
      final headers = {'Authorization': 'Basic dXNlcjpwYXNz'};

      final sanitized = SecretRedactor.redactHeaders(headers);

      expect(sanitized['Authorization'], equals('Basic [REDACTED]'));
    });

    test('masks custom api keys and secrets', () {
      final headers = {
        'X-API-Key': 'key_live_99998888',
        'client-secret': 'sec_7777',
        'Host': 'api.example.com',
      };

      final sanitized = SecretRedactor.redactHeaders(headers);

      expect(sanitized['X-API-Key'], equals('[REDACTED]'));
      expect(sanitized['client-secret'], equals('[REDACTED]'));
      expect(sanitized['Host'], equals('api.example.com'));
    });

    test(
      'masks secret query parameters marked isSecret or matching sensitive names',
      () {
        final params = [
          KeyValuePair(key: 'page', value: '1'),
          KeyValuePair(key: 'apiKey', value: 'secret-val-123'),
          KeyValuePair(key: 'customParam', value: 'my-pass', isSecret: true),
        ];

        final sanitized = SecretRedactor.redactQueryParams(params);

        expect(sanitized[0].value, equals('1'));
        expect(sanitized[1].value, equals('[REDACTED]'));
        expect(sanitized[2].value, equals('[REDACTED]'));
      },
    );
  });
}
