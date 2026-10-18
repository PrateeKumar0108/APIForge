import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apiforge/app/app.dart';
import 'package:apiforge/core/networking/http_request_executor.dart';
import 'package:apiforge/core/networking/request_models.dart';
import 'package:apiforge/core/storage/database/app_database.dart';
import 'package:apiforge/features/collections/presentation/providers/collections_provider.dart';
import 'package:apiforge/features/request_builder/presentation/providers/request_builder_provider.dart';

class MockE2eExecutor implements IHttpRequestExecutor {
  @override
  Future<HttpResponseData> execute(
    HttpRequestData request, {
    CancelToken? cancelToken,
  }) async {
    return HttpResponseData(
      statusCode: 200,
      statusMessage: 'OK',
      durationMs: 45,
      contentLengthBytes: 38,
      headers: {
        'content-type': ['application/json; charset=utf-8'],
        'x-request-id': ['req-e2e-12345'],
      },
      body: '{"status": "success", "count": 3}',
      timestamp: DateTime.now(),
    );
  }
}

void main() {
  testWidgets(
    'E2E Request Flow: Build request -> Send -> Inspect -> Save -> Audit in History -> Replay',
    (tester) async {
      // Set larger viewport to avoid overflow in tests
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final db = AppDatabase(NativeDatabase.memory());
      final executor = MockE2eExecutor();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            httpRequestExecutorProvider.overrideWithValue(executor),
          ],
          child: const ApiForgeApp(),
        ),
      );

      await tester.pumpAndSettle();

      // 1. Enter URL in Request Builder
      final urlField = find.byType(TextField).first;
      await tester.enterText(urlField, 'https://api.example.com/items');
      await tester.pumpAndSettle();

      // 2. Tap Send Request
      final sendButton = find.text('Send');
      expect(sendButton, findsOneWidget);
      await tester.tap(sendButton);
      await tester.pumpAndSettle();

      // 3. Verify Response status is displayed
      expect(find.text('200 OK'), findsAtLeastNWidgets(1));

      // 4. Switch to History Tab via bottom navigation
      final historyNav = find.text('History');
      expect(historyNav, findsOneWidget);
      await tester.tap(historyNav);
      await tester.pumpAndSettle();

      // 5. Verify Request was automatically logged into SQLite History
      expect(find.text('Request History'), findsOneWidget);
      expect(find.text('https://api.example.com/items'), findsOneWidget);
      expect(find.text('200 OK'), findsAtLeastNWidgets(1));

      // 6. Tap Replay button on the history card
      final replayButton = find.byTooltip('Replay in Builder').first;
      await tester.tap(replayButton);
      await tester.pumpAndSettle();

      // 7. Verify we are navigated back to Builder with replayed request loaded
      expect(find.text('Send'), findsOneWidget);
      expect(find.text('https://api.example.com/items'), findsOneWidget);

      await db.close();
    },
  );
}
