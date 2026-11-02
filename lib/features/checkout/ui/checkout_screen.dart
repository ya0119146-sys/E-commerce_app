import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/localization/app_translations.dart';
import '../../../core/widgets/hero_button.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../cart/logic/cart_cubit.dart';
import '../logic/checkout_cubit.dart';
import 'order_success_screen.dart';

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

  void _showAddAddressSheet() {
    final streetC = TextEditingController();
    final cityC = TextEditingController();
    final stateC = TextEditingController();
    final zipC = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXl),
        ),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          24,
          20,
          MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add Address'.tr(ctx), style: Theme.of(ctx).textTheme.headlineSmall),
              const SizedBox(height: 20),
              TextFormField(
                controller: streetC,
                decoration: InputDecoration(labelText: 'Street'.tr(ctx)),
                validator: (v) => v == null || v.isEmpty ? 'Required'.tr(ctx) : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: cityC,
                      decoration: InputDecoration(labelText: 'City'.tr(ctx)),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required'.tr(ctx) : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: stateC,
                      decoration: InputDecoration(labelText: 'State'.tr(ctx)),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required'.tr(ctx) : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: zipC,
                decoration: InputDecoration(labelText: 'ZIP Code'.tr(ctx)),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Required'.tr(ctx) : null,
              ),
              const SizedBox(height: 20),
              HeroButton(
                text: 'Save Address'.tr(ctx),
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    context.read<CheckoutCubit>().addAddress(
                      streetC.text.trim(),
                      cityC.text.trim(),
                      stateC.text.trim(),
                      zipC.text.trim(),
                    );
                    Navigator.pop(ctx);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
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
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!.tr(context))));
          }
        },
        builder: (context, state) {
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
                            onPressed: _showAddAddressSheet,
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
              // Bottom confirm
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                decoration: BoxDecoration(
                  color: AppColors.card(brightness),
                  border: Border(
                    top: BorderSide(
                      color: AppColors.border(
                        brightness,
                      ).withValues(alpha: 0.5),
                    ),
                  ),
                ),
                child: HeroButton(
                  text: 'Confirm Order'.tr(context),
                  icon: Icons.check_circle_outline,
                  isLoading: state.status == CheckoutStatus.placingOrder,
                  onPressed: state.selectedAddressId != null
                      ? () => context.read<CheckoutCubit>().placeOrder()
                      : null,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
