import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/egypt_governorates.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/widgets/hero_button.dart';
import '../../logic/checkout_cubit.dart';

/// Opens a bottom sheet form to add a new delivery address during checkout.
void showCheckoutAddAddressSheet(BuildContext context) {
  final streetC = TextEditingController();
  final cityC = TextEditingController();
  final zipC = TextEditingController();
  String selectedGov = EgyptGovernorates.sharqia;
  final formKey = GlobalKey<FormState>();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppDimensions.radiusXl),
      ),
    ),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheetState) => Padding(
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
              Text(
                'Add Address'.tr(ctx),
                style: Theme.of(ctx).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedGov,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Governorate'.tr(ctx),
                  prefixIcon: const Icon(
                    Icons.location_city_outlined,
                    size: 20,
                  ),
                ),
                items: EgyptGovernorates.governorates.map((gov) {
                  final isFree = EgyptGovernorates.isSharqia(gov);
                  return DropdownMenuItem<String>(
                    value: gov,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            gov,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        if (isFree)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Free Delivery'.tr(ctx),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setSheetState(() => selectedGov = val);
                  }
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: cityC,
                decoration: InputDecoration(
                  labelText: 'City'.tr(ctx),
                  prefixIcon: const Icon(Icons.apartment_outlined, size: 20),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Required'.tr(ctx) : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: streetC,
                decoration: InputDecoration(
                  labelText: 'Street'.tr(ctx),
                  prefixIcon: const Icon(Icons.signpost_outlined, size: 20),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Required'.tr(ctx) : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: zipC,
                decoration: InputDecoration(
                  labelText: 'ZIP Code'.tr(ctx),
                  prefixIcon: const Icon(Icons.pin_outlined, size: 20),
                ),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Required'.tr(ctx) : null,
              ),
              const SizedBox(height: 20),
              HeroButton(
                text: 'Save Address'.tr(ctx),
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    context.read<CheckoutCubit>().addAddress(
                      streetC.text.trim(),
                      cityC.text.trim(),
                      selectedGov,
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
    ),
  );
}
