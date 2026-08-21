import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/glass_panel.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/widgets/star_rating.dart';
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
            const SizedBox(height: AppDimensions.spacingDefault),
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
        title: 'Could not load reviews',
        message: state.message,
        brightness: brightness,
        action: TextButton(
          onPressed: () {
            context.read<ReviewCubit>().fetchProductReviews(widget.productId);
          },
          style: TextButton.styleFrom(
            foregroundColor: AppColors.secondary(brightness),
          ),
          child: const Text('Try Again'),
        ),
      );
    }

    if (state is ReviewLoaded) {
      if (state.reviews.isEmpty) {
        return _ReviewStateCard(
          icon: Icons.rate_review_outlined,
          title: 'No reviews yet',
          message: widget.role == 'admin'
              ? 'Reviews will appear here when customers share feedback.'
              : 'Be the first to share your experience.',
          brightness: brightness,
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: state.reviews.length,
        separatorBuilder: (_, __) {
          return const SizedBox(height: AppDimensions.spacingMd);
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
    return count == 1 ? '1 review' : '$count reviews';
  }

  void _showAddReview(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddReviewDialog(productId: widget.productId),
    );
  }

  void _confirmDeleteReview(BuildContext context, String reviewId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Review'),
        content: const Text('Are you sure you want to delete this review?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<ReviewCubit>().deleteReview(reviewId);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
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
      children: [
        Text('Customer Reviews', style: Theme.of(context).textTheme.titleLarge),
        if (countLabel != null) ...[
          const SizedBox(height: AppDimensions.spacingXs),
          Text(countLabel!, style: Theme.of(context).textTheme.bodySmall),
        ],
      ],
    );

    if (isAdmin) return title;

    final addButton = TextButton.icon(
      onPressed: onAddReview,
      icon: const Icon(Icons.add_rounded, size: 18),
      label: const Text('Add Review'),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.secondary(brightness),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingSm,
          vertical: AppDimensions.spacingXs,
        ),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 360) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              title,
              const SizedBox(height: AppDimensions.spacingSm),
              Align(alignment: Alignment.centerLeft, child: addButton),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: title),
            const SizedBox(width: AppDimensions.spacingMd),
            addButton,
          ],
        );
      },
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
    final reviewerName = review.name.trim().isEmpty ? 'Customer' : review.name.trim();
    final formattedDate = review.createdAt == null ? null : DateFormat.yMMMd().format(review.createdAt!);

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
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
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
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).textTheme.labelSmall?.color?.withValues(alpha: 0.7),
                          ),
                        ),
                      if (isAdmin) ...[
                        const SizedBox(height: AppDimensions.spacingXs),
                        Material(
                          color: Colors.transparent,
                          child: Tooltip(
                            message: 'Delete review',
                            child: InkWell(
                              onTap: onDelete,
                              borderRadius: BorderRadius.circular(20),
                              child: const Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
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
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
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
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
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
