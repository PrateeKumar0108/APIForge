import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Reusable badge displaying an HTTP status code (e.g. "200 OK", "404 Not Found")
/// with semantic color coding and optional status text.
class StatusCodeBadge extends StatelessWidget {
  final int statusCode;
  final String? statusMessage;

  const StatusCodeBadge({
    super.key,
    required this.statusCode,
    this.statusMessage,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.forStatusCode(statusCode);
    final label = statusMessage != null && statusMessage!.isNotEmpty
        ? '$statusCode $statusMessage'
        : '$statusCode';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
