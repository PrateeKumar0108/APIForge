import '../models/environment_entity.dart';

/// Contract for persisting and managing environments and their {{variables}}.
abstract interface class IEnvironmentsRepository {
  Stream<List<EnvironmentEntity>> watchEnvironments({
    String workspaceId = 'default-workspace',
  });
  Future<List<EnvironmentEntity>> getEnvironments({
    String workspaceId = 'default-workspace',
  });
  Future<EnvironmentEntity> createEnvironment({
    required String name,
    String colorHex = '0xFF10B981',
    String workspaceId = 'default-workspace',
    List<EnvironmentVariableEntity> variables = const [],
  });
  Future<void> updateEnvironment(EnvironmentEntity environment);
  Future<void> deleteEnvironment(String environmentId);
  Future<void> saveVariable(
    String environmentId,
    EnvironmentVariableEntity variable,
  );
  Future<void> deleteVariable(String variableId);
  Future<void> seedDefaultEnvironments({
    String workspaceId = 'default-workspace',
  });
}
