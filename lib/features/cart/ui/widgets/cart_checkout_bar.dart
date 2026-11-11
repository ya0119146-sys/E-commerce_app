import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/utils/auth_guard.dart';
import '../../../../core/widgets/hero_button.dart';
import '../../../checkout/ui/checkout_screen.dart';
import '../../logic/cart_cubit.dart';

/// Bottom summary and checkout action bar for CartScreen.
class CartCheckoutBar extends StatelessWidget {
  final CartState state;

  const CartCheckoutBar({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final double subtotal = state.cart.totalPrice;
    final double total = subtotal;

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
                'Subtotal'.tr(context),
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
                'delivery_fee'.tr(context),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.foreground(
                    brightness,
                  ).withValues(alpha: 0.6),
                ),
              ),
              Text(
                'Calculated at checkout'.tr(context),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary(brightness),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary(brightness).withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.local_shipping_outlined,
                  size: 16,
                  color: AppColors.primary(brightness),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Shipping Policy Note'.tr(context),
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.primary(brightness),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total'.tr(context),
                style: Theme.of(context).textTheme.titleLarge,
              ),
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
            text: 'checkout'.tr(context),
            icon: Icons.arrow_forward_rounded,
            onPressed: () {
              AuthGuard.requireAuth(
                context,
                action: AuthActionType.checkout,
                onAuthenticated: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                  );
                },
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
}
