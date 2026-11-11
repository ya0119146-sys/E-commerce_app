import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../auth/logic/auth_cubit.dart';
import '../../logic/cart_cubit.dart';
import '../widgets/cart_checkout_bar.dart';
import '../widgets/cart_empty_views.dart';
import '../widgets/cart_item_card.dart';

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
    if (context.read<AuthCubit>().isAuthenticated) {
      context.read<CartCubit>().fetchCart();
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      appBar: AppBar(
        title: Text('My Cart'.tr(context)),
        actions: [
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, authState) {
              if (!authState.isAuthenticated) return const SizedBox.shrink();
              return BlocBuilder<CartCubit, CartState>(
                builder: (context, state) {
                  if (state.cart.items.isEmpty) return const SizedBox.shrink();
                  return TextButton(
                    onPressed: () => _showClearCartDialog(context),
                    child: Text(
                      'Clear All'.tr(context),
                      style: const TextStyle(color: AppColors.error),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, authState) {
          if (!authState.isAuthenticated) {
            return CartGuestView(role: widget.role);
          }

          return BlocListener<CartCubit, CartState>(
            listenWhen: (prev, curr) =>
                prev.errorMessage != curr.errorMessage &&
                curr.errorMessage != null,
            listener: (context, state) {
              CustomSnackBar.showError(
                context,
                state.errorMessage!.tr(context),
              );
            },
            child: BlocBuilder<CartCubit, CartState>(
              builder: (context, state) {
                if (state.status == CartStatus.loading &&
                    state.cart.items.isEmpty) {
                  return const CartLoadingList();
                }

                if (state.cart.items.isEmpty) {
                  return CartEmptyView(role: widget.role);
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
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = state.cart.items[index];
                            return CartItemCard(item: item, index: index);
                          },
                        ),
                      ),
                    ),
                    CartCheckoutBar(state: state),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear Cart?'.tr(context)),
        content: Text('Are you sure you want to remove all items?'.tr(context)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr(context)),
          ),
          TextButton(
            onPressed: () {
              context.read<CartCubit>().clearCart();
              Navigator.pop(context);
            },
            child: Text(
              'Clear All'.tr(context),
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
