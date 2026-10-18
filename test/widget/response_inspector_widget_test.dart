import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apiforge/core/errors/app_failure.dart';
import 'package:apiforge/core/networking/request_models.dart';
import 'package:apiforge/core/theme/app_theme.dart';
import 'package:apiforge/features/response_inspector/presentation/widgets/response_inspector_widget.dart';

void main() {
  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(body: child),
    );
  }

  group('ResponseInspectorWidget', () {
    testWidgets('renders empty state when no response or error is present', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(const ResponseInspectorWidget()),
      );

      expect(find.text('No Response Yet'), findsOneWidget);
      expect(find.byIcon(Icons.alt_route_rounded), findsOneWidget);
    });

    testWidgets('renders loading state when isLoading is true', (tester) async {
      var cancelled = false;

      await tester.pumpWidget(
        buildTestableWidget(
          ResponseInspectorWidget(
            isLoading: true,
            onCancel: () => cancelled = true,
          ),
        ),
      );

      expect(find.text('Sending Request...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.tap(find.text('Cancel Request'));
      expect(cancelled, isTrue);
    });

    testWidgets('renders failure state with retry option on NetworkFailure', (
      tester,
    ) async {
      var retried = false;

      await tester.pumpWidget(
        buildTestableWidget(
          ResponseInspectorWidget(
            failure: const NetworkFailure('Failed to connect to host.'),
            onRetry: () => retried = true,
          ),
        ),
      );

      expect(find.text('Failed to connect to host.'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
      expect(find.text('Retry Request'), findsOneWidget);

      await tester.tap(find.text('Retry Request'));
      expect(retried, isTrue);
    });

    testWidgets('renders response metadata and inspects tabs on 200 OK', (
      tester,
    ) async {
      final response = HttpResponseData(
        statusCode: 200,
        statusMessage: 'OK',
        headers: {
          'content-type': ['application/json'],
          'set-cookie': ['session_id=secret123; HttpOnly'],
        },
        body: '{"message":"hello world","items":[1,2,3]}',
        durationMs: 145,
        contentLengthBytes: 42,
        contentType: 'application/json',
        timestamp: DateTime(2026, 10, 18, 15, 0),
      );

      await tester.pumpWidget(
        buildTestableWidget(ResponseInspectorWidget(response: response)),
      );

      // Verify header summary strip
      expect(find.text('200 OK'), findsOneWidget);
      expect(find.text('145 ms'), findsOneWidget);
      expect(find.text('42 B'), findsOneWidget);

      // Verify Pretty JSON tab has rendered content
      expect(find.text('Pretty'), findsOneWidget);
      expect(find.text('JSON'), findsOneWidget);

      // Tap Headers tab
      await tester.tap(find.text('Headers'));
      await tester.pumpAndSettle();

      expect(find.text('content-type'), findsOneWidget);
      expect(find.text('set-cookie'), findsOneWidget);
      // Redacted by default
      expect(find.text('[REDACTED]'), findsOneWidget);

      // Tap Reveal Secrets
      await tester.tap(find.text('Reveal Secrets'));
      await tester.pumpAndSettle();

      expect(find.text('session_id=secret123; HttpOnly'), findsOneWidget);
    });
  });
}
