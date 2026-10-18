import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apiforge/app/app.dart';

void main() {
  testWidgets('APIForge smoke test - renders navigation and builder', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: ApiForgeApp()));

    // Initial frame pump
    await tester.pumpAndSettle();

    // Verify presence of navigation items
    expect(find.text('Builder'), findsOneWidget);
    expect(find.text('Collections'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Environments'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    // Verify Request Builder elements
    expect(find.text('Send'), findsOneWidget);
    expect(find.text('Params'), findsOneWidget);
    expect(find.text('Headers'), findsOneWidget);
    expect(find.text('Auth'), findsOneWidget);
    expect(find.text('Body'), findsOneWidget);
  });
}
