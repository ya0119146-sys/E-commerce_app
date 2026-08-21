import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/app_dimensions.dart';

/// Glassmorphism panel — frosted glass container per the Labella design system.
class GlassPanel extends StatelessWidget {
  final Widget child;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final double blurSigma;
  final Color? backgroundColor;
  final Color? borderColor;

  const GlassPanel({
    super.key,
    required this.child,
    this.borderRadius,
    this.padding,
    this.blurSigma = 10.0,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = backgroundColor ??
        (isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.55));
    final border = borderColor ??
        (isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.3));

    return ClipRRect(
      borderRadius: BorderRadius.circular(
        borderRadius ?? AppDimensions.radiusDefault,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding ?? const EdgeInsets.all(AppDimensions.spacingDefault),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(
              borderRadius ?? AppDimensions.radiusDefault,
            ),
            border: Border.all(color: border),
          ),
          child: child,
        ),
      ),
    );
  }
}
