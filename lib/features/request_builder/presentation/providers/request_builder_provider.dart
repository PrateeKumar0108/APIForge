import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/networking/http_request_executor.dart';
import '../../../../core/networking/request_models.dart';
import '../../../../core/networking/url_validator.dart';
import '../../../authentication/domain/models/auth_config.dart';
import '../../../authentication/domain/services/auth_header_generator.dart';
import '../../../environments/domain/services/variable_substitution_engine.dart';
import '../../../history/domain/models/history_entry_entity.dart';
import '../../../history/domain/repositories/i_history_repository.dart';
import '../../../history/presentation/providers/history_provider.dart';
import '../../domain/request_state.dart';

/// Provider exposing the production HTTP executor.
final httpRequestExecutorProvider = Provider<IHttpRequestExecutor>((ref) {
  return HttpRequestExecutor();
});

/// Riverpod StateNotifierProvider driving the Request Builder UI.
final requestBuilderProvider =
    StateNotifierProvider<RequestBuilderNotifier, RequestState>((ref) {
      final executor = ref.watch(httpRequestExecutorProvider);
      final historyRepo = ref.watch(historyRepositoryProvider);
      final persistBody = ref.watch(historyPersistRequestBodyProvider);
      final maxRetention = ref.watch(historyRetentionLimitProvider);
      return RequestBuilderNotifier(
        executor,
        historyRepository: historyRepo,
        persistBody: persistBody,
        maxRetention: maxRetention,
      );
    });

class RequestBuilderNotifier extends StateNotifier<RequestState> {
  final IHttpRequestExecutor _executor;
  final IHistoryRepository? historyRepository;
  final bool persistBody;
  final int maxRetention;

  RequestBuilderNotifier(
    this._executor, {
    this.historyRepository,
    this.persistBody = false,
    this.maxRetention = 100,
  }) : super(RequestState.initial());

  void setMethod(String method) {
    var bodyType = state.bodyType;
    if (['POST', 'PUT', 'PATCH'].contains(method) &&
        bodyType == BodyType.none &&
        state.bodyContent.isEmpty) {
      bodyType = BodyType.json;
    }
    state = state.copyWith(method: method, bodyType: bodyType);
  }

  void setUrl(String url) {
    final validation = UrlValidator.validate(url);
    state = state.copyWith(
      url: url,
      urlValidationError: validation,
      clearValidationError: validation == null,
    );
  }

  void setQueryParams(List<KeyValuePair> params) {
    state = state.copyWith(queryParams: params);
  }

  void setHeaders(List<KeyValuePair> headers) {
    state = state.copyWith(headers: headers);
  }

  void setBodyType(BodyType bodyType) {
    state = state.copyWith(bodyType: bodyType);
  }

  void setBodyContent(String content) {
    state = state.copyWith(bodyContent: content);
  }

  void setFormData(List<KeyValuePair> formData) {
    state = state.copyWith(formData: formData);
  }

  void setAuthConfig(AuthConfig authConfig) {
    state = state.copyWith(authConfig: authConfig);
  }

  /// Formats raw JSON body with standard 2-space indentation.
  bool formatJsonBody() {
    if (state.bodyContent.trim().isEmpty) return true;
    try {
      final decoded = jsonDecode(state.bodyContent);
      final formatted = const JsonEncoder.withIndent('  ').convert(decoded);
      state = state.copyWith(bodyContent: formatted);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Executes the configured HTTP request asynchronously with variable substitution
  /// and auth header injection.
  Future<void> sendRequest({
    Map<String, String> requestVariables = const {},
    Map<String, String> environmentVariables = const {},
  }) async {
    // 1. Inject Auth Configuration
    var rawRequest = state.toRequestData();
    rawRequest = AuthHeaderGenerator.applyAuth(rawRequest, state.authConfig);

    // 2. Perform Variable Substitution
    final substitutionResult = VariableSubstitutionEngine.substituteRequest(
      request: rawRequest,
      requestVariables: requestVariables,
      environmentVariables: environmentVariables,
    );

    final executableRequest = substitutionResult.request;
    final unresolved = substitutionResult.unresolvedVariables;

    // 3. Validate URL
    final urlError = UrlValidator.validate(executableRequest.url);
    if (urlError != null) {
      state = state.copyWith(
        urlValidationError: urlError,
        failure: ValidationFailure(urlError),
        unresolvedVariables: unresolved,
      );
      return;
    }

    // Set up cancellation token
    final cancelToken = CancelToken();

    state = state.copyWith(
      isLoading: true,
      activeCancelToken: cancelToken,
      clearFailure: true,
      clearResponse: true,
      unresolvedVariables: unresolved,
    );

    final stopwatch = Stopwatch()..start();

    try {
      final response = await _executor.execute(
        executableRequest,
        cancelToken: cancelToken,
      );
      stopwatch.stop();

      state = state.copyWith(
        isLoading: false,
        clearCancelToken: true,
        response: response,
        clearFailure: true,
      );

      // Auto-log completed response to SQLite history
      final repo = historyRepository;
      if (repo != null) {
        try {
          await repo.logEntry(
            HistoryEntryEntity(
              id: const Uuid().v4(),
              method: executableRequest.method,
              url: executableRequest.url,
              statusCode: response.statusCode,
              statusMessage: response.statusMessage,
              durationMs: response.durationMs,
              contentLengthBytes: response.contentLengthBytes,
              requestHeaders: executableRequest.headers,
              responseHeaders: response.headers,
              bodyContent: executableRequest.bodyContent,
              executedAt: DateTime.now(),
            ),
            persistBody: persistBody,
            maxRetention: maxRetention,
          );
        } catch (_) {}
      }
    } on AppFailure catch (failure) {
      stopwatch.stop();
      state = state.copyWith(
        isLoading: false,
        clearCancelToken: true,
        failure: failure,
      );

      final repo = historyRepository;
      if (repo != null && failure is! CancelledFailure) {
        try {
          await repo.logEntry(
            HistoryEntryEntity(
              id: const Uuid().v4(),
              method: executableRequest.method,
              url: executableRequest.url,
              statusCode: 0,
              statusMessage: failure.message,
              durationMs: stopwatch.elapsedMilliseconds,
              contentLengthBytes: 0,
              requestHeaders: executableRequest.headers,
              responseHeaders: const {},
              bodyContent: executableRequest.bodyContent,
              executedAt: DateTime.now(),
            ),
            persistBody: persistBody,
            maxRetention: maxRetention,
          );
        } catch (_) {}
      }
    } catch (e) {
      stopwatch.stop();
      state = state.copyWith(
        isLoading: false,
        clearCancelToken: true,
        failure: UnexpectedFailure(e.toString()),
      );
    }
  }

  /// Cancels any ongoing HTTP request execution.
  void cancelRequest() {
    if (state.isLoading && state.activeCancelToken != null) {
      state.activeCancelToken!.cancel('User cancelled request.');
      state = state.copyWith(
        isLoading: false,
        clearCancelToken: true,
        failure: const CancelledFailure(),
      );
    }
  }

  /// Populates the builder with an existing request configuration.
  void loadRequest(HttpRequestData data) {
    state = state.copyWith(
      id: data.id,
      name: data.name,
      method: data.method,
      url: data.url,
      queryParams: data.queryParams,
      headers: data.headers,
      bodyType: data.bodyType,
      bodyContent: data.bodyContent,
      formData: data.formData,
      timeoutSeconds: data.timeoutSeconds,
      clearResponse: true,
      clearFailure: true,
    );
  }
}
