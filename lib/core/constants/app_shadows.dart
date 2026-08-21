import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Labella Design System — Box shadow presets.
class AppShadows {
  AppShadows._();

  /// Warm shadow — cards, elevated elements.
  static List<BoxShadow> warm(Brightness brightness) => [
    BoxShadow(
      color: AppColors.secondary(brightness).withValues(alpha: 0.38),
      blurRadius: 55,
      offset: const Offset(0, 18),
    ),
  ];

  /// Glow shadow — floating action elements, hero buttons.
  static List<BoxShadow> glow(Brightness brightness) => [
    BoxShadow(
      color: AppColors.primary(brightness).withValues(alpha: 0.72),
      blurRadius: 48,
      offset: const Offset(0, 16),
    ),
  ];

  /// Subtle shadow — cards at rest.
  static List<BoxShadow> subtle(Brightness brightness) => [
    BoxShadow(
      color: AppColors.secondary(brightness).withValues(alpha: 0.08),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
}
