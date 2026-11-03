import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../wishlist/logic/wishlist_cubit.dart';
import '../../../cart/logic/cart_cubit.dart';
import '../../../admin/logic/admin_cubit.dart';
import '../../../admin/ui/widgets/product_form.dart';
import '../../logic/categories_cubit.dart';
import '../../logic/products_cubit.dart';
import '../../data/models/product_model.dart';
import '../product_detail_screen.dart';
import '../../../../core/localization/app_translations.dart';

/// Concept 2: Minimalist High-Fashion / Luxury Farfetch & Zara Style Product Card.
/// Dynamic-height squircle card:
/// 1:1 squircle image, floating frosted-glass wishlist heart,
/// title, star rating or "New ✨" badge, price with discount tag and strike-through original price,
/// and contextual action button (Add to Cart for customers, Edit for admins).
class ProductCard extends StatefulWidget {
  final ProductModel product;
  final int index;
  final String role;

  const ProductCard({
    super.key,
    required this.product,
    this.index = 0,
    required this.role,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;

  void _openAdminEditSheet(BuildContext context, ProductModel product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ProductForm(
        product: product,
        categories: context.read<CategoriesCubit>().state.categories,
        subcategories: const [],
        onSubmit: (data) async {
          await context.read<AdminCubit>().updateProduct(product.id, data);
          if (context.mounted) {
            context.read<ProductsCubit>().fetchProducts(refresh: true);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final product = widget.product;

    return RepaintBoundary(
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  ProductDetailScreen(role: widget.role, product: product),
            ),
          );
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.card(brightness),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.border(brightness).withValues(alpha: 0.5),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // ─── 1:1 Image Section with Frosted Glass Wishlist & Sale Badge ───
                AspectRatio(
                  aspectRatio: 1.0,
                  child: Stack(
                    children: [
                      // Product image with hardware-accelerated memory cache
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(15),
                        ),
                        child: SizedBox.expand(
                          child: product.cover != null &&
                                  product.cover!.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: product.cover!,
                                  fit: BoxFit.cover,
                                  memCacheWidth: 600,
                                  memCacheHeight: 600,
                                  maxWidthDiskCache: 800,
                                  maxHeightDiskCache: 800,
                                  placeholder: (_, __) =>
                                      const ShimmerLoading(
                                        width: double.infinity,
                                        height: double.infinity,
                                        borderRadius: 0,
                                      ),
                                  errorWidget: (_, __, ___) =>
                                      _placeholder(brightness),
                                )
                              : _placeholder(brightness),
                        ),
                      ),

                      // Sale / Out of Stock Pill (Top-Start)
                      if (product.onSale || !product.inStock)
                        PositionedDirectional(
                          top: 8,
                          start: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: product.onSale
                                  ? AppColors.accent(brightness)
                                  : Colors.black87,
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color: (product.onSale
                                          ? AppColors.accent(brightness)
                                          : Colors.black)
                                      .withValues(alpha: 0.25),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              product.onSale
                                  ? '-${product.discountPercentage}%'
                                  : 'out_of_stock'.tr(context),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),

                      // Frosted Glass Wishlist Heart (Top-End)
                      PositionedDirectional(
                        top: 8,
                        end: 8,
                        child: _FrostedWishlistHeart(
                          productId: product.id,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                ),

                // ─── Content Section (Dynamic Height, No Gaps) ───
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Product Title (2 lines max with safe line-height)
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              height: 1.25,
                            ),
                      ),
                      const SizedBox(height: 5),

                      // Rating Stars or "New ✨" Pill (Never empty!)
                      if (product.ratingAvg > 0)
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 13,
                              color: Color(0xFFFFB800),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              product.ratingAvg.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.foreground(
                                  brightness,
                                ).withValues(alpha: 0.8),
                              ),
                            ),
                            if (product.ratingCount > 0) ...[
                              const SizedBox(width: 2),
                              Text(
                                '(${product.ratingCount})',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.foreground(
                                    brightness,
                                  ).withValues(alpha: 0.4),
                                ),
                              ),
                            ],
                          ],
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondary(
                              brightness,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: AppColors.secondary(
                                brightness,
                              ).withValues(alpha: 0.25),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                size: 10.5,
                                color: AppColors.secondary(brightness),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                'New'.tr(context),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.secondary(brightness),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 6),

                      // Price Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '\$${product.displayPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: AppColors.secondary(brightness),
                              fontWeight: FontWeight.w800,
                              fontSize: 14.5,
                            ),
                          ),
                          if (product.onSale) ...[
                            const SizedBox(width: 5),
                            Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: AppColors.foreground(
                                  brightness,
                                ).withValues(alpha: 0.4),
                                fontSize: 11,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Action Button:
                      // If Admin: Sleek "Edit / تعديل" button
                      // If Customer: "+ أضف للسلة" or "غير متوفر"
                      if (widget.role == 'admin')
                        GestureDetector(
                          onTap: () => _openAdminEditSheet(context, product),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                vertical: 5.5, horizontal: 8),
                            decoration: BoxDecoration(
                              color: AppColors.primary(brightness)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.primary(brightness)
                                    .withValues(alpha: 0.35),
                                width: 0.9,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.edit_outlined,
                                  size: 13,
                                  color: AppColors.primary(brightness),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'Edit'.tr(context),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary(brightness),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else if (product.inStock)
                        _SleekAddToCartPill(product: product)
                      else
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.muted(
                              brightness,
                            ).withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              'out_of_stock'.tr(context),
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.foreground(
                                  brightness,
                                ).withValues(alpha: 0.4),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _placeholder(Brightness brightness) {
    return Container(
      color: AppColors.muted(brightness),
      child: Center(
        child: Icon(
          Icons.shopping_bag_outlined,
          size: 38,
          color: AppColors.foreground(brightness).withValues(alpha: 0.15),
        ),
      ),
    );
  }
}

/// Floating Frosted Glass Wishlist Heart with smooth scale-bounce animation.
class _FrostedWishlistHeart extends StatefulWidget {
  final String productId;
  final bool isDark;

  const _FrostedWishlistHeart({required this.productId, required this.isDark});

  @override
  State<_FrostedWishlistHeart> createState() => _FrostedWishlistHeartState();
}

class _FrostedWishlistHeartState extends State<_FrostedWishlistHeart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 280),
      vsync: this,
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return BlocBuilder<WishlistCubit, WishlistState>(
      builder: (context, state) {
        final isFav = state.isInWishlist(widget.productId);

        return ScaleTransition(
          scale: _scaleAnimation,
          child: GestureDetector(
            onTap: () {
              _controller.forward(from: 0);
              context.read<WishlistCubit>().toggleWishlist(widget.productId);
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: widget.isDark
                    ? Colors.black.withValues(alpha: 0.55)
                    : Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.35),
                  width: 0.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                isFav ? Icons.favorite : Icons.favorite_border,
                size: 16,
                color: isFav
                    ? AppColors.primary(brightness)
                    : (widget.isDark ? Colors.white70 : Colors.black87),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Concept 2: Sleek Quick-Add Pill "+ أضف للسلة" (`+ Add to Cart`).
class _SleekAddToCartPill extends StatefulWidget {
  final ProductModel product;
  const _SleekAddToCartPill({required this.product});

  @override
  State<_SleekAddToCartPill> createState() => _SleekAddToCartPillState();
}

class _SleekAddToCartPillState extends State<_SleekAddToCartPill>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 240),
      vsync: this,
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.94), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0.94, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTap: () {
          _controller.forward(from: 0);
          context.read<CartCubit>().addToCart(widget.product.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${'add_to_cart'.tr(context)} ✨'),
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 80),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 5.5, horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.secondary(brightness).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.secondary(brightness).withValues(alpha: 0.25),
              width: 0.9,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_bag_outlined,
                size: 13,
                color: AppColors.secondary(brightness),
              ),
              const SizedBox(width: 5),
              Text(
                'add_to_cart'.tr(context),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondary(brightness),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
