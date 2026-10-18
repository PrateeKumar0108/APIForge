import 'package:flutter/material.dart';

/// AppColors defines the central design palette for APIForge.
///
/// Implements a developer-centric, high-contrast dark and light palette
/// with standardized HTTP method and status code semantic coloring.
abstract final class AppColors {
  // Brand identity colors
  static const Color primaryBlue = Color(0xFF2563EB); // Royal Blue
  static const Color primaryBlueLight = Color(0xFF3B82F6);
  static const Color primaryBlueDark = Color(0xFF1D4ED8);

  static const Color cyanAccent = Color(0xFF06B6D4);
  static const Color amberAccent = Color(0xFFF59E0B);

  // Dark theme surfaces (Sleek Slate Navy)
  static const Color darkBackground = Color(0xFF0A0F1D);
  static const Color darkSurface = Color(0xFF111827);
  static const Color darkSurfaceElevated = Color(0xFF1F2937);
  static const Color darkSurfaceBorder = Color(0xFF374151);
  static const Color darkTextPrimary = Color(0xFFF9FAFB);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
  static const Color darkTextMuted = Color(0xFF6B7280);

  // Light theme surfaces
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFF1F5F9);
  static const Color lightSurfaceBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF94A3B8);

  // HTTP Method Colors
  static const Color methodGet = Color(0xFF10B981); // Emerald
  static const Color methodPost = Color(0xFF3B82F6); // Blue
  static const Color methodPut = Color(0xFFF59E0B); // Amber
  static const Color methodPatch = Color(0xFF8B5CF6); // Purple
  static const Color methodDelete = Color(0xFFEF4444); // Crimson Red
  static const Color methodHead = Color(0xFF64748B); // Slate
  static const Color methodOptions = Color(0xFF06B6D4); // Cyan

  // HTTP Status Code Colors
  static const Color statusSuccess = Color(0xFF10B981); // 2xx
  static const Color statusRedirect = Color(0xFF3B82F6); // 3xx
  static const Color statusClientError = Color(0xFFF59E0B); // 4xx
  static const Color statusServerError = Color(0xFFEF4444); // 5xx
  static const Color statusUnknown = Color(0xFF6B7280);

  /// Resolves the semantic color for a given HTTP method string.
  static Color forMethod(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return methodGet;
      case 'POST':
        return methodPost;
      case 'PUT':
        return methodPut;
      case 'PATCH':
        return methodPatch;
      case 'DELETE':
        return methodDelete;
      case 'HEAD':
        return methodHead;
      case 'OPTIONS':
        return methodOptions;
      default:
        return primaryBlue;
    }
  }

  /// Resolves the semantic color for an HTTP status code.
  static Color forStatusCode(int? code) {
    if (code == null) return statusUnknown;
    if (code >= 200 && code < 300) return statusSuccess;
    if (code >= 300 && code < 400) return statusRedirect;
    if (code >= 400 && code < 500) return statusClientError;
    if (code >= 500) return statusServerError;
    return statusUnknown;
  }
}
