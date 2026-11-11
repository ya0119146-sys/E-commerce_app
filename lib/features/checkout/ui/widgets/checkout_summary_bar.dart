import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/widgets/hero_button.dart';
import '../../logic/checkout_cubit.dart';

/// Bottom summary container showing subtotal, governorate shipping policy, total, and Confirm Order CTA.
class CheckoutSummaryBar extends StatelessWidget {
  final double subtotal;
  final bool hasAddress;
  final bool isSharqia;
  final double shippingFee;
  final double finalTotal;
  final CheckoutState state;

  const CheckoutSummaryBar({
    super.key,
    required this.subtotal,
    required this.hasAddress,
    required this.isSharqia,
    required this.shippingFee,
    required this.finalTotal,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      decoration: BoxDecoration(
        color: AppColors.card(brightness),
        border: Border(
          top: BorderSide(
            color: AppColors.border(brightness).withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal'.tr(context),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                '\$${subtotal.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'delivery_fee'.tr(context),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (!hasAddress)
                Text(
                  context.isArabic
                      ? 'اختر عنواناً لحساب الشحن'
                      : 'Select address',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.foreground(
                      brightness,
                    ).withValues(alpha: 0.5),
                  ),
                )
              else if (isSharqia)
                Row(
                  children: [
                    Text(
                      context.isArabic
                          ? 'مجاني (محافظة الشرقية)'
                          : 'Free (Sharqia)',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 16,
                    ),
                  ],
                )
              else
                Text(
                  '\$${shippingFee.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
            ],
          ),
          const Divider(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total'.tr(context),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                '\$${finalTotal.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary(brightness),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          HeroButton(
            text: 'Confirm Order'.tr(context),
            icon: Icons.check_circle_outline,
            isLoading: state.status == CheckoutStatus.placingOrder,
            onPressed: state.selectedAddressId != null
                ? () => context.read<CheckoutCubit>().placeOrder()
                : null,
          ),
        ],
      ),
    );
  }
}
