import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
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
    _scrollController.animateTo(
      380,
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeInOutCubic,
    );
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
        child: CustomScrollView(
          controller: _scrollController,
          cacheExtent: 600.0,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ─── App Bar ───
            SliverAppBar(
              floating: true,
              snap: true,
              pinned: true,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              backgroundColor: AppColors.background(brightness),
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

            // ─── Hero Banner (Concept 1: Auto-Scrolling Editorial Carousel) ───
            SliverToBoxAdapter(
              child: RepaintBoundary(
                child: _EditorialHeroCarousel(
                  onShopNow: _scrollToProducts,
                ),
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
              child: RepaintBoundary(
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

            // ─── Product Grid (Dynamic-Height Content-Driven Cards) ───
            BlocBuilder<ProductsCubit, ProductsState>(
              builder: (context, state) {
                if (state.status == ProductsStatus.loading) {
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.screenPadding,
                    ),
                    sliver: SliverMasonryGrid.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      itemBuilder: (_, __) => const ShimmerProductCard(),
                      childCount: 6,
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
                  sliver: SliverMasonryGrid.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    itemBuilder: (_, index) => ProductCard(
                      role: widget.role,
                      product: state.products[index],
                      index: index,
                    ),
                    childCount: state.products.length,
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

class _BannerSlideData {
  final String tag;
  final String title;
  final String subtitle;
  final List<Color> gradientColors;
  final String ctaText;

  const _BannerSlideData({
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.gradientColors,
    required this.ctaText,
  });
}

/// Concept 1: Luxury Editorial Auto-Scrolling Hero Banner Carousel.
class _EditorialHeroCarousel extends StatefulWidget {
  final VoidCallback onShopNow;

  const _EditorialHeroCarousel({required this.onShopNow});

  @override
  State<_EditorialHeroCarousel> createState() => _EditorialHeroCarouselState();
}

class _EditorialHeroCarouselState extends State<_EditorialHeroCarousel> {
  late PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (_pageController.hasClients) {
        _currentPage = (_currentPage + 1) % 3;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 650),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slides = [
      _BannerSlideData(
        tag: 'Exclusive Collection'.tr(context),
        title: 'New Collection'.tr(context),
        subtitle: 'Discover luxury beauty essentials'.tr(context),
        gradientColors: const [
          Color(0xFF6B204D),
          Color(0xFF4A1236),
          Color(0xFF2E0921),
        ],
        ctaText: 'Shop Now'.tr(context),
      ),
      _BannerSlideData(
        tag: 'Special Offers'.tr(context),
        title: 'Up to 50% Off'.tr(context),
        subtitle: 'On luxury skincare and premium fragrances'.tr(context),
        gradientColors: const [
          Color(0xFF8E3A59),
          Color(0xFF5A1C36),
          Color(0xFF380E21),
        ],
        ctaText: 'Shop Now'.tr(context),
      ),
      _BannerSlideData(
        tag: 'Trending Now'.tr(context),
        title: 'Radiant Beauty'.tr(context),
        subtitle: 'Selected from world-class luxury beauty brands'.tr(context),
        gradientColors: const [
          Color(0xFF531E4D),
          Color(0xFF3B1036),
          Color(0xFF230820),
        ],
        ctaText: 'Shop Now'.tr(context),
      ),
    ];

    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final bannerHeight =
        (152.0 * (textScale > 1.0 ? textScale : 1.0)).clamp(148.0, 180.0);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.screenPadding,
        vertical: 8,
      ),
      height: bannerHeight,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (idx) {
              setState(() => _currentPage = idx);
              _startTimer(); // reset auto-scroll timer on user interaction
            },
            itemCount: slides.length,
            itemBuilder: (context, index) {
              final slide = slides[index];
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: slide.gradientColors,
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
                      color: slide.gradientColors[1].withValues(alpha: 0.35),
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
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Capsule Tag
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2.5,
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
                                    size: 10.5,
                                    color: Color(0xFFFFD194),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    slide.tag,
                                    style: const TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 5),

                            // Heading
                            Text(
                              slide.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 2),

                            // Subtitle
                            Text(
                              slide.subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.cairo(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                height: 1.2,
                                color: Colors.white.withValues(alpha: 0.88),
                              ),
                            ),

                            const Spacer(),

                            // Action Row (Shop Now Button + Carousel Dots)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Working Shop Now CTA Button
                                GestureDetector(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    widget.onShopNow();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 13,
                                      vertical: 6,
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
                                          slide.ctaText,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: slide.gradientColors[0],
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          Directionality.of(context) == TextDirection.rtl
                                              ? Icons.arrow_back_rounded
                                              : Icons.arrow_forward_rounded,
                                          size: 12,
                                          color: slide.gradientColors[0],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Interactive Carousel Indicator Dots
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: List.generate(slides.length, (dotIdx) {
                                    final isActive = _currentPage == dotIdx;
                                    return GestureDetector(
                                      onTap: () {
                                        _pageController.animateToPage(
                                          dotIdx,
                                          duration: const Duration(milliseconds: 400),
                                          curve: Curves.easeInOut,
                                        );
                                      },
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 300),
                                        margin: const EdgeInsets.symmetric(horizontal: 2.5),
                                        width: isActive ? 16 : 5.5,
                                        height: 4.5,
                                        decoration: BoxDecoration(
                                          color: isActive
                                              ? const Color(0xFFFFD194)
                                              : Colors.white.withValues(alpha: 0.4),
                                          borderRadius: BorderRadius.circular(3),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
