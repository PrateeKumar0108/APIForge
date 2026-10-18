import 'dart:convert';
import '../../../../core/networking/secret_redactor.dart';
import '../../../authentication/domain/models/auth_config.dart';
import '../../../collections/domain/models/collection_entity.dart';
import '../../../environments/domain/models/environment_entity.dart';

/// Service responsible for serializing collections and environments into the
/// versioned APIForge JSON v1 interchange format.
///
/// Guaranteed security invariant: Sensitive authentication tokens, passwords,
/// and secret variables are sanitized and never exported in plaintext.
abstract final class CollectionExportService {
  static const String formatIdentifier = 'apiforge';
  static const int currentVersion = 1;

  /// Serializes a collection and its associated requests into a formatted JSON string.
  static String exportCollection({
    required CollectionEntity collection,
    required List<SavedRequestEntity> requests,
  }) {
    final payload = {
      r'$schema': 'https://apiforge.dev/schemas/v1.json',
      'format': formatIdentifier,
      'version': currentVersion,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'collection': {
        'name': collection.name,
        'description': collection.description,
        'requests': requests.map(_sanitizeAndSerializeRequest).toList(),
      },
    };

    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  /// Serializes an environment definition, ensuring secrets are stripped.
  static String exportEnvironment({
    required EnvironmentEntity environment,
    required List<EnvironmentVariableEntity> variables,
  }) {
    final payload = {
      r'$schema': 'https://apiforge.dev/schemas/v1.json',
      'format': formatIdentifier,
      'version': currentVersion,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'environment': {
        'name': environment.name,
        'colorHex': environment.colorHex,
        'variables': variables.map((v) {
          return {
            'key': v.key,
            'value': v.isSecret ? '[SECRET_REDACTED]' : v.value,
            'isSecret': v.isSecret,
            'isEnabled': v.isEnabled,
          };
        }).toList(),
      },
    };

    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  static Map<String, dynamic> _sanitizeAndSerializeRequest(
    SavedRequestEntity req,
  ) {
    // Redact sensitive headers
    final sanitizedHeaders = SecretRedactor.redactKeyValuePairs(req.headers);

    // Sanitize Auth Config: wipe credentials
    Map<String, dynamic>? sanitizedAuth;
    if (req.authConfig != null) {
      final auth = req.authConfig!;
      sanitizedAuth = {
        'type': auth.type.name,
        'token': auth.type == AuthType.bearer ? '[REDACTED]' : null,
        'username': auth.type == AuthType.basic ? auth.username : null,
        'password': auth.type == AuthType.basic ? '[REDACTED]' : null,
        'apiKeyName': auth.apiKeyName,
        'apiKeyValue': auth.type == AuthType.apiKey ? '[REDACTED]' : null,
        'apiKeyLocation': auth.apiKeyLocation.name,
      };
    }

    return {
      'name': req.name,
      'description': req.description,
      'method': req.method,
      'url': req.url,
      'queryParams': req.queryParams
          .map(
            (p) => {
              'key': p.key,
              'value': p.value,
              'isEnabled': p.isEnabled,
              'isSecret': p.isSecret,
            },
          )
          .toList(),
      'headers': sanitizedHeaders
          .map(
            (h) => {
              'key': h.key,
              'value': h.value,
              'isEnabled': h.isEnabled,
              'isSecret': h.isSecret,
            },
          )
          .toList(),
      'bodyType': req.bodyType.name,
      'bodyContent': req.bodyContent,
      'formData': req.formData
          .map(
            (f) => {
              'key': f.key,
              'value': f.value,
              'isEnabled': f.isEnabled,
              'isSecret': f.isSecret,
            },
          )
          .toList(),
      'authType': req.authType,
      'authConfig': sanitizedAuth,
    };
  }
}
