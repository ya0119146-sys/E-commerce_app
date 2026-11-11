import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/widgets/glass_panel.dart';
import '../../../../core/widgets/star_rating.dart';
import '../../data/models/review_model.dart';

/// Header row displaying review section title, count label, and Add Review action.
class ReviewHeader extends StatelessWidget {
  final String? countLabel;
  final bool isAdmin;
  final VoidCallback onAddReview;

  const ReviewHeader({
    super.key,
    required this.countLabel,
    required this.isAdmin,
    required this.onAddReview,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Customer Reviews'.tr(context),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        if (countLabel != null) ...[
          const SizedBox(height: 2),
          Text(
            countLabel!,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontSize: 12),
          ),
        ],
      ],
    );

    if (isAdmin) return title;

    final addButton = TextButton.icon(
      onPressed: onAddReview,
      icon: const Icon(Icons.add_rounded, size: 16),
      label: Text(
        'Add Review'.tr(context),
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.secondary(brightness),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: title),
        const SizedBox(width: 8),
        addButton,
      ],
    );
  }
}

/// Individual glassmorphic review card displaying author, rating, comment, and optional admin delete button.
class ReviewCard extends StatelessWidget {
  final ReviewModel review;
  final bool isAdmin;
  final VoidCallback onDelete;

  const ReviewCard({
    super.key,
    required this.review,
    required this.isAdmin,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final reviewerName = review.name.trim().isEmpty
        ? 'Customer'.tr(context)
        : review.name.trim();
    final formattedDate = review.createdAt == null
        ? null
        : DateFormat.yMMMd().format(review.createdAt!);

    return GlassPanel(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ReviewAvatar(name: reviewerName),
                const SizedBox(width: AppDimensions.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reviewerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      StarRating(rating: review.rate, size: 14),
                    ],
                  ),
                ),
                if (formattedDate != null || isAdmin)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (formattedDate != null)
                        Text(
                          formattedDate,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.color
                                    ?.withValues(alpha: 0.7),
                              ),
                        ),
                      if (isAdmin) ...[
                        const SizedBox(height: AppDimensions.spacingXs),
                        Material(
                          color: Colors.transparent,
                          child: Tooltip(
                            message: 'Delete review'.tr(context),
                            child: InkWell(
                              onTap: onDelete,
                              borderRadius: BorderRadius.circular(20),
                              child: const Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Icon(
                                  Icons.delete_outline_rounded,
                                  size: 18,
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
              ],
            ),
            if (review.comment.trim().isNotEmpty) ...[
              const SizedBox(height: AppDimensions.spacingMd),
              Text(
                review.comment.trim(),
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReviewAvatar extends StatelessWidget {
  final String name;

  const _ReviewAvatar({required this.name});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();

    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary(brightness).withValues(alpha: 0.1),
        border: Border.all(
          color: AppColors.primary(brightness).withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        initial,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AppColors.primary(brightness),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Error/empty state glass panel card for product reviews.
class ReviewStateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Brightness brightness;
  final Widget? action;

  const ReviewStateCard({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.brightness,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingDefault,
        vertical: AppDimensions.spacingXl,
      ),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: AppColors.foreground(brightness).withValues(alpha: 0.22),
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.foreground(brightness).withValues(alpha: 0.7),
              ),
            ),
            if (action != null) ...[
              const SizedBox(height: AppDimensions.spacingLg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
