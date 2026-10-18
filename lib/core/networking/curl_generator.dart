import 'request_models.dart';
import 'secret_redactor.dart';
import 'url_validator.dart';

/// Utility to generate reproducible cURL commands from an [HttpRequestData].
abstract final class CurlGenerator {
  /// Generates a cURL command string.
  /// If [redactSecrets] is true, sensitive tokens and headers are masked.
  static String generate(
    HttpRequestData request, {
    bool redactSecrets = false,
  }) {
    final buffer = StringBuffer('curl');

    final method = request.method.toUpperCase();
    if (method != 'GET') {
      buffer.write(' -X $method');
    }

    // Process headers
    var headers = request.enabledHeaders;
    if (redactSecrets) {
      headers = SecretRedactor.redactHeaders(headers);
    }

    // Ensure Content-Type is included if body is present and not already specified
    final contentType = request.bodyType.contentType;
    if (contentType != null &&
        !headers.keys.any((k) => k.toLowerCase() == 'content-type')) {
      headers = Map.from(headers);
      headers['Content-Type'] = contentType;
    }

    for (final entry in headers.entries) {
      final escapedHeader = entry.value.replaceAll("'", r"\'");
      buffer.write(" -H '${entry.key}: $escapedHeader'");
    }

    // Process Body
    if (method != 'GET' && method != 'HEAD') {
      switch (request.bodyType) {
        case BodyType.none:
          break;
        case BodyType.json:
        case BodyType.text:
          if (request.bodyContent.trim().isNotEmpty) {
            final escapedBody = request.bodyContent.replaceAll("'", r"\'");
            buffer.write(" -d '$escapedBody'");
          }
          break;
        case BodyType.formUrlEncoded:
          final formData = request.enabledFormData;
          if (formData.isNotEmpty) {
            final encoded = formData.entries
                .map(
                  (e) =>
                      '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
                )
                .join('&');
            buffer.write(" -d '$encoded'");
          }
          break;
      }
    }

    // Full URL with query parameters
    var finalUrl = UrlValidator.buildUrlWithQueryParams(
      request.url,
      request.enabledQueryParams,
    );

    buffer.write(" '$finalUrl'");

    return buffer.toString();
  }
}
