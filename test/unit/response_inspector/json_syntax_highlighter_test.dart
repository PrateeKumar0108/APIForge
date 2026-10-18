import 'package:flutter_test/flutter_test.dart';
import 'package:apiforge/features/response_inspector/presentation/widgets/json_syntax_highlighter.dart';

void main() {
  group('JsonSyntaxHighlighter', () {
    test('handles empty or blank JSON gracefully', () {
      const highlighter = JsonSyntaxHighlighter();
      final span = highlighter.highlight('');
      expect(span.text, equals(''));
      expect(span.children, isNull);
    });

    test('highlights valid JSON with syntax tokens', () {
      const highlighter = JsonSyntaxHighlighter(isDark: true);
      const jsonStr =
          '{"status":"success","count":42,"active":true,"data":null}';

      final span = highlighter.highlight(jsonStr);

      expect(span.children, isNotNull);
      expect(span.children!.isNotEmpty, isTrue);

      // Verify that children contain key names and values
      final allText = span.toPlainText();
      expect(allText, contains('"status"'));
      expect(allText, contains('"success"'));
      expect(allText, contains('42'));
      expect(allText, contains('true'));
      expect(allText, contains('null'));
    });

    test('falls back gracefully to plain text for non-JSON content', () {
      const highlighter = JsonSyntaxHighlighter();
      const htmlStr = '<!DOCTYPE html><html><body>Error</body></html>';

      final span = highlighter.highlight(htmlStr);

      expect(span.text, equals(htmlStr));
      expect(span.children, isNull);
    });

    test('supports light mode with darker contrast colors', () {
      const lightHighlighter = JsonSyntaxHighlighter(isDark: false);
      const darkHighlighter = JsonSyntaxHighlighter(isDark: true);

      expect(
        lightHighlighter.keyColor,
        isNot(equals(darkHighlighter.keyColor)),
      );
      expect(
        lightHighlighter.stringColor,
        isNot(equals(darkHighlighter.stringColor)),
      );
      expect(
        lightHighlighter.numberColor,
        isNot(equals(darkHighlighter.numberColor)),
      );
    });
  });
}
