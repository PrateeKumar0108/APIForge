import 'package:flutter_test/flutter_test.dart';
import 'package:apiforge/core/networking/url_validator.dart';

void main() {
  group('UrlValidator', () {
    test('validates valid http and https URLs', () {
      expect(UrlValidator.validate('https://api.github.com/users'), isNull);
      expect(UrlValidator.validate('http://localhost:8080/health'), isNull);
      expect(UrlValidator.validate('https://httpbin.org/get?foo=bar'), isNull);
    });

    test('accepts URLs with variable placeholders like {{baseUrl}}', () {
      expect(UrlValidator.validate('{{baseUrl}}/users'), isNull);
      expect(UrlValidator.validate('https://{{host}}:{{port}}/api'), isNull);
    });

    test('rejects empty or whitespace URLs', () {
      expect(UrlValidator.validate(''), isNotNull);
      expect(UrlValidator.validate('   '), isNotNull);
      expect(UrlValidator.validate(null), isNotNull);
    });

    test('rejects URLs with missing or invalid schemes', () {
      expect(UrlValidator.validate('ftp://files.example.com'), isNotNull);
      expect(UrlValidator.validate('api.example.com/endpoint'), isNotNull);
    });

    test(
      'buildUrlWithQueryParams correctly appends and encodes query parameters',
      () {
        final base = 'https://api.example.com/search';
        final params = {'q': 'flutter test', 'page': '1', 'tags': 'dart&dio'};

        final result = UrlValidator.buildUrlWithQueryParams(base, params);

        expect(result, contains('q=flutter+test'));
        expect(result, contains('page=1'));
        expect(result, contains('tags=dart%26dio'));
      },
    );

    test('buildUrlWithQueryParams preserves existing query params', () {
      final base = 'https://api.example.com/items?sort=desc';
      final params = {'limit': '10'};

      final result = UrlValidator.buildUrlWithQueryParams(base, params);

      expect(result, contains('sort=desc'));
      expect(result, contains('limit=10'));
    });
  });
}
