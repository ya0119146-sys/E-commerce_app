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
    final double availableWidth = width - horizontalPadding - ((crossAxisCount - 1) * spacing);
    final double itemWidth = (availableWidth / crossAxisCount).clamp(60.0, 500.0);
    // 1:1 square image + 146px content area (padding, title, rating, price, button)
    final double itemHeight = itemWidth + 146.0;
    final double aspectRatio = (itemWidth / itemHeight).clamp(0.48, 0.65);

    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: spacing,
      mainAxisSpacing: spacing,
      childAspectRatio: aspectRatio,
    );
  }
}

