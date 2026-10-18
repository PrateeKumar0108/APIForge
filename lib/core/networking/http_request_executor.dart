import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../errors/app_failure.dart';
import 'request_models.dart';
import 'url_validator.dart';

/// Contract for executing HTTP requests against remote or local hosts.
abstract interface class IHttpRequestExecutor {
  Future<HttpResponseData> execute(
    HttpRequestData request, {
    CancelToken? cancelToken,
  });
}

/// Production implementation of [IHttpRequestExecutor] using [Dio].
///
/// Features:
/// - Treats 4xx and 5xx HTTP status codes as valid inspectable responses.
/// - Accurately records round-trip latency via [Stopwatch].
/// - Converts Dio exceptions into typed, leak-safe [AppFailure] instances.
/// - Prevents automatic retries on non-idempotent operations.
class HttpRequestExecutor implements IHttpRequestExecutor {
  final Dio _dio;

  HttpRequestExecutor({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              responseType: ResponseType.plain,
              // Do not throw on 4xx/5xx; API testers must inspect error responses
              validateStatus: (status) => true,
              followRedirects: true,
              maxRedirects: 5,
            ),
          );

  @override
  Future<HttpResponseData> execute(
    HttpRequestData request, {
    CancelToken? cancelToken,
  }) async {
    // 1. Validate URL
    final urlError = UrlValidator.validate(request.url);
    if (urlError != null) {
      throw ValidationFailure(urlError);
    }

    // 2. Prepare URL and query parameters
    final requestUrl = request.url;
    final queryParams = request.enabledQueryParams;

    // 3. Prepare headers
    final headers = Map<String, dynamic>.from(request.enabledHeaders);

    // Ensure content type header matches body type
    final autoContentType = request.bodyType.contentType;
    if (autoContentType != null &&
        !headers.keys.any((k) => k.toLowerCase() == 'content-type')) {
      headers['Content-Type'] = autoContentType;
    }

    // Default User-Agent if not set
    if (!headers.keys.any((k) => k.toLowerCase() == 'user-agent')) {
      headers['User-Agent'] = 'APIForge/1.0.0 (Mobile REST Client)';
    }

    // 4. Prepare Body data
    dynamic requestBody;
    final method = request.method.toUpperCase();

    if (method != 'GET' && method != 'HEAD') {
      switch (request.bodyType) {
        case BodyType.none:
          requestBody = null;
          break;
        case BodyType.json:
        case BodyType.text:
          requestBody = request.bodyContent;
          break;
        case BodyType.formUrlEncoded:
          requestBody = request.enabledFormData;
          break;
      }
    }

    // 5. Configure execution options
    final options = Options(
      method: method,
      headers: headers,
      responseType: ResponseType.plain,
      sendTimeout: Duration(seconds: request.timeoutSeconds),
      receiveTimeout: Duration(seconds: request.timeoutSeconds),
      // Validate all statuses so error responses are inspectable
      validateStatus: (status) => true,
    );

    final stopwatch = Stopwatch()..start();

    try {
      final response = await _dio.request<String>(
        requestUrl,
        data: requestBody,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        options: options,
        cancelToken: cancelToken,
      );

      stopwatch.stop();

      final responseBody = response.data ?? '';
      final bodyBytes = utf8.encode(responseBody);

      // Extract headers into Map<String, List<String>>
      final responseHeaders = <String, List<String>>{};
      response.headers.forEach((name, values) {
        responseHeaders[name] = values;
      });

      // Calculate payload size: prefer Content-Length header, fallback to byte length
      final contentLengthHeader = response.headers.value('content-length');
      final size = contentLengthHeader != null
          ? (int.tryParse(contentLengthHeader) ?? bodyBytes.length)
          : bodyBytes.length;

      return HttpResponseData(
        statusCode: response.statusCode ?? 0,
        statusMessage: response.statusMessage ?? '',
        headers: responseHeaders,
        body: responseBody,
        durationMs: stopwatch.elapsedMilliseconds,
        contentLengthBytes: size,
        contentType: response.headers.value('content-type'),
        timestamp: DateTime.now(),
      );
    } on DioException catch (dioError) {
      stopwatch.stop();
      throw _mapDioError(dioError);
    } catch (unexpected) {
      stopwatch.stop();
      if (unexpected is AppFailure) rethrow;
      throw UnexpectedFailure(
        'An unexpected error occurred while sending the request.',
        unexpected.toString(),
      );
    }
  }

  /// Maps low-level Dio exceptions into typed, user-safe [AppFailure] instances.
  AppFailure _mapDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.cancel:
        return const CancelledFailure('The request was cancelled by user.');

      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return TimeoutFailure(
          'Request timed out. The server took too long to respond.',
          error.message,
        );

      case DioExceptionType.badCertificate:
        return TlsFailure(
          'TLS/SSL Certificate validation failed for the target server.',
          error.message,
        );

      case DioExceptionType.connectionError:
        return NetworkFailure(
          'Network connection failed. Verify host, port, and your internet connection.',
          error.message,
        );

      case DioExceptionType.badResponse:
        // When validateStatus allows all codes, badResponse only triggers if something malformed occurred
        return NetworkFailure(
          'Invalid response received from server.',
          error.message,
        );

      case DioExceptionType.unknown:
        final message =
            error.message ?? error.error?.toString() ?? 'Unknown error';
        if (message.toLowerCase().contains('socketexception') ||
            message.toLowerCase().contains('connection refused') ||
            message.toLowerCase().contains('failed host lookup')) {
          return NetworkFailure(
            'Unable to resolve or connect to target host.',
            message,
          );
        }
        return UnexpectedFailure('Network error encountered.', message);
    }
  }
}
