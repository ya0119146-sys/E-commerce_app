import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/widgets/shimmer_loading.dart';
import '../../../logic/categories_cubit.dart';
import '../../../logic/products_cubit.dart';
import '../category_grid.dart';

/// Sliver section displaying horizontal category stories with shimmer loading fallback.
class HomeCategoriesSection extends StatelessWidget {
  const HomeCategoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: BlocBuilder<CategoriesCubit, CategoriesState>(
        buildWhen: (prev, next) =>
            prev.status != next.status ||
            prev.categories != next.categories ||
            prev.selectedCategoryId != next.selectedCategoryId,
        builder: (context, state) {
          if (state.status == CategoriesStatus.loading) {
            return SizedBox(
              height: 114,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.screenPadding,
                ),
                itemCount: 5,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, __) => const SizedBox(
                  width: 78,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ShimmerLoading(width: 60, height: 60, borderRadius: 30),
                      SizedBox(height: 6),
                      ShimmerLoading(width: 56, height: 14, borderRadius: 6),
                    ],
                  ),
                ),
              ),
            );
          }

          return CategoryGrid(
            categories: state.categories,
            selectedId: state.selectedCategoryId,
            onSelected: (id) {
              context.read<CategoriesCubit>().selectCategory(id);
              context.read<ProductsCubit>().fetchProducts(
                category: id,
                clearCategory: id == null || id.isEmpty,
                refresh: true,
              );
            },
          );
        },
      ),
    );
  }
}
