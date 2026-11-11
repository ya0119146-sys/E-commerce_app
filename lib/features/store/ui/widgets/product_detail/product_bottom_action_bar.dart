import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_gradients.dart';
import '../../../../../core/localization/app_translations.dart';
import '../../../../../core/utils/auth_guard.dart';
import '../../../../../core/widgets/custom_snackbar.dart';
import '../../../../../core/widgets/hero_button.dart';
import '../../../../admin/logic/admin_cubit.dart';
import '../../../../admin/ui/widgets/product_form.dart';
import '../../../../cart/data/models/cart_model.dart';
import '../../../../cart/logic/cart_cubit.dart';
import '../../../../cart/ui/cart_screen.dart';
import '../../../data/models/product_model.dart';
import '../../../logic/categories_cubit.dart';
import '../../../logic/products_cubit.dart';

/// Bottom action bar for ProductDetailScreen supporting:
/// - Customer / Guest: Add to Cart <-> Pattern 2 in-place quantity stepper + Checkout CTA.
/// - Admin: Edit Product modal sheet trigger.
class ProductBottomActionBar extends StatelessWidget {
  final ProductModel product;
  final String role;

  const ProductBottomActionBar({
    super.key,
    required this.product,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    if (role == 'admin') {
      return Container(
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
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (_) => ProductForm(
                product: product,
                categories: context.read<CategoriesCubit>().state.categories,
                subcategories: const [],
                onSubmit: (data) async {
                  await context.read<AdminCubit>().updateProduct(
                    product.id,
                    data,
                  );
                  if (context.mounted) {
                    context.read<ProductsCubit>().fetchProducts(refresh: true);
                    Navigator.pop(context);
                  }
                },
              ),
            );
          },
        ),
      );
    }

    return BlocBuilder<CartCubit, CartState>(
      builder: (context, cartState) {
        CartItemModel? cartItem;
        for (final item in cartState.cart.items) {
          if (item.productId == product.id || item.product?.id == product.id) {
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
                color: AppColors.border(brightness).withValues(alpha: 0.5),
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
                    quantity: quantityInCart,
                  )
                : _buildAddToCartBottomBar(context),
          ),
        );
      },
    );
  }

  Widget _buildAddToCartBottomBar(BuildContext context) {
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
    required int quantity,
  }) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return KeyedSubtree(
      key: const ValueKey('in_cart_stepper_state'),
      child: SizedBox(
        height: 52,
        child: Row(
          children: [
            // 1. In-Place Luxury Quantity Stepper Pill
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
                  _buildStepperButton(
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
                  _buildStepperButton(
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

            // 2. Checkout Button
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CartScreen(role: role)),
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

  Widget _buildStepperButton({
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
