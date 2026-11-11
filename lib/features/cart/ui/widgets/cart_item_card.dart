import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../data/models/cart_model.dart';
import '../../logic/cart_cubit.dart';

/// Individual cart item card with swipe-to-remove and quantity controls.
class CartItemCard extends StatelessWidget {
  final CartItemModel item;
  final int index;

  const CartItemCard({super.key, required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final product = item.product;

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) =>
          context.read<CartCubit>().removeFromCart(item.productId),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusDefault),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.error),
      ),
      child:
          Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.card(brightness),
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusDefault,
                  ),
                  border: Border.all(
                    color: AppColors.border(brightness).withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ─── Image ───
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMd,
                      ),
                      child: SizedBox(
                        width: 76,
                        height: 76,
                        child: product?.cover != null
                            ? CachedNetworkImage(
                                imageUrl: product!.cover!,
                                fit: BoxFit.cover,
                                placeholder: (_, __) =>
                                    const ShimmerLoading(width: 76, height: 76),
                                errorWidget: (_, __, ___) =>
                                    _imagePlaceholder(brightness),
                              )
                            : _imagePlaceholder(brightness),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // ─── Info ───
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name + Delete button
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  product?.name ?? 'Product',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => context
                                    .read<CartCubit>()
                                    .removeFromCart(item.productId),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: Icon(
                                    Icons.close_rounded,
                                    size: 18,
                                    color: AppColors.foreground(
                                      brightness,
                                    ).withValues(alpha: 0.35),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // Price + Quantity controls
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '\$${item.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.foreground(brightness),
                                ),
                              ),
                              Container(
                                height: 32,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColors.border(
                                      brightness,
                                    ).withValues(alpha: 0.5),
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusMd,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _qtyButton(
                                      icon: Icons.remove,
                                      onTap: () {
                                        if (item.quantity > 1) {
                                          context
                                              .read<CartCubit>()
                                              .updateQuantity(
                                                item.productId,
                                                item.quantity - 1,
                                              );
                                        }
                                      },
                                    ),
                                    Container(
                                      width: 32,
                                      decoration: BoxDecoration(
                                        border: Border.symmetric(
                                          vertical: BorderSide(
                                            color: AppColors.border(
                                              brightness,
                                            ).withValues(alpha: 0.5),
                                          ),
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '${item.quantity}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ),
                                    _qtyButton(
                                      icon: Icons.add,
                                      onTap: () {
                                        final maxStock = product?.quantity ?? 0;
                                        if (maxStock > 0 &&
                                            item.quantity >= maxStock) {
                                          CustomSnackBar.show(
                                            context,
                                            message: context.isArabic
                                                ? 'وصلت للحد الأقصى ($maxStock)'
                                                : 'Reached maximum stock ($maxStock)',
                                            type: SnackBarType.warning,
                                          );
                                          return;
                                        }
                                        context
                                            .read<CartCubit>()
                                            .updateQuantity(
                                              item.productId,
                                              item.quantity + 1,
                                            );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fade(
                duration: 350.ms,
                delay: Duration(milliseconds: 60 * index),
              )
              .moveX(
                begin: 30,
                end: 0,
                duration: 350.ms,
                delay: Duration(milliseconds: 60 * index),
              ),
    );
  }

  Widget _qtyButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        color: Colors.transparent,
        child: Icon(icon, size: 16),
      ),
    );
  }

  Widget _imagePlaceholder(Brightness brightness) {
    return Container(
      color: AppColors.muted(brightness),
      child: Icon(
        Icons.shopping_bag_outlined,
        color: AppColors.foreground(brightness).withValues(alpha: 0.15),
      ),
    );
  }
}
