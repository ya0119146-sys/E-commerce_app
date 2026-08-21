import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

/// Shimmer skeleton loading widget for premium loading states.
class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final double? borderRadius;

  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.darkMuted : const Color(0xFFEBE5DE),
      highlightColor:
          isDark ? AppColors.darkCard : const Color(0xFFF5EBE0),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            borderRadius ?? AppDimensions.radiusMd,
          ),
        ),
      ),
    );
  }
}

/// A shimmer product card placeholder.
class ShimmerProductCard extends StatelessWidget {
  const ShimmerProductCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShimmerLoading(
          width: double.infinity,
          height: 200,
          borderRadius: AppDimensions.radiusDefault,
        ),
        const SizedBox(height: 8),
        const ShimmerLoading(width: 120, height: 14),
        const SizedBox(height: 6),
        const ShimmerLoading(width: 80, height: 12),
        const SizedBox(height: 6),
        const ShimmerLoading(width: 60, height: 16),
      ],
    );
  }
}
