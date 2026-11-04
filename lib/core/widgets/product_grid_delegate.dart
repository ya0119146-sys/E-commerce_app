import 'package:flutter/material.dart';
import '../constants/app_dimensions.dart';

/// Rock-solid, responsive SliverGridDelegate for product catalog grids.
///
/// Automatically adapts across all viewports (mini-window, phones, foldables, tablets)
/// without third-party layout estimation bugs or assertions.
class ProductGridDelegate {
  ProductGridDelegate._();

  static SliverGridDelegate create(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    // 1 column for ultra-compact mini-windows (< 280), 3 for tablets/foldables (>= 600), 2 for standard phones
    final int crossAxisCount = width < 280 ? 1 : (width >= 600 ? 3 : 2);
    const double spacing = 14.0;
    const double horizontalPadding = AppDimensions.screenPadding * 2;
    final double availableWidth =
        width - horizontalPadding - ((crossAxisCount - 1) * spacing);
    final double itemWidth = (availableWidth / crossAxisCount).clamp(
      60.0,
      500.0,
    );
    final textScale = MediaQuery.textScalerOf(
      context,
    ).scale(1.0).clamp(1.0, 1.3);
    // 1:1 square image + compact content area (padding, title 2-lines, rating/badge, price, tight 6px gap, button)
    final double contentHeight = 120.0 * textScale;
    final double itemHeight = itemWidth + contentHeight;
    final double aspectRatio = (itemWidth / itemHeight).clamp(0.48, 0.70);

    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: spacing,
      mainAxisSpacing: spacing,
      childAspectRatio: aspectRatio,
    );
  }
}
