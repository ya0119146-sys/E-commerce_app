import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/localization/app_translations.dart';
import '../../../../store/data/models/sub_category_model.dart';
import '../../../../store/logic/categories_cubit.dart';
import '../../../logic/admin_cubit.dart';
import '../shared/admin_item_actions.dart';
import '../subcategory_form.dart';

/// Admin subcategories management tab.
class AdminSubcategoriesTab extends StatelessWidget {
  final bool isLoading;
  final List<SubCategoryModel> subcategories;
  final void Function(Widget form) onShowForm;

  const AdminSubcategoriesTab({
    super.key,
    required this.isLoading,
    required this.subcategories,
    required this.onShowForm,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.screenPadding,
        AppDimensions.screenPadding,
        AppDimensions.screenPadding,
        100,
      ),
      itemCount: subcategories.length,
      itemBuilder: (context, index) {
        final subcat = subcategories[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.only(left: 12, right: 8),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: subcat.image != null
                  ? Image.network(
                      subcat.image!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    )
                  : const Icon(Icons.subtitles_outlined),
            ),
            title: Text(subcat.name),
            subtitle: Text('${'Category'.tr(context)}: ${subcat.categoryName}'),
            trailing: AdminItemActions(
              onEdit: () => onShowForm(
                SubcategoryForm(
                  subcategory: subcat,
                  categories: context.read<CategoriesCubit>().state.categories,
                  onSubmit: (data) => context
                      .read<AdminCubit>()
                      .updateSubcategory(subcat.id, data),
                ),
              ),
              onDelete: () => showAdminDeleteConfirmDialog(
                context,
                onConfirm: () =>
                    context.read<AdminCubit>().deleteSubcategory(subcat.id),
              ),
            ),
          ),
        );
      },
    );
  }
}
