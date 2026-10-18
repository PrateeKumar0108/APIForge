import 'dart:convert';
import 'package:flutter/material.dart';

/// Formatter and syntax highlighter that transforms raw JSON into rich [TextSpan] elements.
class JsonSyntaxHighlighter {
  final bool isDark;

  const JsonSyntaxHighlighter({this.isDark = true});

  // Theme-aware token color palette
  Color get keyColor =>
      isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7); // Cyan / Blue
  Color get stringColor =>
      isDark ? const Color(0xFF34D399) : const Color(0xFF059669); // Emerald
  Color get numberColor =>
      isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706); // Amber
  Color get boolColor =>
      isDark ? const Color(0xFFA78BFA) : const Color(0xFF7C3AED); // Violet
  Color get nullColor =>
      isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B); // Slate
  Color get symbolColor =>
      isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155); // Structure

  /// Parses JSON string and builds syntax-colored [TextSpan].
  TextSpan highlight(String rawJson) {
    if (rawJson.trim().isEmpty) {
      return const TextSpan(text: '');
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(rawJson);
    } catch (_) {
      // Fallback for non-JSON text
      return TextSpan(
        text: rawJson,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
          color: symbolColor,
        ),
      );
    }

    final spans = <TextSpan>[];
    _formatNode(decoded, spans, 0);
    return TextSpan(children: spans);
  }

  void _formatNode(dynamic node, List<TextSpan> spans, int indentLevel) {
    final indent = '  ' * indentLevel;

    if (node is Map) {
      if (node.isEmpty) {
        spans.add(
          TextSpan(
            text: '{}',
            style: TextStyle(color: symbolColor),
          ),
        );
        return;
      }

      spans.add(
        TextSpan(
          text: '{\n',
          style: TextStyle(color: symbolColor),
        ),
      );
      final entries = node.entries.toList();

      for (var i = 0; i < entries.length; i++) {
        final entry = entries[i];
        final isLast = i == entries.length - 1;

        spans.add(TextSpan(text: '$indent  '));
        // JSON Key
        spans.add(
          TextSpan(
            text: '"${entry.key}"',
            style: TextStyle(
              color: keyColor,
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace',
            ),
          ),
        );
        spans.add(
          TextSpan(
            text: ': ',
            style: TextStyle(color: symbolColor),
          ),
        );

        // Value
        _formatNode(entry.value, spans, indentLevel + 1);

        if (!isLast) {
          spans.add(
            TextSpan(
              text: ',',
              style: TextStyle(color: symbolColor),
            ),
          );
        }
        spans.add(const TextSpan(text: '\n'));
      }

      spans.add(
        TextSpan(
          text: '$indent}',
          style: TextStyle(color: symbolColor),
        ),
      );
    } else if (node is List) {
      if (node.isEmpty) {
        spans.add(
          TextSpan(
            text: '[]',
            style: TextStyle(color: symbolColor),
          ),
        );
        return;
      }

      spans.add(
        TextSpan(
          text: '[\n',
          style: TextStyle(color: symbolColor),
        ),
      );
      for (var i = 0; i < node.length; i++) {
        final item = node[i];
        final isLast = i == node.length - 1;

        spans.add(TextSpan(text: '$indent  '));
        _formatNode(item, spans, indentLevel + 1);

        if (!isLast) {
          spans.add(
            TextSpan(
              text: ',',
              style: TextStyle(color: symbolColor),
            ),
          );
        }
        spans.add(const TextSpan(text: '\n'));
      }

      spans.add(
        TextSpan(
          text: '$indent]',
          style: TextStyle(color: symbolColor),
        ),
      );
    } else if (node is String) {
      final escaped = node.replaceAll(r'\', r'\\').replaceAll('"', r'\"');
      spans.add(
        TextSpan(
          text: '"$escaped"',
          style: TextStyle(color: stringColor, fontFamily: 'monospace'),
        ),
      );
    } else if (node is num) {
      spans.add(
        TextSpan(
          text: node.toString(),
          style: TextStyle(
            color: numberColor,
            fontFamily: 'monospace',
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    } else if (node is bool) {
      spans.add(
        TextSpan(
          text: node.toString(),
          style: TextStyle(
            color: boolColor,
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else if (node == null) {
      spans.add(
        TextSpan(
          text: 'null',
          style: TextStyle(
            color: nullColor,
            fontStyle: FontStyle.italic,
            fontFamily: 'monospace',
          ),
        ),
      );
    } else {
      spans.add(
        TextSpan(
          text: node.toString(),
          style: TextStyle(color: symbolColor, fontFamily: 'monospace'),
        ),
      );
    }
  }
}
