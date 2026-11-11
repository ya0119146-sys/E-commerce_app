import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/egypt_governorates.dart';
import '../../../core/localization/app_translations.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../cart/logic/cart_cubit.dart';
import '../data/models/address_model.dart';
import '../logic/checkout_cubit.dart';
import 'order_success_screen.dart';
import 'widgets/checkout_add_address_sheet.dart';
import 'widgets/checkout_summary_bar.dart';

/// Checkout screen — address selection/addition and order confirmation.
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CheckoutCubit>().fetchAddresses();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      appBar: AppBar(title: Text('Checkout'.tr(context))),
      body: BlocConsumer<CheckoutCubit, CheckoutState>(
        listener: (context, state) {
          if (state.status == CheckoutStatus.orderPlaced) {
            // Backend deletes the cart upon order creation; reset cart state immediately
            context.read<CartCubit>().resetCart();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => OrderSuccessScreen(order: state.lastOrder!),
              ),
            );
          }
          if (state.status == CheckoutStatus.error &&
              state.errorMessage != null) {
            CustomSnackBar.showError(context, state.errorMessage!.tr(context));
          }
        },
        builder: (context, state) {
          final selectedAddress = state.addresses
              .cast<AddressModel?>()
              .firstWhere(
                (a) => a?.id == state.selectedAddressId,
                orElse: () => null,
              );
          final cart = context.watch<CartCubit>().state.cart;
          final double subtotal = cart.totalPrice;
          final bool hasAddress = selectedAddress != null;
          final bool isSharqia =
              hasAddress && EgyptGovernorates.isSharqia(selectedAddress.state);
          final double shippingFee = hasAddress
              ? EgyptGovernorates.getShippingFee(selectedAddress.state)
              : 0.0;
          final double finalTotal = subtotal + (hasAddress ? shippingFee : 0.0);

          if (state.status == CheckoutStatus.loading &&
              state.addresses.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(AppDimensions.screenPadding),
              child: Column(
                children: List.generate(
                  3,
                  (_) => const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: ShimmerLoading(
                      width: double.infinity,
                      height: 80,
                      borderRadius: AppDimensions.radiusDefault,
                    ),
                  ),
                ),
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppDimensions.screenPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Shipping Address'.tr(context),
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          TextButton.icon(
                            onPressed: () =>
                                showCheckoutAddAddressSheet(context),
                            icon: const Icon(Icons.add, size: 18),
                            label: Text('Add New'.tr(context)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (state.addresses.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(24),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.muted(brightness),
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusDefault,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.location_off_outlined,
                                size: 40,
                                color: AppColors.foreground(
                                  brightness,
                                ).withValues(alpha: 0.3),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No addresses saved'.tr(context),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        )
                      else
                        ...state.addresses.asMap().entries.map((entry) {
                          final i = entry.key;
                          final addr = entry.value;
                          final isSelected = state.selectedAddressId == addr.id;
                          return GestureDetector(
                                onTap: () => context
                                    .read<CheckoutCubit>()
                                    .selectAddress(addr.id),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.card(brightness),
                                    borderRadius: BorderRadius.circular(
                                      AppDimensions.radiusDefault,
                                    ),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary(brightness)
                                          : AppColors.border(brightness),
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isSelected
                                            ? Icons.radio_button_checked
                                            : Icons.radio_button_off,
                                        color: isSelected
                                            ? AppColors.primary(brightness)
                                            : AppColors.foreground(
                                                brightness,
                                              ).withValues(alpha: 0.3),
                                        size: 22,
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Text(
                                          addr.displayAddress,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .animate()
                              .fade(
                                duration: 300.ms,
                                delay: Duration(milliseconds: 80 * i),
                              )
                              .moveY(
                                begin: 15,
                                end: 0,
                                duration: 300.ms,
                                delay: Duration(milliseconds: 80 * i),
                              );
                        }),
                    ],
                  ),
                ),
              ),
              CheckoutSummaryBar(
                subtotal: subtotal,
                hasAddress: hasAddress,
                isSharqia: isSharqia,
                shippingFee: shippingFee,
                finalTotal: finalTotal,
                state: state,
              ),
            ],
          );
        },
      ),
    );
  }
}
