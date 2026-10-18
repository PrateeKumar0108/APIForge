import 'package:flutter/foundation.dart';

/// Sealed hierarchy of typed application failures.
/// Distinguishes network disconnects, timeouts, TLS errors,
/// cancellations, and validation issues without leaking sensitive stack traces.
@immutable
sealed class AppFailure implements Exception {
  final String message;
  final String? technicalDetails;

  const AppFailure(this.message, [this.technicalDetails]);

  @override
  String toString() =>
      technicalDetails == null ? message : '$message ($technicalDetails)';
}

/// Triggered when host lookup fails, connection is refused, or device is offline.
final class NetworkFailure extends AppFailure {
  const NetworkFailure([
    super.message =
        'Unable to reach the destination host. Please check network connectivity.',
    super.technicalDetails,
  ]);
}

/// Triggered when TCP connection, handshake, or data reception times out.
final class TimeoutFailure extends AppFailure {
  const TimeoutFailure([
    super.message =
        'The request timed out before receiving a response from the server.',
    super.technicalDetails,
  ]);
}

/// Triggered when TLS certificate validation fails or handshake cannot negotiate cipher.
final class TlsFailure extends AppFailure {
  const TlsFailure([
    super.message =
        'TLS/SSL certificate validation failed. The connection may not be secure.',
    super.technicalDetails,
  ]);
}

/// Triggered when an in-flight HTTP request is explicitly cancelled by the user.
final class CancelledFailure extends AppFailure {
  const CancelledFailure([
    super.message = 'Request cancelled by user.',
    super.technicalDetails,
  ]);
}

/// Triggered when an input URL or body payload violates protocol validation rules.
final class ValidationFailure extends AppFailure {
  const ValidationFailure(super.message, [super.technicalDetails]);
}

/// Triggered when parsing JSON or binary response payloads fails.
final class ParseFailure extends AppFailure {
  const ParseFailure([
    super.message = 'Failed to parse response payload.',
    super.technicalDetails,
  ]);
}

/// Generic fallback failure for unexpected exceptions.
final class UnexpectedFailure extends AppFailure {
  const UnexpectedFailure([
    super.message = 'An unexpected error occurred during request processing.',
    super.technicalDetails,
  ]);
}
