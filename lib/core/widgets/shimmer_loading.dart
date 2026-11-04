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
      highlightColor: isDark ? AppColors.darkCard : const Color(0xFFF5EBE0),
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
    final brightness = Theme.of(context).brightness;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card(brightness),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border(brightness).withValues(alpha: 0.5),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const AspectRatio(
            aspectRatio: 1.0,
            child: ShimmerLoading(
              width: double.infinity,
              height: double.infinity,
              borderRadius: 15,
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ShimmerLoading(width: 110, height: 13),
                SizedBox(height: 6),
                ShimmerLoading(width: 55, height: 11),
                SizedBox(height: 6),
                ShimmerLoading(width: 70, height: 15),
                SizedBox(height: 8),
                ShimmerLoading(
                  width: double.infinity,
                  height: 26,
                  borderRadius: 8,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
