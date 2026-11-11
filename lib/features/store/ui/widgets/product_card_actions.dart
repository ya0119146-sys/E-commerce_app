import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/utils/auth_guard.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../cart/logic/cart_cubit.dart';
import '../../../wishlist/logic/wishlist_cubit.dart';
import '../../data/models/product_model.dart';

/// Floating Frosted Glass Wishlist Heart with smooth scale-bounce animation.
class FrostedWishlistHeart extends StatefulWidget {
  final ProductModel product;
  final bool isDark;

  const FrostedWishlistHeart({
    super.key,
    required this.product,
    required this.isDark,
  });

  @override
  State<FrostedWishlistHeart> createState() => _FrostedWishlistHeartState();
}

class _FrostedWishlistHeartState extends State<FrostedWishlistHeart>
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
      // Only rebuild when THIS product's wishlist status changes.
      buildWhen: (prev, next) =>
          prev.isInWishlist(widget.product.id) !=
          next.isInWishlist(widget.product.id),
      builder: (context, state) {
        final isFav = state.isInWishlist(widget.product.id);

        return ScaleTransition(
          scale: _scaleAnimation,
          child: GestureDetector(
            onTap: () {
              AuthGuard.requireAuth(
                context,
                action: AuthActionType.wishlist,
                onAuthenticated: () {
                  _controller.forward(from: 0);
                  context.read<WishlistCubit>().toggleWishlist(
                    widget.product.id,
                    widget.product,
                  );
                },
              );
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

/// Concept 2: Sleek Quick-Add Pill `+ Add to Cart`.
class SleekAddToCartPill extends StatefulWidget {
  final ProductModel product;
  const SleekAddToCartPill({super.key, required this.product});

  @override
  State<SleekAddToCartPill> createState() => _SleekAddToCartPillState();
}

class _SleekAddToCartPillState extends State<SleekAddToCartPill>
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
          AuthGuard.requireAuth(
            context,
            action: AuthActionType.cart,
            onAuthenticated: () {
              _controller.forward(from: 0);
              context.read<CartCubit>().addToCart(widget.product.id);
              CustomSnackBar.showCart(
                context,
                '${'add_to_cart'.tr(context)} ✨',
              );
            },
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8),
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
                  fontSize: 10.5,
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
