import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/localization/app_translations.dart';
import '../../../../store/data/models/category_model.dart';
import '../../../../store/data/models/sub_category_model.dart';

/// Optional Category and cascading Subcategory dropdowns for ProductForm.
class ProductFormCategoryDropdowns extends StatelessWidget {
  final List<CategoryModel> categories;
  final List<SubCategoryModel> subcategories;
  final String? selectedCategoryId;
  final String? selectedSubcategoryId;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<String?> onSubcategoryChanged;

  const ProductFormCategoryDropdowns({
    super.key,
    required this.categories,
    required this.subcategories,
    required this.selectedCategoryId,
    required this.selectedSubcategoryId,
    required this.onCategoryChanged,
    required this.onSubcategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    final filteredSubcats = selectedCategoryId == null
        ? subcategories
        : subcategories
              .where(
                (s) =>
                    s.categoryId.isEmpty || s.categoryId == selectedCategoryId,
              )
              .toList();
    final subcatsToShow = filteredSubcats.isNotEmpty
        ? filteredSubcats
        : subcategories;

    final currentSubcategoryValue =
        subcatsToShow.any((s) => s.id == selectedSubcategoryId)
        ? selectedSubcategoryId
        : null;

    return Column(
      children: [
        DropdownButtonFormField<String?>(
          initialValue: selectedCategoryId,
          dropdownColor: AppColors.card(brightness),
          borderRadius: BorderRadius.circular(16),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.secondary(brightness),
          ),
          decoration: InputDecoration(
            labelText: 'Category (Optional)'.tr(context),
            prefixIcon: const Icon(Icons.category_outlined),
          ),
          items: [
            _buildDropdownItem(
              context,
              brightness: brightness,
              value: null,
              label: 'None (Optional)'.tr(context),
              isSelected: selectedCategoryId == null,
              isNoneOption: true,
            ),
            ...categories.map(
              (c) => _buildDropdownItem(
                context,
                brightness: brightness,
                value: c.id,
                label: c.name,
                isSelected: c.id == selectedCategoryId,
              ),
            ),
          ],
          onChanged: onCategoryChanged,
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String?>(
          initialValue: currentSubcategoryValue,
          dropdownColor: AppColors.card(brightness),
          borderRadius: BorderRadius.circular(16),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.secondary(brightness),
          ),
          decoration: InputDecoration(
            labelText: 'Subcategory (Optional)'.tr(context),
            prefixIcon: const Icon(Icons.account_tree_outlined),
          ),
          items: [
            _buildDropdownItem(
              context,
              brightness: brightness,
              value: null,
              label: 'None (Optional)'.tr(context),
              isSelected: currentSubcategoryValue == null,
              isNoneOption: true,
            ),
            ...subcatsToShow.map(
              (s) => _buildDropdownItem(
                context,
                brightness: brightness,
                value: s.id,
                label: s.name,
                isSelected: s.id == currentSubcategoryValue,
              ),
            ),
          ],
          onChanged: onSubcategoryChanged,
        ),
      ],
    );
  }

  DropdownMenuItem<String?> _buildDropdownItem(
    BuildContext context, {
    required Brightness brightness,
    required String? value,
    required String label,
    required bool isSelected,
    bool isNoneOption = false,
  }) {
    return DropdownMenuItem<String?>(
      value: value,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? AppColors.secondary(brightness)
                  : (isNoneOption
                        ? AppColors.foreground(
                            brightness,
                          ).withValues(alpha: 0.6)
                        : AppColors.foreground(brightness)),
            ),
          ),
          if (isSelected) ...[
            const SizedBox(width: 12),
            Icon(
              Icons.check_circle_rounded,
              size: 18,
              color: AppColors.secondary(brightness),
            ),
          ],
        ],
      ),
    );
  }
}
