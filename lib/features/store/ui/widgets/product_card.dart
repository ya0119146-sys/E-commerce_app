import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../wishlist/logic/wishlist_cubit.dart';
import '../../../cart/logic/cart_cubit.dart';
import '../../data/models/product_model.dart';
import '../product_detail_screen.dart';
import '../../../../core/localization/app_translations.dart';

/// Concept 2: Minimalist High-Fashion / Luxury Farfetch & Zara Style Product Card.
/// 4:5 squircle image, floating frosted-glass wishlist heart, brand tag,
/// Arabic title, star rating, price with discount tag and strike-through original price,
/// and sleek "+ أضف للسلة" button.
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

  String get _displayCategory {
    final cat = widget.product.category?.trim();
    if (cat == null || cat.isEmpty) return 'LABELLA';
    // If it's a 24-character hexadecimal MongoDB ObjectId, hide it and use brand fallback
    if (RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(cat)) return 'LABELLA';
    return cat.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final product = widget.product;

    return GestureDetector(
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
            children: [
              // ─── 4:5 Image Section with Frosted Glass Wishlist & Sale Badge ───
              Expanded(
                flex: 10,
                child: Stack(
                  children: [
                    // Product image
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(15),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: product.cover != null && product.cover!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: product.cover!,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => const ShimmerLoading(
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
                        top: 9,
                        start: 9,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3.5,
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
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),

                    // Frosted Glass Wishlist Heart (Top-End)
                    PositionedDirectional(
                      top: 9,
                      end: 9,
                      child: _FrostedWishlistHeart(
                        productId: product.id,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
              ),

              // ─── Content Section (Editorial / High-Fashion Typography) ───
              Expanded(
                flex: 9,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Brand / Category Tag
                          Text(
                            _displayCategory,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 9.5,
                              letterSpacing: 1.0,
                              fontWeight: FontWeight.w600,
                              color: AppColors.foreground(brightness)
                                  .withValues(alpha: 0.45),
                            ),
                          ),
                          const SizedBox(height: 2),

                          // Product Title (2 lines max)
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
                          const SizedBox(height: 3),

                          // Rating Stars / Count
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
                                    color: AppColors.foreground(brightness)
                                        .withValues(alpha: 0.8),
                                  ),
                                ),
                                if (product.ratingCount > 0) ...[
                                  const SizedBox(width: 2),
                                  Text(
                                    '(${product.ratingCount})',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.foreground(brightness)
                                          .withValues(alpha: 0.4),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                        ],
                      ),

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
                                color: AppColors.foreground(brightness)
                                    .withValues(alpha: 0.4),
                                fontSize: 11,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ],
                      ),

                      // Sleek "+ أضف للسلة" Action Button
                      if (widget.role != 'admin' && product.inStock)
                        _SleekAddToCartPill(product: product)
                      else if (!product.inStock)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.muted(brightness).withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              'out_of_stock'.tr(context),
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.foreground(brightness)
                                    .withValues(alpha: 0.4),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fade(
          duration: 350.ms,
          delay: Duration(milliseconds: 60 * widget.index),
        )
        .moveY(
          begin: 16,
          end: 0,
          duration: 350.ms,
          delay: Duration(milliseconds: 60 * widget.index),
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

  const _FrostedWishlistHeart({
    required this.productId,
    required this.isDark,
  });

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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: widget.isDark
                        ? Colors.black.withValues(alpha: 0.45)
                        : Colors.white.withValues(alpha: 0.8),
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
