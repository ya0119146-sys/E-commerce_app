import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/star_rating.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../wishlist/logic/wishlist_cubit.dart';
import '../../../cart/logic/cart_cubit.dart';
import '../../data/models/product_model.dart';
import '../product_detail_screen.dart';

/// Product Card matching the Labella design:
/// Image (4:5), badges, heart, shopping bag, title, rating, price.
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

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
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
                borderRadius: BorderRadius.circular(
                  AppDimensions.radiusDefault,
                ),
                border: Border.all(
                  color: AppColors.border(brightness).withValues(alpha: 0.4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary(
                      brightness,
                    ).withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Image Section ───
                  Expanded(
                    flex: 5,
                    child: Stack(
                      children: [
                        // Product image
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(AppDimensions.radiusDefault),
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            child: product.cover != null
                                ? CachedNetworkImage(
                                    imageUrl: product.cover!,
                                    fit: BoxFit.cover,
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

                        // Sale / Out of Stock badge
                        if (product.onSale || !product.inStock)
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: product.onSale
                                    ? AppColors.accent(brightness)
                                    : AppColors.secondary(brightness),
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusSm,
                                ),
                              ),
                              child: Text(
                                product.onSale
                                    ? '-${product.discountPercent.toStringAsFixed(0)}%'
                                    : 'Out of Stock',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),

                        // Heart (Wishlist) button
                        Positioned(
                          top: 8,
                          right: 8,
                          child: _WishlistHeart(productId: product.id),
                        ),

                        // Shopping bag (Add to Cart) button
                        if (product.inStock && widget.role != 'admin')
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: _AddToCartButton(product: product),
                          ),
                      ],
                    ),
                  ),

                  // ─── Content Section ───
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontSize: 13, height: 1.3),
                          ),
                          const SizedBox(height: 4),
                          if (product.ratingAvg > 0)
                            StarRating(rating: product.ratingAvg, size: 13),
                          const Spacer(),
                          Row(
                            children: [
                              Text(
                                '\$${product.displayPrice.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: AppColors.secondary(brightness),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                              if (product.onSale) ...[
                                const SizedBox(width: 6),
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
          duration: 400.ms,
          delay: Duration(milliseconds: 80 * widget.index),
        )
        .moveY(
          begin: 20,
          end: 0,
          duration: 400.ms,
          delay: Duration(milliseconds: 80 * widget.index),
        );
  }

  Widget _placeholder(Brightness brightness) {
    return Container(
      color: AppColors.muted(brightness),
      child: Center(
        child: Icon(
          Icons.shopping_bag_outlined,
          size: 40,
          color: AppColors.foreground(brightness).withValues(alpha: 0.15),
        ),
      ),
    );
  }
}

/// Animated wishlist heart button with scale-bounce.
class _WishlistHeart extends StatefulWidget {
  final String productId;
  const _WishlistHeart({required this.productId});

  @override
  State<_WishlistHeart> createState() => _WishlistHeartState();
}

class _WishlistHeartState extends State<_WishlistHeart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.4), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 1.0), weight: 50),
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
                color: AppColors.card(brightness).withValues(alpha: 0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Icon(
                isFav ? Icons.favorite : Icons.favorite_border,
                size: 16,
                color: isFav
                    ? AppColors.primary(brightness)
                    : AppColors.foreground(brightness).withValues(alpha: 0.5),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Animated add-to-cart button with pulse.
class _AddToCartButton extends StatefulWidget {
  final ProductModel product;
  const _AddToCartButton({required this.product});

  @override
  State<_AddToCartButton> createState() => _AddToCartButtonState();
}

class _AddToCartButtonState extends State<_AddToCartButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
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
          if (widget.product.inStock) {
            _controller.forward(from: 0);
            context.read<CartCubit>().addToCart(widget.product.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Added to cart ✨'),
                duration: const Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 80),
              ),
            );
          }
        },
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: widget.product.inStock
                ? AppColors.secondary(brightness)
                : AppColors.muted(brightness),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary(brightness).withValues(alpha: 0.3),
                blurRadius: 8,
              ),
            ],
          ),
          child: Icon(
            Icons.shopping_bag_outlined,
            size: 15,
            color: widget.product.inStock
                ? Colors.white
                : AppColors.foreground(brightness).withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }
}
