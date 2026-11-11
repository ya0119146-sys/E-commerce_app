import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimensions.dart';

/// Horizontal compact thumbnail selector below the main product gallery.
class ProductThumbnailCarousel extends StatelessWidget {
  final List<String> allImages;
  final int selectedImageIndex;
  final PageController pageController;

  const ProductThumbnailCarousel({
    super.key,
    required this.allImages,
    required this.selectedImageIndex,
    required this.pageController,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 0),
        child: SizedBox(
          height: 42,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.screenPadding,
            ),
            itemCount: allImages.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final isSelected = selectedImageIndex == i;
              return GestureDetector(
                onTap: () {
                  pageController.animateToPage(
                    i,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOutCubic,
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusSm + 2,
                    ),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.secondary(brightness)
                          : AppColors.border(brightness),
                      width: isSelected ? 2.0 : 1.0,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.secondary(
                                brightness,
                              ).withValues(alpha: 0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                    child: Opacity(
                      opacity: isSelected ? 1.0 : 0.6,
                      child: CachedNetworkImage(
                        imageUrl: allImages[i],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
