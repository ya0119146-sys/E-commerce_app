import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/localization/app_translations.dart';
import '../../../../store/data/models/sub_category_model.dart';
import '../../../../store/logic/categories_cubit.dart';
import '../../../../store/logic/products_cubit.dart';
import '../../../logic/admin_cubit.dart';
import '../product_form.dart';
import '../shared/admin_item_actions.dart';

/// Admin products management tab with infinite scroll and pull-to-refresh.
class AdminProductsTab extends StatelessWidget {
  final ScrollController scrollController;
  final List<SubCategoryModel> allSubcategories;
  final void Function(Widget form) onShowForm;

  const AdminProductsTab({
    super.key,
    required this.scrollController,
    required this.allSubcategories,
    required this.onShowForm,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductsCubit, ProductsState>(
      builder: (context, state) {
        if (state.status == ProductsStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        final isLoadingMore = state.status == ProductsStatus.loadingMore;
        final totalCount = state.products.length + (isLoadingMore ? 1 : 0);

        return RefreshIndicator(
          onRefresh: () => context.read<ProductsCubit>().fetchProducts(
            refresh: true,
            clearCategory: true,
            clearKeyword: true,
            clearSort: true,
          ),
          child: ListView.builder(
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.screenPadding,
              AppDimensions.screenPadding,
              AppDimensions.screenPadding,
              100,
            ),
            itemCount: totalCount,
            itemBuilder: (context, index) {
              if (index >= state.products.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final product = state.products[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.only(left: 12, right: 8),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: product.cover != null
                        ? Image.network(
                            product.cover!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.image_not_supported),
                  ),
                  title: Text(product.name),
                  subtitle: Text(
                    product.onSale
                        ? '\$${product.displayPrice.toStringAsFixed(2)} (-${product.discountPercentage}%) • ${'Quantity'.tr(context)}: ${product.quantity}'
                        : '\$${product.price.toStringAsFixed(2)} • ${'Quantity'.tr(context)}: ${product.quantity}',
                  ),
                  trailing: AdminItemActions(
                    onEdit: () => onShowForm(
                      ProductForm(
                        product: product,
                        categories: context
                            .read<CategoriesCubit>()
                            .state
                            .categories,
                        subcategories: allSubcategories,
                        onSubmit: (data) => context
                            .read<AdminCubit>()
                            .updateProduct(product.id, data),
                      ),
                    ),
                    onDelete: () => showAdminDeleteConfirmDialog(
                      context,
                      onConfirm: () =>
                          context.read<AdminCubit>().deleteProduct(product.id),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
