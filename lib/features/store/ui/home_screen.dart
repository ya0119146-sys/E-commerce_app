import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../logic/products_cubit.dart';
import '../logic/categories_cubit.dart';
import 'widgets/product_card.dart';
import 'widgets/category_grid.dart';
import 'search_screen.dart';
import '../../../core/localization/app_translations.dart';

/// Home screen with Concept 1 hero banner, Concept 1 story categories, and Concept 2 trending products.
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

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      body: RefreshIndicator(
        color: AppColors.primary(brightness),
        onRefresh: () async {
          await Future.wait([
            context.read<ProductsCubit>().fetchProducts(refresh: true),
            context.read<CategoriesCubit>().fetchCategories(),
          ]);
        },
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
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

            // ─── Hero Banner (Concept 1: Editorial Cosmetics) ───
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.screenPadding,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF6B204D),
                      Color(0xFF4A1236),
                      Color(0xFF2E0921),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4A1236).withValues(alpha: 0.35),
                      blurRadius: 28,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                  child: Stack(
                    children: [
                      // Background Glowing Shapes
                      Positioned(
                        top: -40,
                        right: -30,
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFE8A598).withValues(alpha: 0.12),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -50,
                        left: -20,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.05),
                          ),
                        ),
                      ),

                      // Content
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 20,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Capsule Tag
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusRound,
                                ),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.25),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.auto_awesome,
                                    size: 12,
                                    color: Color(0xFFFFD194),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    'Exclusive Collection'.tr(context),
                                    style: const TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.8,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Heading
                            Text(
                              'New Collection'.tr(context),
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 25,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 5),

                            // Subtitle
                            Text(
                              'Discover luxury beauty essentials'.tr(context),
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                height: 1.35,
                                color: Colors.white.withValues(alpha: 0.88),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Action Row (Shop Now Button + Carousel Dots)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // CTA Button
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 9,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(
                                      AppDimensions.radiusRound,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.12),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Shop Now'.tr(context),
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF6B204D),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Icon(
                                        Directionality.of(context) == TextDirection.rtl
                                            ? Icons.arrow_back_rounded
                                            : Icons.arrow_forward_rounded,
                                        size: 15,
                                        color: const Color(0xFF6B204D),
                                      ),
                                    ],
                                  ),
                                ),

                                // Carousel Indicator Dots
                                Row(
                                  children: [
                                    Container(
                                      width: 18,
                                      height: 5,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFD194),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Container(
                                      width: 5,
                                      height: 5,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.4),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Container(
                                      width: 5,
                                      height: 5,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.4),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  .animate()
                  .fade(duration: 600.ms)
                  .scale(
                    begin: const Offset(0.97, 0.97),
                    end: const Offset(1.0, 1.0),
                    duration: 600.ms,
                  ),
            ),

            // ─── Section: Categories (Concept 1: Story Avatars) ───
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
            SliverToBoxAdapter(
              child: BlocBuilder<CategoriesCubit, CategoriesState>(
                builder: (context, state) {
                  if (state.status == CategoriesStatus.loading) {
                    return SizedBox(
                      height: 98,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.screenPadding,
                        ),
                        itemCount: 5,
                        separatorBuilder: (_, __) => const SizedBox(width: 14),
                        itemBuilder: (_, __) => const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ShimmerLoading(
                              width: 60,
                              height: 60,
                              borderRadius: 30,
                            ),
                            SizedBox(height: 6),
                            ShimmerLoading(
                              width: 50,
                              height: 12,
                              borderRadius: 6,
                            ),
                          ],
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
                  'Trending Now'.tr(context),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ),

            // ─── Product Grid (Concept 2: Minimalist High-Fashion 4:5 Cards) ───
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
                            color: AppColors.primary(
                              brightness,
                            ).withValues(alpha: 0.4),
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
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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

            // ─── Loading More Indicator (Pagination) ───
            BlocBuilder<ProductsCubit, ProductsState>(
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
            ),

            // Bottom spacing
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}
