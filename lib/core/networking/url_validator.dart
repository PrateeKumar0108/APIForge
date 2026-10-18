/// Helper for validating user-entered request URLs.
abstract final class UrlValidator {
  static final RegExp _variableRegex = RegExp(r'\{\{\s*[\w\.\-]+\s*\}\}');

  /// Validates a URL string. Returns an error message if invalid, or null if valid.
  static String? validate(String? rawUrl) {
    if (rawUrl == null || rawUrl.trim().isEmpty) {
      return 'URL cannot be empty.';
    }

    final trimmed = rawUrl.trim();

    // Check if the URL starts with a variable like {{baseUrl}}/path
    final hasVariablePrefix = _variableRegex.hasMatch(trimmed);

    // If it starts with variable interpolation, we allow it (scheme might be inside variable)
    if (trimmed.startsWith('{{')) {
      return null;
    }

    // Require http or https scheme if not starting with variable
    if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
      return 'URL must start with http:// or https:// (or a {{variable}}).';
    }

    // If URL contains variables (like {{host}} or {{port}}), Uri.parse may fail on non-numeric port
    final testUrl = hasVariablePrefix
        ? trimmed.replaceAll(_variableRegex, 'dummy')
        : trimmed;

    try {
      final uri = Uri.parse(testUrl);
      if (uri.host.isEmpty && !hasVariablePrefix) {
        return 'URL must contain a valid destination host.';
      }
      return null;
    } on FormatException catch (e) {
      if (hasVariablePrefix) return null;
      return 'Malformed URL: ${e.message}';
    }
  }

  /// Appends or updates query parameters in a URL string.
  static String buildUrlWithQueryParams(
    String baseUrl,
    Map<String, String> queryParams,
  ) {
    if (queryParams.isEmpty) return baseUrl;

    try {
      final uri = Uri.parse(baseUrl);
      final mergedParams = Map<String, String>.from(uri.queryParameters);
      mergedParams.addAll(queryParams);

      final updatedUri = uri.replace(queryParameters: mergedParams);
      return updatedUri.toString();
    } catch (_) {
      // Fallback if URL contains custom variables that fail standard URI parser
      final queryBuffer = StringBuffer();
      var first = !baseUrl.contains('?');
      for (final entry in queryParams.entries) {
        if (first) {
          queryBuffer.write('?');
          first = false;
        } else {
          queryBuffer.write('&');
        }
        queryBuffer.write(Uri.encodeComponent(entry.key));
        queryBuffer.write('=');
        queryBuffer.write(Uri.encodeComponent(entry.value));
      }
      return '$baseUrl$queryBuffer';
    }
  }
}
