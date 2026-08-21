import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../data/models/category_model.dart';

/// A horizontal scrolling list of category chips.
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
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding:
            const EdgeInsets.symmetric(horizontal: AppDimensions.screenPadding),
        itemCount: categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          if (index == 0) {
            final isSelected = selectedId == null || selectedId!.isEmpty;
            return _chip(
              context,
              label: 'All',
              isSelected: isSelected,
              brightness: brightness,
              onTap: () => onSelected(null),
            );
          }
          final cat = categories[index - 1];
          final isSelected = selectedId == cat.id;
          return _chip(
            context,
            label: cat.name,
            isSelected: isSelected,
            brightness: brightness,
            onTap: () => onSelected(cat.id),
          )
              .animate()
              .fade(
                duration: 300.ms,
                delay: Duration(milliseconds: 50 * index),
              )
              .moveX(
                begin: 20,
                end: 0,
                duration: 300.ms,
                delay: Duration(milliseconds: 50 * index),
              );
        },
      ),
    );
  }

  Widget _chip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required Brightness brightness,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.secondary(brightness)
              : AppColors.card(brightness),
          borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
          border: Border.all(
            color: isSelected
                ? AppColors.secondary(brightness)
                : AppColors.border(brightness),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : AppColors.foreground(brightness),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
