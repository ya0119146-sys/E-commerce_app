import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Star rating display widget using the Accent (Gold) color.
class StarRating extends StatelessWidget {
  final double rating;
  final int maxStars;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;

  const StarRating({
    super.key,
    required this.rating,
    this.maxStars = 5,
    this.size = 16,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final active = activeColor ?? AppColors.accent(brightness);
    final inactive = inactiveColor ??
        AppColors.foreground(brightness).withValues(alpha: 0.2);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxStars, (index) {
        final starValue = index + 1;
        IconData icon;
        Color color;

        if (rating >= starValue) {
          icon = Icons.star_rounded;
          color = active;
        } else if (rating >= starValue - 0.5) {
          icon = Icons.star_half_rounded;
          color = active;
        } else {
          icon = Icons.star_border_rounded;
          color = inactive;
        }

        return Icon(icon, size: size, color: color);
      }),
    );
  }
}
