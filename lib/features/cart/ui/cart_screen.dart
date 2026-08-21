import 'package:e_commerce/features/store/ui/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/hero_button.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../checkout/ui/checkout_screen.dart';
import '../data/models/cart_model.dart';
import '../logic/cart_cubit.dart';

/// Cart screen showing all cart items with quantity controls.
class CartScreen extends StatefulWidget {
  const CartScreen({super.key, required this.role});
  final String role;
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CartCubit>().fetchCart();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        actions: [
          BlocBuilder<CartCubit, CartState>(
            builder: (context, state) {
              if (state.cart.items.isEmpty) return const SizedBox.shrink();
              return TextButton(
                onPressed: () => _showClearCartDialog(context),
                child: Text(
                  'Clear All',
                  style: TextStyle(color: AppColors.error),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocListener<CartCubit, CartState>(
        listenWhen: (prev, curr) =>
            prev.errorMessage != curr.errorMessage && curr.errorMessage != null,
        listener: (context, state) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        },
        child: BlocBuilder<CartCubit, CartState>(
          builder: (context, state) {
            if (state.status == CartStatus.loading &&
                state.cart.items.isEmpty) {
              return _buildLoadingList();
            }

            if (state.cart.items.isEmpty) {
              return _buildEmptyState(context, brightness);
            }

            return Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => context.read<CartCubit>().fetchCart(),
                    color: AppColors.primary(brightness),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(
                        AppDimensions.screenPadding,
                      ),
                      itemCount: state.cart.items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = state.cart.items[index];
                        return _CartItemCard(item: item, index: index);
                      },
                    ),
                  ),
                ),
                // ─── Bottom Total & Checkout ───
                _buildCheckoutBar(context, state, brightness),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingList() {
    return ListView.separated(
      padding: const EdgeInsets.all(AppDimensions.screenPadding),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (_, __) =>
          const ShimmerLoading(width: double.infinity, height: 100),
    );
  }

  Widget _buildEmptyState(BuildContext context, Brightness brightness) {
    return Center(
      child:
          Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.primary(
                        brightness,
                      ).withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.shopping_cart_outlined,
                      size: 80,
                      color: AppColors.primary(
                        brightness,
                      ).withValues(alpha: 0.3),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Your cart is empty',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Add some items to get started',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.foreground(
                        brightness,
                      ).withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: HeroButton(
                      text: 'Start Shopping',
                      icon: Icons.shopping_bag_outlined,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HomeScreen(role: widget.role),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              )
              .animate()
              .fade(duration: 500.ms)
              .scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOutBack),
    );
  }

  Widget _buildCheckoutBar(
    BuildContext context,
    CartState state,
    Brightness brightness,
  ) {
    const double tax = 25.0;
    final double subtotal = state.cart.totalPrice;
    final double total = subtotal + tax;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      decoration: BoxDecoration(
        color: AppColors.card(brightness),
        border: Border(
          top: BorderSide(
            color: AppColors.border(brightness).withValues(alpha: 0.5),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.foreground(
                    brightness,
                  ).withValues(alpha: 0.6),
                ),
              ),
              Text(
                '\$${subtotal.toStringAsFixed(2)}',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Shipping & Tax',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.foreground(
                    brightness,
                  ).withValues(alpha: 0.6),
                ),
              ),
              Text(
                '\$${tax.toStringAsFixed(2)}',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: Theme.of(context).textTheme.titleLarge),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondary(brightness),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          HeroButton(
            text: 'Proceed to Checkout',
            icon: Icons.arrow_forward_rounded,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CheckoutScreen()),
              );
            },
          ),
        ],
      ),
    ).animate().moveY(
      begin: 100,
      end: 0,
      duration: 400.ms,
      curve: Curves.easeOut,
    );
  }

  void _showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cart?'),
        content: const Text('Are you sure you want to remove all items?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<CartCubit>().clearCart();
              Navigator.pop(context);
            },
            child: const Text(
              'Clear All',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual cart item card with quantity controls.
class _CartItemCard extends StatelessWidget {
  final CartItemModel item;
  final int index;

  const _CartItemCard({required this.item, required this.index});

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

                              // Quantity controls
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
                                      context,
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
                                      context,
                                      icon: Icons.add,
                                      onTap: () {
                                        if (product != null &&
                                            item.quantity < product.quantity) {
                                          context
                                              .read<CartCubit>()
                                              .updateQuantity(
                                                item.productId,
                                                item.quantity + 1,
                                              );
                                        } else {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Reached maximum stock',
                                              ),
                                              duration: Duration(seconds: 1),
                                            ),
                                          );
                                        }
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

  Widget _qtyButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        color: Colors.transparent, // Increase tap area
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
