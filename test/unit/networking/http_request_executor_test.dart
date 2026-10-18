import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apiforge/core/errors/app_failure.dart';
import 'package:apiforge/core/networking/http_request_executor.dart';
import 'package:apiforge/core/networking/request_models.dart';

/// Test adapter that intercepts Dio calls and returns mocked [ResponseBody] or throws.
class MockHttpAdapter implements HttpClientAdapter {
  final Future<ResponseBody> Function(RequestOptions options) handler;

  MockHttpAdapter(this.handler);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('HttpRequestExecutor', () {
    test(
      'successfully executes GET and returns HttpResponseData with timing',
      () async {
        final dio = Dio();
        dio.httpClientAdapter = MockHttpAdapter((options) async {
          final payload = jsonEncode({'status': 'ok', 'user': 'alex'});
          return ResponseBody.fromString(
            payload,
            200,
            headers: {
              'content-type': ['application/json'],
              'content-length': [payload.length.toString()],
            },
            statusMessage: 'OK',
          );
        });

        final executor = HttpRequestExecutor(dio: dio);
        final request = HttpRequestData(
          method: 'GET',
          url: 'https://api.example.com/status',
        );

        final response = await executor.execute(request);

        expect(response.statusCode, equals(200));
        expect(response.statusMessage, equals('OK'));
        expect(response.isSuccess, isTrue);
        expect(response.isJson, isTrue);
        expect(response.body, contains('"status":"ok"'));
        expect(response.durationMs, greaterThanOrEqualTo(0));
        expect(response.contentLengthBytes, greaterThan(0));
        expect(response.headers['content-type'], contains('application/json'));
      },
    );

    test(
      'treats 404 Not Found as valid inspectable response without throwing',
      () async {
        final dio = Dio();
        dio.httpClientAdapter = MockHttpAdapter((options) async {
          return ResponseBody.fromString(
            jsonEncode({'error': 'Resource not found'}),
            404,
            headers: {
              'content-type': ['application/json'],
            },
            statusMessage: 'Not Found',
          );
        });

        final executor = HttpRequestExecutor(dio: dio);
        final request = HttpRequestData(
          method: 'GET',
          url: 'https://api.example.com/missing-item',
        );

        final response = await executor.execute(request);

        expect(response.statusCode, equals(404));
        expect(response.statusMessage, equals('Not Found'));
        expect(response.isSuccess, isFalse);
        expect(response.isClientError, isTrue);
        expect(response.body, contains('Resource not found'));
      },
    );

    test(
      'treats 500 Internal Server Error as valid inspectable response',
      () async {
        final dio = Dio();
        dio.httpClientAdapter = MockHttpAdapter((options) async {
          return ResponseBody.fromString(
            'Internal server error occurred',
            500,
            headers: {
              'content-type': ['text/plain'],
            },
            statusMessage: 'Internal Server Error',
          );
        });

        final executor = HttpRequestExecutor(dio: dio);
        final request = HttpRequestData(
          method: 'POST',
          url: 'https://api.example.com/crash',
          bodyType: BodyType.text,
          bodyContent: 'crash trigger',
        );

        final response = await executor.execute(request);

        expect(response.statusCode, equals(500));
        expect(response.isServerError, isTrue);
        expect(response.body, equals('Internal server error occurred'));
      },
    );

    test('maps connection timeout to TimeoutFailure', () async {
      final dio = Dio();
      dio.httpClientAdapter = MockHttpAdapter((options) async {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionTimeout,
          message: 'Connection timed out after 30000ms',
        );
      });

      final executor = HttpRequestExecutor(dio: dio);
      final request = HttpRequestData(
        method: 'GET',
        url: 'https://api.example.com/slow',
      );

      expect(() => executor.execute(request), throwsA(isA<TimeoutFailure>()));
    });

    test('maps request cancellation to CancelledFailure', () async {
      final dio = Dio();
      dio.httpClientAdapter = MockHttpAdapter((options) async {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.cancel,
          message: 'User cancelled request.',
        );
      });

      final executor = HttpRequestExecutor(dio: dio);
      final request = HttpRequestData(
        method: 'GET',
        url: 'https://api.example.com/in-flight',
      );

      expect(() => executor.execute(request), throwsA(isA<CancelledFailure>()));
    });

    test('maps connection error to NetworkFailure', () async {
      final dio = Dio();
      dio.httpClientAdapter = MockHttpAdapter((options) async {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          message: 'SocketException: OS Error: Connection refused',
        );
      });

      final executor = HttpRequestExecutor(dio: dio);
      final request = HttpRequestData(
        method: 'GET',
        url: 'https://api.example.com/offline',
      );

      expect(() => executor.execute(request), throwsA(isA<NetworkFailure>()));
    });

    test('rejects invalid URL immediately with ValidationFailure', () async {
      final executor = HttpRequestExecutor();
      final request = HttpRequestData(
        method: 'GET',
        url: 'ftp://not-supported.com',
      );

      expect(
        () => executor.execute(request),
        throwsA(isA<ValidationFailure>()),
      );
    });
  });
}
