import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/localization/app_translations.dart';
import '../../../../../core/widgets/product_grid_delegate.dart';
import '../../../../../core/widgets/shimmer_loading.dart';
import '../../../logic/products_cubit.dart';
import '../product_card.dart';

/// Sliver grid displaying products with shimmer loading, error retry, and empty states.
class HomeProductsSliverGrid extends StatelessWidget {
  final String role;

  const HomeProductsSliverGrid({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return BlocBuilder<ProductsCubit, ProductsState>(
      // Skip rebuild when only status flips to loadingMore — avoids layout thrash.
      buildWhen: (prev, next) {
        if (prev.products.length != next.products.length) return true;
        if (next.status == ProductsStatus.loadingMore) return false;
        if (prev.status != next.status) return true;
        return prev.category != next.category || prev.keyword != next.keyword;
      },
      builder: (context, state) {
        if (state.status == ProductsStatus.loading) {
          return SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.screenPadding,
            ),
            sliver: SliverGrid(
              gridDelegate: ProductGridDelegate.create(context),
              delegate: SliverChildBuilderDelegate(
                (_, __) => const ShimmerProductCard(),
                childCount: 6,
              ),
            ),
          );
        }

        if (state.status == ProductsStatus.error) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.cloud_off_outlined,
                    size: 48,
                    color: AppColors.foreground(
                      brightness,
                    ).withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    state.errorMessage ?? 'Failed to load products',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context
                        .read<ProductsCubit>()
                        .fetchProducts(refresh: true),
                    child: Text('Retry'.tr(context)),
                  ),
                ],
              ),
            ),
          );
        }

        if (state.products.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 56,
                    color: AppColors.primary(brightness).withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No products found'.tr(context),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.screenPadding,
          ),
          sliver: SliverGrid(
            gridDelegate: ProductGridDelegate.create(context),
            delegate: SliverChildBuilderDelegate(
              (_, index) => ProductCard(
                key: ValueKey(state.products[index].id),
                role: role,
                product: state.products[index],
                index: index,
              ),
              childCount: state.products.length,
            ),
          ),
        );
      },
    );
  }
}

/// Sliver footer showing pagination spinner when loading additional product pages.
class HomePaginationSliver extends StatelessWidget {
  const HomePaginationSliver({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return BlocBuilder<ProductsCubit, ProductsState>(
      builder: (context, state) {
        if (state.status == ProductsStatus.loadingMore) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.primary(brightness),
                  ),
                ),
              ),
            ),
          );
        }
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }
}
