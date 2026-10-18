import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

/// Single variable entry within an environment.
@immutable
class EnvironmentVariableEntity {
  final String id;
  final String key;
  final String value;
  final bool isSecret;
  final String? secretRefId;
  final bool isEnabled;

  EnvironmentVariableEntity({
    String? id,
    required this.key,
    required this.value,
    this.isSecret = false,
    this.secretRefId,
    this.isEnabled = true,
  }) : id = id ?? const Uuid().v4();

  EnvironmentVariableEntity copyWith({
    String? key,
    String? value,
    bool? isSecret,
    String? secretRefId,
    bool? isEnabled,
  }) {
    return EnvironmentVariableEntity(
      id: id,
      key: key ?? this.key,
      value: value ?? this.value,
      isSecret: isSecret ?? this.isSecret,
      secretRefId: secretRefId ?? this.secretRefId,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'key': key,
    'value': isSecret ? '' : value,
    'isSecret': isSecret,
    'secretRefId': secretRefId,
    'isEnabled': isEnabled,
  };

  factory EnvironmentVariableEntity.fromJson(Map<String, dynamic> json) {
    return EnvironmentVariableEntity(
      id: json['id'] as String?,
      key: json['key'] as String? ?? '',
      value: json['value'] as String? ?? '',
      isSecret: json['isSecret'] as bool? ?? false,
      secretRefId: json['secretRefId'] as String?,
      isEnabled: json['isEnabled'] as bool? ?? true,
    );
  }
}

/// Domain representation of an environment (e.g. Local, Development, Staging, Production).
@immutable
class EnvironmentEntity {
  final String id;
  final String workspaceId;
  final String name;
  final String colorHex;
  final bool isDefault;
  final List<EnvironmentVariableEntity> variables;
  final DateTime createdAt;
  final DateTime updatedAt;

  const EnvironmentEntity({
    required this.id,
    required this.workspaceId,
    required this.name,
    this.colorHex = '0xFF10B981',
    this.isDefault = false,
    this.variables = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  /// Map of enabled key-value pairs ready for interpolation.
  Map<String, String> get variableMap {
    final map = <String, String>{};
    for (final v in variables) {
      if (v.isEnabled && v.key.trim().isNotEmpty) {
        map[v.key.trim()] = v.value;
      }
    }
    return map;
  }

  EnvironmentEntity copyWith({
    String? name,
    String? colorHex,
    bool? isDefault,
    List<EnvironmentVariableEntity>? variables,
    DateTime? updatedAt,
  }) {
    return EnvironmentEntity(
      id: id,
      workspaceId: workspaceId,
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
      isDefault: isDefault ?? this.isDefault,
      variables: variables ?? this.variables,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
