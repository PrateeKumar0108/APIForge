import '../../../../core/networking/request_models.dart';

/// Engine responsible for {{variable}} interpolation, precedence resolution,
/// and detection of unresolved template tokens.
abstract final class VariableSubstitutionEngine {
  static final RegExp variableRegex = RegExp(r'\{\{\s*([\w\.\-]+)\s*\}\}');

  /// Substitutes {{variable}} placeholders within a template string.
  static String substitute(String template, Map<String, String> variables) {
    if (template.isEmpty || variables.isEmpty) return template;

    return template.replaceAllMapped(variableRegex, (match) {
      final key = match.group(1)?.trim();
      if (key != null && variables.containsKey(key)) {
        return variables[key]!;
      }
      return match.group(0)!; // Preserve unresolved token
    });
  }

  /// Identifies any {{variable}} tokens in [template] that do not exist in [variables].
  static List<String> findUnresolvedVariables(
    String template,
    Map<String, String> variables,
  ) {
    final unresolved = <String>{};
    for (final match in variableRegex.allMatches(template)) {
      final key = match.group(1)?.trim();
      if (key != null && !variables.containsKey(key)) {
        unresolved.add(key);
      }
    }
    return unresolved.toList();
  }

  /// Evaluates and substitutes variables in an [HttpRequestData] according to precedence:
  /// 1. Request-local variables
  /// 2. Active environment variables
  /// 3. Workspace defaults
  ///
  /// Returns a record containing the fully interpolated request and a list of any unresolved variable tokens.
  static ({HttpRequestData request, List<String> unresolvedVariables})
  substituteRequest({
    required HttpRequestData request,
    Map<String, String> requestVariables = const {},
    Map<String, String> environmentVariables = const {},
    Map<String, String> workspaceDefaults = const {},
  }) {
    // 1. Build composite variable resolution map with precedence.
    // Request-local overrides must win over environment and workspace values.
    final effectiveVariables = <String, String>{};
    effectiveVariables.addAll(workspaceDefaults);
    effectiveVariables.addAll(environmentVariables);
    effectiveVariables.addAll(requestVariables);

    // Collect all template strings to inspect for unresolved tokens
    final templatesToScan = <String>[request.url];

    // 2. Interpolate URL
    final resolvedUrl = substitute(request.url, effectiveVariables);

    // 3. Interpolate Query Parameters
    final resolvedQueryParams = request.queryParams.map((p) {
      if (!p.isEnabled) return p;
      templatesToScan.add(p.key);
      templatesToScan.add(p.value);
      return p.copyWith(
        key: substitute(p.key, effectiveVariables),
        value: substitute(p.value, effectiveVariables),
      );
    }).toList();

    // 4. Interpolate Headers
    final resolvedHeaders = request.headers.map((h) {
      if (!h.isEnabled) return h;
      templatesToScan.add(h.key);
      templatesToScan.add(h.value);
      return h.copyWith(
        key: substitute(h.key, effectiveVariables),
        value: substitute(h.value, effectiveVariables),
      );
    }).toList();

    // 5. Interpolate Body (only for text formats, never for binary)
    var resolvedBodyContent = request.bodyContent;
    if (request.bodyType == BodyType.json ||
        request.bodyType == BodyType.text) {
      if (request.bodyContent.trim().isNotEmpty) {
        templatesToScan.add(request.bodyContent);
        resolvedBodyContent = substitute(
          request.bodyContent,
          effectiveVariables,
        );
      }
    }

    final resolvedFormData = request.formData.map((f) {
      if (!f.isEnabled) return f;
      templatesToScan.add(f.key);
      templatesToScan.add(f.value);
      return f.copyWith(
        key: substitute(f.key, effectiveVariables),
        value: substitute(f.value, effectiveVariables),
      );
    }).toList();

    // 6. Gather all unresolved variable tokens across the request
    final allUnresolved = <String>{};
    for (final template in templatesToScan) {
      allUnresolved.addAll(
        findUnresolvedVariables(template, effectiveVariables),
      );
    }

    final interpolatedRequest = request.copyWith(
      url: resolvedUrl,
      queryParams: resolvedQueryParams,
      headers: resolvedHeaders,
      bodyContent: resolvedBodyContent,
      formData: resolvedFormData,
    );

    return (
      request: interpolatedRequest,
      unresolvedVariables: allUnresolved.toList(),
    );
  }
}
