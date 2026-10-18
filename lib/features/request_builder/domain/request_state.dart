import 'package:dio/dio.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/networking/request_models.dart';
import '../../authentication/domain/models/auth_config.dart';

/// State representation of the interactive Request Builder workspace.
class RequestState {
  final String id;
  final String name;
  final String method;
  final String url;
  final List<KeyValuePair> queryParams;
  final List<KeyValuePair> headers;
  final BodyType bodyType;
  final String bodyContent;
  final List<KeyValuePair> formData;
  final AuthConfig authConfig;
  final int timeoutSeconds;
  final bool isLoading;
  final CancelToken? activeCancelToken;
  final HttpResponseData? response;
  final AppFailure? failure;
  final String? urlValidationError;
  final List<String> unresolvedVariables;

  const RequestState({
    required this.id,
    this.name = 'Untracked Request',
    this.method = 'GET',
    this.url = 'https://httpbin.org/get',
    this.queryParams = const [],
    this.headers = const [],
    this.bodyType = BodyType.none,
    this.bodyContent = '',
    this.formData = const [],
    this.authConfig = const AuthConfig(),
    this.timeoutSeconds = 30,
    this.isLoading = false,
    this.activeCancelToken,
    this.response,
    this.failure,
    this.urlValidationError,
    this.unresolvedVariables = const [],
  });

  /// Factory for standard default initial state.
  factory RequestState.initial() {
    return RequestState(
      id: 'initial',
      headers: [
        KeyValuePair(key: 'Accept', value: '*/*'),
        KeyValuePair(key: 'User-Agent', value: 'APIForge/1.0.0'),
      ],
    );
  }

  /// Converts this state into an executable [HttpRequestData].
  HttpRequestData toRequestData() {
    return HttpRequestData(
      id: id,
      name: name,
      method: method,
      url: url,
      queryParams: queryParams,
      headers: headers,
      bodyType: bodyType,
      bodyContent: bodyContent,
      formData: formData,
      timeoutSeconds: timeoutSeconds,
    );
  }

  RequestState copyWith({
    String? id,
    String? name,
    String? method,
    String? url,
    List<KeyValuePair>? queryParams,
    List<KeyValuePair>? headers,
    BodyType? bodyType,
    String? bodyContent,
    List<KeyValuePair>? formData,
    AuthConfig? authConfig,
    int? timeoutSeconds,
    bool? isLoading,
    CancelToken? activeCancelToken,
    bool clearCancelToken = false,
    HttpResponseData? response,
    bool clearResponse = false,
    AppFailure? failure,
    bool clearFailure = false,
    String? urlValidationError,
    bool clearValidationError = false,
    List<String>? unresolvedVariables,
  }) {
    return RequestState(
      id: id ?? this.id,
      name: name ?? this.name,
      method: method ?? this.method,
      url: url ?? this.url,
      queryParams: queryParams ?? this.queryParams,
      headers: headers ?? this.headers,
      bodyType: bodyType ?? this.bodyType,
      bodyContent: bodyContent ?? this.bodyContent,
      formData: formData ?? this.formData,
      authConfig: authConfig ?? this.authConfig,
      timeoutSeconds: timeoutSeconds ?? this.timeoutSeconds,
      isLoading: isLoading ?? this.isLoading,
      activeCancelToken: clearCancelToken
          ? null
          : (activeCancelToken ?? this.activeCancelToken),
      response: clearResponse ? null : (response ?? this.response),
      failure: clearFailure ? null : (failure ?? this.failure),
      urlValidationError: clearValidationError
          ? null
          : (urlValidationError ?? this.urlValidationError),
      unresolvedVariables: unresolvedVariables ?? this.unresolvedVariables,
    );
  }
}
