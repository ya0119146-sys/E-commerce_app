import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/localization/app_translations.dart';
import '../../logic/categories_cubit.dart';
import '../../logic/products_cubit.dart';
import '../widgets/home/editorial_hero_carousel.dart';
import '../widgets/home/home_categories_section.dart';
import '../widgets/home/home_products_sliver_grid.dart';
import '../widgets/home/home_sliver_app_bar.dart';

/// Home screen with Concept 1 auto-scrolling hero banner,
/// Concept 1 story categories, and Concept 2 trending products.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.role});
  final String role;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<ProductsCubit>().fetchProducts(refresh: true);
    context.read<CategoriesCubit>().fetchCategories();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= 250) {
      context.read<ProductsCubit>().loadMore();
    }
  }

  void _scrollToProducts() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final target = (320.0).clamp(0.0, maxScroll);
    if (target > 0) {
      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      backgroundColor: AppColors.background(brightness),
      body: RefreshIndicator(
        color: AppColors.primary(brightness),
        onRefresh: () async {
          await Future.wait([
            context.read<ProductsCubit>().fetchProducts(refresh: true),
            context.read<CategoriesCubit>().fetchCategories(),
          ]);
        },
        child: ColoredBox(
          color: AppColors.background(brightness),
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              HomeSliverAppBar(role: widget.role),

              SliverToBoxAdapter(
                child: EditorialHeroCarousel(onShopNow: _scrollToProducts),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: AppDimensions.screenPadding,
                    right: AppDimensions.screenPadding,
                    top: 8,
                    bottom: 12,
                  ),
                  child: Text(
                    'Categories'.tr(context),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ),

              const HomeCategoriesSection(),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: AppDimensions.screenPadding,
                    right: AppDimensions.screenPadding,
                    top: 24,
                    bottom: 12,
                  ),
                  child: Text(
                    'Trending Now'.tr(context),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ),

              HomeProductsSliverGrid(role: widget.role),

              const HomePaginationSliver(),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }
}
