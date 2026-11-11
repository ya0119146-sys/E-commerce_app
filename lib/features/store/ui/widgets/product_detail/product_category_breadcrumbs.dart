import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/localization/app_translations.dart';
import '../../../logic/categories_cubit.dart';
import '../../../logic/products_cubit.dart';

/// Luxury breadcrumb pills displaying category and optional subcategory.
class ProductCategoryBreadcrumbs extends StatelessWidget {
  final String? categoryName;
  final String? categoryId;
  final String? subcategoryName;
  final bool isSameCategory;

  const ProductCategoryBreadcrumbs({
    super.key,
    required this.categoryName,
    required this.categoryId,
    required this.subcategoryName,
    required this.isSameCategory,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isArabic = context.isArabic;

    return Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 6,
          children: [
            if (categoryName != null && categoryName!.trim().isNotEmpty)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (categoryId != null && categoryId!.isNotEmpty) {
                      context.read<CategoriesCubit>().selectCategory(
                        categoryId!,
                      );
                      context.read<ProductsCubit>().fetchProducts(
                        category: categoryId,
                        refresh: true,
                      );
                      Navigator.pop(context);
                    }
                  },
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusRound,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondary(
                        brightness,
                      ).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusRound,
                      ),
                      border: Border.all(
                        color: AppColors.secondary(
                          brightness,
                        ).withValues(alpha: 0.24),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.spa_outlined,
                          size: 14,
                          color: AppColors.secondary(brightness),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          categoryName!.trim(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.secondary(brightness),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (!isSameCategory &&
                subcategoryName != null &&
                subcategoryName!.trim().isNotEmpty) ...[
              Icon(
                isArabic
                    ? Icons.chevron_left_rounded
                    : Icons.chevron_right_rounded,
                size: 15,
                color: AppColors.foreground(brightness).withValues(alpha: 0.35),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary(brightness).withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusRound,
                  ),
                  border: Border.all(
                    color: AppColors.primary(
                      brightness,
                    ).withValues(alpha: 0.20),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 12,
                      color: AppColors.primary(brightness),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      subcategoryName!.trim(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary(brightness),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        )
        .animate()
        .fade(duration: 450.ms)
        .moveY(begin: 8, end: 0, duration: 450.ms);
  }
}
