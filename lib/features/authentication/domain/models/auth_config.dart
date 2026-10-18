import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Supported authentication schemes.
enum AuthType {
  none,
  bearer,
  basic,
  apiKey;

  String get displayName {
    switch (this) {
      case AuthType.none:
        return 'No Auth';
      case AuthType.bearer:
        return 'Bearer Token';
      case AuthType.basic:
        return 'Basic Auth';
      case AuthType.apiKey:
        return 'API Key';
    }
  }
}

/// Placement location for API Keys.
enum ApiKeyLocation {
  header,
  query;

  String get displayName {
    switch (this) {
      case ApiKeyLocation.header:
        return 'Header';
      case ApiKeyLocation.query:
        return 'Query Parameter';
    }
  }
}

/// Authentication configuration model.
@immutable
class AuthConfig {
  final AuthType type;
  // Bearer
  final String? token;
  final String? tokenSecretRefId;
  // Basic
  final String? username;
  final String? password;
  final String? passwordSecretRefId;
  // API Key
  final String? apiKeyName;
  final String? apiKeyValue;
  final String? apiKeySecretRefId;
  final ApiKeyLocation apiKeyLocation;

  const AuthConfig({
    this.type = AuthType.none,
    this.token,
    this.tokenSecretRefId,
    this.username,
    this.password,
    this.passwordSecretRefId,
    this.apiKeyName,
    this.apiKeyValue,
    this.apiKeySecretRefId,
    this.apiKeyLocation = ApiKeyLocation.header,
  });

  AuthConfig copyWith({
    AuthType? type,
    String? token,
    String? tokenSecretRefId,
    String? username,
    String? password,
    String? passwordSecretRefId,
    String? apiKeyName,
    String? apiKeyValue,
    String? apiKeySecretRefId,
    ApiKeyLocation? apiKeyLocation,
  }) {
    return AuthConfig(
      type: type ?? this.type,
      token: token ?? this.token,
      tokenSecretRefId: tokenSecretRefId ?? this.tokenSecretRefId,
      username: username ?? this.username,
      password: password ?? this.password,
      passwordSecretRefId: passwordSecretRefId ?? this.passwordSecretRefId,
      apiKeyName: apiKeyName ?? this.apiKeyName,
      apiKeyValue: apiKeyValue ?? this.apiKeyValue,
      apiKeySecretRefId: apiKeySecretRefId ?? this.apiKeySecretRefId,
      apiKeyLocation: apiKeyLocation ?? this.apiKeyLocation,
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'tokenSecretRefId': tokenSecretRefId,
    'username': username,
    'passwordSecretRefId': passwordSecretRefId,
    'apiKeyName': apiKeyName,
    'apiKeySecretRefId': apiKeySecretRefId,
    'apiKeyLocation': apiKeyLocation.name,
  };

  factory AuthConfig.fromJson(Map<String, dynamic> json) {
    return AuthConfig(
      type: AuthType.values.byName(json['type'] as String? ?? 'none'),
      tokenSecretRefId: json['tokenSecretRefId'] as String?,
      username: json['username'] as String?,
      passwordSecretRefId: json['passwordSecretRefId'] as String?,
      apiKeyName: json['apiKeyName'] as String?,
      apiKeySecretRefId: json['apiKeySecretRefId'] as String?,
      apiKeyLocation: ApiKeyLocation.values.byName(
        json['apiKeyLocation'] as String? ?? 'header',
      ),
    );
  }

  String encode() => jsonEncode(toJson());

  static AuthConfig decode(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const AuthConfig();
    try {
      return AuthConfig.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const AuthConfig();
    }
  }
}
