import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_dimensions.dart';
import '../../../../store/logic/categories_cubit.dart';
import '../../../logic/admin_cubit.dart';
import '../category_form.dart';
import '../shared/admin_item_actions.dart';

/// Admin categories management tab.
class AdminCategoriesTab extends StatelessWidget {
  final void Function(Widget form) onShowForm;

  const AdminCategoriesTab({super.key, required this.onShowForm});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoriesCubit, CategoriesState>(
      builder: (context, state) {
        if (state.status == CategoriesStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.screenPadding,
            AppDimensions.screenPadding,
            AppDimensions.screenPadding,
            100,
          ),
          itemCount: state.categories.length,
          itemBuilder: (context, index) {
            final category = state.categories[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: const EdgeInsets.only(left: 12, right: 8),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: category.image != null
                      ? Image.network(
                          category.image!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.category),
                ),
                title: Text(category.name),
                trailing: AdminItemActions(
                  onEdit: () => onShowForm(
                    CategoryForm(
                      category: category,
                      onSubmit: (data) => context
                          .read<AdminCubit>()
                          .updateCategory(category.id, data),
                    ),
                  ),
                  onDelete: () => showAdminDeleteConfirmDialog(
                    context,
                    onConfirm: () =>
                        context.read<AdminCubit>().deleteCategory(category.id),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
