import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Reusable badge displaying an HTTP method with standardized semantic colors.
class MethodBadge extends StatelessWidget {
  final String method;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const MethodBadge({
    super.key,
    required this.method,
    this.fontSize = 11,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
  });

  @override
  Widget build(BuildContext context) {
    final methodUpper = method.toUpperCase();
    final color = AppColors.forMethod(methodUpper);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Text(
        methodUpper,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}
