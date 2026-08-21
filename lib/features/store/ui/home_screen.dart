import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_gradients.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../logic/products_cubit.dart';
import '../logic/categories_cubit.dart';
import 'widgets/product_card.dart';
import 'widgets/category_grid.dart';
import 'search_screen.dart';

/// Home screen with hero banner, categories, and trending products.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.role});
  final String role;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProductsCubit>().fetchProducts(refresh: true);
    context.read<CategoriesCubit>().fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ─── App Bar ───
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: AppColors.background(
              brightness,
            ).withValues(alpha: 0.9),
            title: Text(
              'Labella',
              style: GoogleFonts.greatVibes(
                fontSize: 30,
                color: AppColors.secondary(brightness),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SearchScreen(role: widget.role),
                    ),
                  );
                },
              ),
            ],
          ),

          // ─── Hero Banner ───
          SliverToBoxAdapter(
            child:
                Container(
                      margin: const EdgeInsets.all(AppDimensions.screenPadding),
                      height: size.height * 0.22,
                      decoration: BoxDecoration(
                        gradient: AppGradients.plum(brightness),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusXl,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.secondary(
                              brightness,
                            ).withValues(alpha: 0.25),
                            blurRadius: 30,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Decorative circles
                          Positioned(
                            top: -30,
                            right: -20,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.08),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -20,
                            left: -10,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.06),
                              ),
                            ),
                          ),
                          // Content
                          Padding(
                            padding: const EdgeInsets.all(
                              AppDimensions.spacingLg,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                      'New Collection',
                                      style: GoogleFonts.playfairDisplay(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    )
                                    .animate()
                                    .fade(duration: 600.ms)
                                    .moveX(
                                      begin: -20,
                                      end: 0,
                                      duration: 600.ms,
                                    ),
                                const SizedBox(height: 4),
                                Text(
                                  'Discover luxury beauty essentials',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: Colors.white.withValues(alpha: 0.85),
                                  ),
                                ).animate().fade(
                                  duration: 500.ms,
                                  delay: 200.ms,
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(
                                      AppDimensions.radiusRound,
                                    ),
                                  ),
                                  child: Text(
                                    'Shop Now',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.secondary(brightness),
                                    ),
                                  ),
                                ).animate().fade(
                                  duration: 500.ms,
                                  delay: 400.ms,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                    .animate()
                    .fade(duration: 700.ms)
                    .scale(
                      begin: const Offset(0.95, 0.95),
                      end: const Offset(1.0, 1.0),
                      duration: 700.ms,
                    ),
          ),

          // ─── Section: Categories ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                left: AppDimensions.screenPadding,
                right: AppDimensions.screenPadding,
                bottom: 12,
              ),
              child: Text(
                'Categories',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: BlocBuilder<CategoriesCubit, CategoriesState>(
              builder: (context, state) {
                if (state.status == CategoriesStatus.loading) {
                  return SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.screenPadding,
                      ),
                      itemCount: 5,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (_, __) => const ShimmerLoading(
                        width: 80,
                        height: 44,
                        borderRadius: 22,
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
                      category: id ?? '',
                      refresh: true,
                    );
                  },
                );
              },
            ),
          ),

          // ─── Section: Trending Products ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                left: AppDimensions.screenPadding,
                right: AppDimensions.screenPadding,
                top: 24,
                bottom: 12,
              ),
              child: Text(
                'Trending Now',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ),

          // ─── Product Grid ───
          BlocBuilder<ProductsCubit, ProductsState>(
            builder: (context, state) {
              if (state.status == ProductsStatus.loading) {
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.screenPadding,
                  ),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 0.58,
                        ),
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
                          child: const Text('Retry'),
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
                          color: AppColors.primary(
                            brightness,
                          ).withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No products found',
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
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.58,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (_, index) => ProductCard(
                      role: widget.role,
                      product: state.products[index],
                      index: index,
                    ),
                    childCount: state.products.length,
                  ),
                ),
              );
            },
          ),

          // Bottom spacing
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
