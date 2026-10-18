import 'package:flutter_test/flutter_test.dart';
import 'package:apiforge/core/networking/curl_generator.dart';
import 'package:apiforge/core/networking/request_models.dart';

void main() {
  group('CurlGenerator', () {
    test('generates simple GET cURL command', () {
      final request = HttpRequestData(
        method: 'GET',
        url: 'https://httpbin.org/get',
        queryParams: [KeyValuePair(key: 'format', value: 'json')],
        headers: [KeyValuePair(key: 'Accept', value: 'application/json')],
      );

      final curl = CurlGenerator.generate(request);

      expect(curl, startsWith('curl'));
      expect(curl, contains("-H 'Accept: application/json'"));
      expect(curl, contains("'https://httpbin.org/get?format=json'"));
    });

    test('generates POST cURL command with JSON body and headers', () {
      final request = HttpRequestData(
        method: 'POST',
        url: 'https://httpbin.org/post',
        headers: [
          KeyValuePair(key: 'Authorization', value: 'Bearer token_abc_123'),
        ],
        bodyType: BodyType.json,
        bodyContent: '{"name":"APIForge"}',
      );

      final curl = CurlGenerator.generate(request);

      expect(curl, contains('-X POST'));
      expect(curl, contains("-H 'Authorization: Bearer token_abc_123'"));
      expect(
        curl,
        contains("-H 'Content-Type: application/json; charset=utf-8'"),
      );
      expect(curl, contains("-d '{\"name\":\"APIForge\"}'"));
    });

    test('redacts sensitive headers when redactSecrets is enabled', () {
      final request = HttpRequestData(
        method: 'GET',
        url: 'https://api.example.com/protected',
        headers: [
          KeyValuePair(
            key: 'Authorization',
            value: 'Bearer my-super-secret-token',
          ),
        ],
      );

      final curl = CurlGenerator.generate(request, redactSecrets: true);

      expect(curl, contains("-H 'Authorization: Bearer [REDACTED]'"));
      expect(curl, isNot(contains('my-super-secret-token')));
    });

    test('generates x-www-form-urlencoded body properly', () {
      final request = HttpRequestData(
        method: 'POST',
        url: 'https://httpbin.org/post',
        bodyType: BodyType.formUrlEncoded,
        formData: [
          KeyValuePair(key: 'user', value: 'dev'),
          KeyValuePair(key: 'code', value: '100%'),
        ],
      );

      final curl = CurlGenerator.generate(request);

      expect(curl, contains('-X POST'));
      expect(
        curl,
        contains("-H 'Content-Type: application/x-www-form-urlencoded'"),
      );
      expect(curl, contains("-d 'user=dev&code=100%25'"));
    });
  });
}
