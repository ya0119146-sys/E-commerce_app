import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Labella Design System — Gradient definitions.
class AppGradients {
  AppGradients._();

  /// Hero gradient — used on hero banners / onboarding.
  static LinearGradient hero(Brightness brightness) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.muted(brightness),
      AppColors.background(brightness),
      AppColors.primary(brightness).withValues(alpha: 0.45),
    ],
  );

  /// Plum gradient — used on primary CTA buttons.
  static LinearGradient plum(Brightness brightness) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.secondary(brightness), AppColors.primary(brightness)],
  );

  /// Shimmer gradient for skeleton loading.
  static const LinearGradient shimmer = LinearGradient(
    colors: [Color(0xFFEBE5DE), Color(0xFFF5EBE0), Color(0xFFEBE5DE)],
  );
}
