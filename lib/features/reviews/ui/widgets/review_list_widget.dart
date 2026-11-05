import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/widgets/glass_panel.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/widgets/star_rating.dart';
import '../../../../core/utils/auth_guard.dart';
import '../../data/models/review_model.dart';
import '../../logic/review_cubit.dart';
import '../../logic/review_state.dart';
import 'add_review_dialog.dart';

class ReviewListWidget extends StatefulWidget {
  final String productId;
  final String role;

  const ReviewListWidget({
    super.key,
    required this.productId,
    required this.role,
  });

  @override
  State<ReviewListWidget> createState() => _ReviewListWidgetState();
}

class _ReviewListWidgetState extends State<ReviewListWidget> {
  @override
  void initState() {
    super.initState();
    context.read<ReviewCubit>().fetchProductReviews(widget.productId);
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return BlocBuilder<ReviewCubit, ReviewState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ReviewHeader(
              countLabel: _reviewCountLabel(state),
              isAdmin: widget.role == 'admin',
              onAddReview: () => _showAddReview(context),
            ),
            const SizedBox(height: 10),
            _buildReviewContent(context, state, brightness),
          ],
        );
      },
    );
  }

  Widget _buildReviewContent(
    BuildContext context,
    ReviewState state,
    Brightness brightness,
  ) {
    if (state is ReviewLoading) {
      return const Column(
        children: [
          ShimmerLoading(height: 112, width: double.infinity),
          SizedBox(height: AppDimensions.spacingMd),
          ShimmerLoading(height: 112, width: double.infinity),
        ],
      );
    }

    if (state is ReviewError) {
      return _ReviewStateCard(
        icon: Icons.error_outline_rounded,
        title: 'Could not load reviews'.tr(context),
        message: state.message,
        brightness: brightness,
        action: TextButton(
          onPressed: () {
            context.read<ReviewCubit>().fetchProductReviews(widget.productId);
          },
          style: TextButton.styleFrom(
            foregroundColor: AppColors.secondary(brightness),
          ),
          child: Text('Try Again'.tr(context)),
        ),
      );
    }

    if (state is ReviewLoaded) {
      if (state.reviews.isEmpty) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: AppColors.card(brightness),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.border(brightness).withValues(alpha: 0.5),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: brightness == Brightness.dark ? 0.2 : 0.03,
                ),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (i) => const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2.0),
                    child: Icon(
                      Icons.star_rounded,
                      size: 22,
                      color: Color(0xFFFFB800),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'No reviews yet'.tr(context),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.foreground(brightness),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.role == 'admin'
                    ? 'Reviews will appear here when customers share feedback.'
                          .tr(context)
                    : 'Be the first to share your experience.'.tr(context),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.foreground(
                    brightness,
                  ).withValues(alpha: 0.65),
                ),
              ),
              if (widget.role != 'admin') ...[
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => _showAddReview(context),
                  icon: const Icon(Icons.rate_review_outlined, size: 16),
                  label: Text('Write a Review'.tr(context)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.secondary(brightness),
                    side: BorderSide(
                      color: AppColors.secondary(
                        brightness,
                      ).withValues(alpha: 0.4),
                      width: 1.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusRound,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: state.reviews.length,
        separatorBuilder: (_, __) {
          return const SizedBox(height: 10);
        },
        itemBuilder: (context, index) {
          final review = state.reviews[index];

          return _ReviewCard(
                review: review,
                isAdmin: widget.role == 'admin',
                onDelete: () => _confirmDeleteReview(context, review.id),
              )
              .animate()
              .fade(duration: 400.ms, delay: (index * 50).ms)
              .moveY(begin: 10, end: 0);
        },
      );
    }

    return const SizedBox.shrink();
  }

  String? _reviewCountLabel(ReviewState state) {
    if (state is! ReviewLoaded) return null;

    final count = state.reviews.length;
    return count == 1
        ? '1 ${'review'.tr(context)}'
        : '$count ${'reviews'.tr(context)}';
  }

  void _showAddReview(BuildContext context) {
    AuthGuard.requireAuth(
      context,
      action: AuthActionType.generic,
      onAuthenticated: () {
        showDialog(
          context: context,
          builder: (context) => AddReviewDialog(productId: widget.productId),
        );
      },
    );
  }

  void _confirmDeleteReview(BuildContext context, String reviewId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Review'.tr(context)),
        content: Text(
          'Are you sure you want to delete this review?'.tr(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'.tr(context)),
          ),
          TextButton(
            onPressed: () {
              context.read<ReviewCubit>().deleteReview(reviewId);
              Navigator.pop(context);
            },
            child: Text('Delete'.tr(context)),
          ),
        ],
      ),
    );
  }
}

class _ReviewHeader extends StatelessWidget {
  final String? countLabel;
  final bool isAdmin;
  final VoidCallback onAddReview;

  const _ReviewHeader({
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

class _ReviewCard extends StatelessWidget {
  final ReviewModel review;
  final bool isAdmin;
  final VoidCallback onDelete;

  const _ReviewCard({
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

class _ReviewStateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Brightness brightness;
  final Widget? action;

  const _ReviewStateCard({
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
