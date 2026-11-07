import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_gradients.dart';
import '../../../core/widgets/star_rating.dart';
import '../../../core/widgets/hero_button.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../cart/logic/cart_cubit.dart';
import '../../cart/data/models/cart_model.dart';
import '../../cart/ui/cart_screen.dart';
import '../../wishlist/logic/wishlist_cubit.dart';
import '../../reviews/logic/review_cubit.dart';
import '../../reviews/ui/widgets/review_list_widget.dart';
import '../data/models/product_model.dart';
import '../data/models/category_model.dart';
import 'widgets/product_image_lightbox.dart';
import '../../admin/logic/admin_cubit.dart';
import '../../admin/ui/widgets/product_form.dart';
import '../logic/categories_cubit.dart';
import '../logic/products_cubit.dart';
import '../../../core/localization/app_translations.dart';
import '../../../core/utils/whatsapp_helper.dart';
import '../../../core/utils/auth_guard.dart';

/// Full-screen product detail with image, info, and Add to Cart.
class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;
  final String role;

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.role,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _selectedImageIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReviewCubit>().fetchProductReviews(widget.product.id);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _openLightbox(List<String> allImages) async {
    final newIndex = await ProductImageLightbox.show(
      context,
      images: allImages,
      initialIndex: _selectedImageIndex,
      heroTagPrefix: 'product_${widget.product.id}',
    );
    if (newIndex != null && newIndex != _selectedImageIndex && mounted) {
      _pageController.jumpToPage(newIndex);
      setState(() => _selectedImageIndex = newIndex);
    }
  }

  void _launchProductWhatsApp(BuildContext context) {
    WhatsAppHelper.inquireAboutProduct(
      productName: widget.product.name,
      price: widget.product.displayPrice,
      originalPrice: widget.product.price,
      onSale: widget.product.onSale,
      size: widget.product.size,
      category: widget.product.category,
      subcategory: widget.product.subcategory,
      productId: widget.product.id,
      inStock: widget.product.inStock,
      isArabic: context.isArabic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final product = widget.product;
    final allImages = [
      if (product.cover != null) product.cover!,
      ...product.images,
    ];

    // ─── Resolve Category & Subcategory Names ───
    String? categoryName = product.category;
    if (categoryName == null ||
        categoryName.trim().isEmpty ||
        ProductModel.isHexObjectId(categoryName.trim())) {
      if (product.categoryId != null && product.categoryId!.isNotEmpty) {
        try {
          final cats = context.read<CategoriesCubit>().state.categories;
          final match = cats.firstWhere(
            (c) => c.id == product.categoryId,
            orElse: () => const CategoryModel(id: '', name: ''),
          );
          if (match.name.isNotEmpty) {
            categoryName = match.name;
          } else {
            categoryName = null;
          }
        } catch (_) {
          categoryName = null;
        }
      } else {
        categoryName = null;
      }
    }

    String? subcategoryName = product.subcategory;
    if (subcategoryName != null &&
        (subcategoryName.trim().isEmpty ||
            ProductModel.isHexObjectId(subcategoryName.trim()))) {
      subcategoryName = null;
    }

    final isSameCategory =
        categoryName != null &&
        subcategoryName != null &&
        categoryName.trim().toLowerCase() ==
            subcategoryName.trim().toLowerCase();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ─── Image Header ───
          SliverAppBar(
            expandedHeight: 245.0 + MediaQuery.of(context).padding.top,
            pinned: true,
            backgroundColor: AppColors.background(brightness),
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.card(brightness).withValues(alpha: 0.85),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.border(
                          brightness,
                        ).withValues(alpha: 0.3),
                        width: 0.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        context.isArabic
                            ? Icons.arrow_forward_ios
                            : Icons.arrow_back_ios_new,
                        size: 16,
                        color: AppColors.foreground(brightness),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              // WhatsApp Merchant Inquiry Button
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4.0,
                  vertical: 8.0,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusRound,
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.card(
                          brightness,
                        ).withValues(alpha: 0.85),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.border(
                            brightness,
                          ).withValues(alpha: 0.3),
                          width: 0.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        tooltip: 'Contact on WhatsApp'.tr(context),
                        icon: Image.asset(
                          'assets/icons/whatsapp_icon.png',
                          width: 22,
                          height: 22,
                          fit: BoxFit.contain,
                        ),
                        onPressed: () => _launchProductWhatsApp(context),
                      ),
                    ),
                  ),
                ),
              ),
              BlocBuilder<WishlistCubit, WishlistState>(
                builder: (context, state) {
                  final isFav = state.isInWishlist(product.id);
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 8.0,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusRound,
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.card(
                              brightness,
                            ).withValues(alpha: 0.85),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.border(
                                brightness,
                              ).withValues(alpha: 0.3),
                              width: 0.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              size: 20,
                              color: isFav
                                  ? AppColors.primary(brightness)
                                  : AppColors.foreground(brightness),
                            ),
                            onPressed: () {
                              AuthGuard.requireAuth(
                                context,
                                action: AuthActionType.wishlist,
                                onAuthenticated: () {
                                  context.read<WishlistCubit>().toggleWishlist(
                                    product.id,
                                    product,
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Full-width Edge-to-Edge Image PageView
                  allImages.isNotEmpty
                      ? PageView.builder(
                          controller: _pageController,
                          onPageChanged: (i) =>
                              setState(() => _selectedImageIndex = i),
                          itemCount: allImages.length,
                          itemBuilder: (_, i) => GestureDetector(
                            onTap: () => _openLightbox(allImages),
                            child: Container(
                              width: double.infinity,
                              color: AppColors.card(brightness),
                              child: Hero(
                                tag: 'product_${product.id}_$i',
                                child: CachedNetworkImage(
                                  imageUrl: allImages[i],
                                  fit: BoxFit.cover,
                                  alignment: Alignment.center,
                                  placeholder: (_, __) => const ShimmerLoading(
                                    width: double.infinity,
                                    height: double.infinity,
                                    borderRadius: 0,
                                  ),
                                  errorWidget: (_, __, ___) => Container(
                                    color: AppColors.muted(brightness),
                                    child: Center(
                                      child: Icon(
                                        Icons.image_outlined,
                                        size: 60,
                                        color: AppColors.foreground(
                                          brightness,
                                        ).withValues(alpha: 0.15),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(
                          width: double.infinity,
                          color: AppColors.muted(brightness),
                          child: Center(
                            child: Icon(
                              Icons.shopping_bag_outlined,
                              size: 80,
                              color: AppColors.foreground(
                                brightness,
                              ).withValues(alpha: 0.15),
                            ),
                          ),
                        ),

                  // Floating Counter & Fullscreen Zoom Pill (with RTL fix)
                  if (allImages.isNotEmpty)
                    Positioned(
                      bottom: 14,
                      right: 14,
                      child: GestureDetector(
                        onTap: () => _openLightbox(allImages),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusXl,
                          ),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.card(
                                  brightness,
                                ).withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusXl,
                                ),
                                border: Border.all(
                                  color: AppColors.border(
                                    brightness,
                                  ).withValues(alpha: 0.4),
                                  width: 0.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.fullscreen,
                                    size: 15,
                                    color: AppColors.secondary(brightness),
                                  ),
                                  const SizedBox(width: 4),
                                  Directionality(
                                    textDirection: TextDirection.ltr,
                                    child: Text(
                                      '${_selectedImageIndex + 1} / ${allImages.length}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.foreground(brightness),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Floating Modern Dots Indicator (Centered at bottom of image)
                  if (allImages.length > 1)
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          allImages.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: _selectedImageIndex == i ? 18 : 6,
                            height: 5,
                            decoration: BoxDecoration(
                              color: _selectedImageIndex == i
                                  ? AppColors.secondary(brightness)
                                  : (brightness == Brightness.dark
                                        ? Colors.white.withValues(alpha: 0.45)
                                        : Colors.black.withValues(alpha: 0.35)),
                              borderRadius: BorderRadius.circular(3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 3,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Sale badge if product is on sale
                  if (product.onSale)
                    Positioned(
                      bottom: 14,
                      left: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary(brightness),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusSm,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary(
                                brightness,
                              ).withValues(alpha: 0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          'sale'.tr(context),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ─── Compact Thumbnail Carousel ───
          if (allImages.length > 1)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 0),
                child: SizedBox(
                  height: 42,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.screenPadding,
                    ),
                    itemCount: allImages.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final isSelected = _selectedImageIndex == i;
                      return GestureDetector(
                        onTap: () {
                          _pageController.animateToPage(
                            i,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOutCubic,
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusSm + 2,
                            ),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.secondary(brightness)
                                  : AppColors.border(brightness),
                              width: isSelected ? 2.0 : 1.0,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.secondary(
                                        brightness,
                                      ).withValues(alpha: 0.2),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusSm,
                            ),
                            child: Opacity(
                              opacity: isSelected ? 1.0 : 0.6,
                              child: CachedNetworkImage(
                                imageUrl: allImages[i],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

          // ─── Product Info ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.screenPadding,
                10,
                AppDimensions.screenPadding,
                AppDimensions.screenPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Luxury Category & Subcategory Breadcrumb Pills ───
                  if (categoryName != null || subcategoryName != null) ...[
                    _buildCategoryBreadcrumbs(
                      context: context,
                      brightness: brightness,
                      categoryName: categoryName,
                      categoryId: product.categoryId,
                      subcategoryName: subcategoryName,
                      isSame: isSameCategory,
                    ),
                    const SizedBox(height: 6),
                  ],

                  // Title
                  Text(
                        product.name,
                        style: Theme.of(context).textTheme.headlineLarge,
                      )
                      .animate()
                      .fade(duration: 500.ms)
                      .moveY(begin: 15, end: 0, duration: 500.ms),

                  const SizedBox(height: 6),

                  // Rating
                  if (product.ratingAvg > 0) ...[
                    Row(
                      children: [
                        StarRating(rating: product.ratingAvg),
                        const SizedBox(width: 8),
                        Text(
                          '${product.ratingAvg.toStringAsFixed(1)} (${product.ratingCount})',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ).animate().fade(duration: 400.ms, delay: 150.ms),
                    const SizedBox(height: 8),
                  ] else
                    const SizedBox(height: 4),

                  // Price Section with Discount Badge & Savings
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '\$${product.displayPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: AppColors.secondary(brightness),
                            ),
                          ),
                          if (product.onSale) ...[
                            const SizedBox(width: 12),
                            Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 18,
                                color: AppColors.foreground(
                                  brightness,
                                ).withValues(alpha: 0.4),
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accent(brightness),
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.accent(
                                      brightness,
                                    ).withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                '-${product.discountPercentage}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (product.onSale && product.savingsAmount > 0) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF2E7D32,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: const Color(
                                0xFF2E7D32,
                              ).withValues(alpha: 0.3),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.savings_outlined,
                                size: 14,
                                color: Color(0xFF2E7D32),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '${'You save'.tr(context)} \$${product.savingsAmount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Color(0xFF2E7D32),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ).animate().fade(duration: 400.ms, delay: 250.ms),

                  const SizedBox(height: 10),

                  // ─── Product Size / Volume Luxury Capsule ───
                  if (product.size != null &&
                      product.size!.trim().isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.card(brightness),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.secondary(
                            brightness,
                          ).withValues(alpha: 0.28),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: brightness == Brightness.dark ? 0.2 : 0.03,
                            ),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.science_outlined,
                                size: 16,
                                color: AppColors.secondary(brightness),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${'Size'.tr(context)}: ${product.size}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.foreground(brightness),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondary(
                                brightness,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Standard'.tr(context),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.secondary(brightness),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Stock status
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: product.inStock
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        product.inStock
                            ? '${'in_stock'.tr(context)} (${product.quantity})'
                            : 'out_of_stock'.tr(context),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: product.inStock
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                    ],
                  ),

                  // ─── Luxury Porcelain Description Card ───
                  if (product.description != null &&
                      product.description!.trim().isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.card(brightness),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.border(
                            brightness,
                          ).withValues(alpha: 0.5),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: brightness == Brightness.dark ? 0.2 : 0.03,
                            ),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                size: 16,
                                color: AppColors.secondary(brightness),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'description'.tr(context),
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.secondary(brightness),
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _ExpandableDescription(
                            description: product.description!,
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 14),
                  const Divider(height: 16),
                  const SizedBox(height: 8),
                  ReviewListWidget(productId: product.id, role: widget.role),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      // ─── Bottom Action Bar ───
      bottomNavigationBar: widget.role != 'admin'
          ? BlocBuilder<CartCubit, CartState>(
              builder: (context, cartState) {
                // Find if this product is currently in the cart
                CartItemModel? cartItem;
                for (final item in cartState.cart.items) {
                  if (item.productId == product.id ||
                      item.product?.id == product.id) {
                    cartItem = item;
                    break;
                  }
                }
                final quantityInCart = cartItem?.quantity ?? 0;
                final isInCart = quantityInCart > 0;

                return Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                  decoration: BoxDecoration(
                    color: AppColors.card(brightness),
                    border: Border(
                      top: BorderSide(
                        color: AppColors.border(
                          brightness,
                        ).withValues(alpha: 0.5),
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: brightness == Brightness.dark ? 0.3 : 0.05,
                        ),
                        blurRadius: 10,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: Tween<double>(
                            begin: 0.96,
                            end: 1.0,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: isInCart
                        ? _buildInCartBottomBar(
                            context,
                            brightness: brightness,
                            product: product,
                            quantity: quantityInCart,
                          )
                        : _buildAddToCartBottomBar(
                            context,
                            brightness: brightness,
                            product: product,
                          ),
                  ),
                );
              },
            )
          : Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              decoration: BoxDecoration(
                color: AppColors.card(brightness),
                border: Border(
                  top: BorderSide(
                    color: AppColors.border(brightness).withValues(alpha: 0.5),
                  ),
                ),
              ),
              child: HeroButton(
                text: 'Edit Product'.tr(context),
                icon: Icons.edit_outlined,
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Theme.of(context).cardColor,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (_) => ProductForm(
                      product: product,
                      categories: context
                          .read<CategoriesCubit>()
                          .state
                          .categories,
                      subcategories: const [],
                      onSubmit: (data) async {
                        await context.read<AdminCubit>().updateProduct(
                          product.id,
                          data,
                        );
                        if (context.mounted) {
                          context.read<ProductsCubit>().fetchProducts(
                            refresh: true,
                          );
                          Navigator.pop(context);
                        }
                      },
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildCategoryBreadcrumbs({
    required BuildContext context,
    required Brightness brightness,
    required String? categoryName,
    required String? categoryId,
    required String? subcategoryName,
    required bool isSame,
  }) {
    final isArabic = context.isArabic;

    return Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 6,
          children: [
            if (categoryName != null && categoryName.trim().isNotEmpty)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (categoryId != null && categoryId.isNotEmpty) {
                      context.read<CategoriesCubit>().selectCategory(
                        categoryId,
                      );
                      context.read<ProductsCubit>().fetchProducts(
                        category: categoryId,
                        refresh: true,
                      );
                      Navigator.pop(context);
                    }
                  },
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusRound,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondary(
                        brightness,
                      ).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusRound,
                      ),
                      border: Border.all(
                        color: AppColors.secondary(
                          brightness,
                        ).withValues(alpha: 0.24),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.spa_outlined,
                          size: 14,
                          color: AppColors.secondary(brightness),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          categoryName.trim(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.secondary(brightness),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (!isSame &&
                subcategoryName != null &&
                subcategoryName.trim().isNotEmpty) ...[
              Icon(
                isArabic
                    ? Icons.chevron_left_rounded
                    : Icons.chevron_right_rounded,
                size: 15,
                color: AppColors.foreground(brightness).withValues(alpha: 0.35),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary(brightness).withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusRound,
                  ),
                  border: Border.all(
                    color: AppColors.primary(
                      brightness,
                    ).withValues(alpha: 0.20),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 12,
                      color: AppColors.primary(brightness),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      subcategoryName.trim(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary(brightness),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        )
        .animate()
        .fade(duration: 450.ms)
        .moveY(begin: 8, end: 0, duration: 450.ms);
  }

  Widget _buildAddToCartBottomBar(
    BuildContext context, {
    required Brightness brightness,
    required ProductModel product,
  }) {
    return KeyedSubtree(
      key: const ValueKey('add_to_cart_state'),
      child: HeroButton(
        text: product.inStock
            ? 'add_to_cart'.tr(context)
            : 'out_of_stock'.tr(context),
        icon: Icons.shopping_bag_outlined,
        onPressed: product.inStock
            ? () {
                AuthGuard.requireAuth(
                  context,
                  action: AuthActionType.cart,
                  onAuthenticated: () {
                    context.read<CartCubit>().addToCart(product.id, product);
                    CustomSnackBar.showCart(
                      context,
                      '${'added_to_cart'.tr(context)} ✨',
                    );
                  },
                );
              }
            : null,
      ),
    );
  }

  Widget _buildInCartBottomBar(
    BuildContext context, {
    required Brightness brightness,
    required ProductModel product,
    required int quantity,
  }) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return KeyedSubtree(
      key: const ValueKey('in_cart_stepper_state'),
      child: SizedBox(
        height: 52,
        child: Row(
          children: [
            // ─── 1. In-Place Luxury Quantity Stepper Pill ───
            Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary(brightness).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: AppColors.primary(brightness).withValues(alpha: 0.35),
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Minus / Delete Button
                  _buildStepperButton(
                    context,
                    brightness: brightness,
                    icon: quantity == 1
                        ? Icons.delete_outline_rounded
                        : Icons.remove_rounded,
                    isDestructive: quantity == 1,
                    onTap: () {
                      if (quantity > 1) {
                        context.read<CartCubit>().updateQuantity(
                          product.id,
                          quantity - 1,
                        );
                      } else {
                        context.read<CartCubit>().removeFromCart(product.id);
                      }
                    },
                  ),

                  // Center Quantity Display: count + "في السلة" / "in cart"
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$quantity',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.foreground(brightness),
                            height: 1.1,
                          ),
                        ),
                        Text(
                          'in_cart'.tr(context),
                          style: GoogleFonts.cairo(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary(brightness),
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Plus Button
                  _buildStepperButton(
                    context,
                    brightness: brightness,
                    icon: Icons.add_rounded,
                    isPrimary: true,
                    onTap: () {
                      if (product.quantity > 0 &&
                          quantity >= product.quantity) {
                        CustomSnackBar.show(
                          context,
                          message: 'max_stock_reached'.tr(context),
                          type: SnackBarType.warning,
                        );
                        return;
                      }
                      context.read<CartCubit>().updateQuantity(
                        product.id,
                        quantity + 1,
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // ─── 2. Checkout Button (إتمام الشراء) ───
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CartScreen(role: widget.role),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(26),
                  child: Ink(
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: AppGradients.plum(brightness),
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary(
                            brightness,
                          ).withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.shopping_bag_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'checkout_now'.tr(context),
                              style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            isRtl
                                ? Icons.arrow_back_ios_new_rounded
                                : Icons.arrow_forward_ios_rounded,
                            color: Colors.white.withValues(alpha: 0.85),
                            size: 13,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepperButton(
    BuildContext context, {
    required Brightness brightness,
    required IconData icon,
    required VoidCallback onTap,
    bool isPrimary = false,
    bool isDestructive = false,
  }) {
    final Color bgColor;
    final Color iconColor;

    if (isPrimary) {
      bgColor = AppColors.primary(brightness);
      iconColor = Colors.white;
    } else if (isDestructive) {
      bgColor = AppColors.error.withValues(alpha: 0.12);
      iconColor = AppColors.error;
    } else {
      bgColor = AppColors.primary(brightness).withValues(alpha: 0.14);
      iconColor = AppColors.primary(brightness);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isPrimary ? null : bgColor,
            gradient: isPrimary ? AppGradients.plum(brightness) : null,
            shape: BoxShape.circle,
            boxShadow: isPrimary
                ? [
                    BoxShadow(
                      color: AppColors.primary(
                        brightness,
                      ).withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
      ),
    );
  }
}

/// Expandable Description with luxury Show more / Show less toggle
class _ExpandableDescription extends StatefulWidget {
  final String description;
  const _ExpandableDescription({required this.description});

  @override
  State<_ExpandableDescription> createState() => _ExpandableDescriptionState();
}

class _ExpandableDescriptionState extends State<_ExpandableDescription> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isLong = widget.description.length > 120;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: Text(
            widget.description,
            maxLines: _isExpanded || !isLong ? null : 3,
            overflow: _isExpanded || !isLong
                ? TextOverflow.visible
                : TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.6,
              color: AppColors.foreground(brightness).withValues(alpha: 0.85),
            ),
          ),
        ),
        if (isLong) ...[
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isExpanded
                      ? 'show_less'.tr(context)
                      : 'show_more'.tr(context),
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary(brightness),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 18,
                  color: AppColors.secondary(brightness),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
