import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/localization/app_translations.dart';
import '../../data/models/category_model.dart';

/// Concept 1: Instagram-Story style circular category avatars with luxury gradient rings.
class CategoryGrid extends StatelessWidget {
  final List<CategoryModel> categories;
  final String? selectedId;
  final ValueChanged<String?> onSelected;

  const CategoryGrid({
    super.key,
    required this.categories,
    this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return SizedBox(
      height: 114,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        cacheExtent: 300.0,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.screenPadding,
        ),
        itemCount: categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          if (index == 0) {
            final isSelected = selectedId == null || selectedId!.isEmpty;
            return _storyAvatar(
              context,
              label: 'All'.tr(context),
              isSelected: isSelected,
              brightness: brightness,
              icon: Icons.auto_awesome_rounded,
              imageUrl: null,
              onTap: () => onSelected(null),
            );
          }
          final cat = categories[index - 1];
          final isSelected = selectedId == cat.id;
          return _storyAvatar(
            context,
            label: cat.name,
            isSelected: isSelected,
            brightness: brightness,
            icon: _getCategoryIcon(cat.name),
            imageUrl: cat.image,
            onTap: () => onSelected(cat.id),
          );
        },
      ),
    );
  }

  Widget _storyAvatar(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required Brightness brightness,
    required IconData icon,
    required String? imageUrl,
    required VoidCallback onTap,
  }) {
    const double circleSize = 60.0;
    const double innerSize = 52.0;

    // Rose gold & plum gradient for selected ring
    final activeGradient = LinearGradient(
      colors: [
        AppColors.secondary(brightness),
        const Color(0xFFC76D7E),
        const Color(0xFFE8A598),
        AppColors.primary(brightness),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 78,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Outer Ring
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: circleSize,
                height: circleSize,
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isSelected ? activeGradient : null,
                  border: isSelected
                      ? null
                      : Border.all(
                          color: AppColors.border(brightness).withValues(alpha: 0.6),
                          width: 1.5,
                        ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.secondary(brightness).withValues(alpha: 0.28),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Container(
                  width: innerSize,
                  height: innerSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.card(brightness),
                    image: imageUrl != null && imageUrl.isNotEmpty
                        ? DecorationImage(
                            image: CachedNetworkImageProvider(
                              imageUrl,
                              maxWidth: 150,
                              maxHeight: 150,
                            ),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: imageUrl == null || imageUrl.isEmpty
                      ? _fallbackIcon(icon, isSelected, brightness)
                      : null,
                ),
              ),
              const SizedBox(height: 6),
              // Category Name Label
              SizedBox(
                height: 32,
                child: Center(
                  child: Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11.5,
                      height: 1.25,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? AppColors.secondary(brightness)
                          : AppColors.foreground(brightness).withValues(alpha: 0.85),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fallbackIcon(IconData icon, bool isSelected, Brightness brightness) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.secondary(brightness).withValues(alpha: 0.12)
            : AppColors.muted(brightness).withValues(alpha: 0.6),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          icon,
          size: 24,
          color: isSelected
              ? AppColors.secondary(brightness)
              : AppColors.foreground(brightness).withValues(alpha: 0.6),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('عطر') || lower.contains('perfume') || lower.contains('fragrance')) {
      return Icons.opacity_rounded;
    }
    if (lower.contains('بشرة') || lower.contains('skin') || lower.contains('care')) {
      return Icons.spa_outlined;
    }
    if (lower.contains('شعر') || lower.contains('hair')) {
      return Icons.face_retouching_natural_rounded;
    }
    if (lower.contains('مكياج') || lower.contains('makeup') || lower.contains('beauty')) {
      return Icons.brush_outlined;
    }
    if (lower.contains('أظافر') || lower.contains('nail')) {
      return Icons.favorite_border_rounded;
    }
    if (lower.contains('حقائب') || lower.contains('bag') || lower.contains('accessories')) {
      return Icons.shopping_bag_outlined;
    }
    return Icons.diamond_outlined;
  }
}
