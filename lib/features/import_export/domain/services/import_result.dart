import '../../../../core/networking/request_models.dart';
import '../../../authentication/domain/models/auth_config.dart';

/// Represents a validated request ready to be persisted into SQLite during import.
class ImportedRequest {
  final String name;
  final String? description;
  final String method;
  final String url;
  final List<KeyValuePair> queryParams;
  final List<KeyValuePair> headers;
  final BodyType bodyType;
  final String bodyContent;
  final List<KeyValuePair> formData;
  final AuthConfig authConfig;
  final String? folderName;

  const ImportedRequest({
    required this.name,
    this.description,
    required this.method,
    required this.url,
    this.queryParams = const [],
    this.headers = const [],
    this.bodyType = BodyType.none,
    this.bodyContent = '',
    this.formData = const [],
    this.authConfig = const AuthConfig(type: AuthType.none),
    this.folderName,
  });
}

/// The result of parsing and validating an external or internal collection definition.
class ImportResult {
  final String collectionName;
  final String? collectionDescription;
  final List<ImportedRequest> requests;
  final List<String> warnings;

  const ImportResult({
    required this.collectionName,
    this.collectionDescription,
    required this.requests,
    this.warnings = const [],
  });
}
