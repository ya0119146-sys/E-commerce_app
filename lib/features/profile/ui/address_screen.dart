import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../../core/constants/egypt_governorates.dart';
import '../../../core/localization/app_translations.dart';
import '../../checkout/logic/checkout_cubit.dart';
import '../../checkout/data/models/address_model.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CheckoutCubit>().fetchAddresses();
  }

  void _showAddAddressDialog() {
    final streetController = TextEditingController();
    final cityController = TextEditingController();
    final zipController = TextEditingController();
    String selectedGovernorate = EgyptGovernorates.sharqia;
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Add New Address'.tr(context),
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedGovernorate,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Governorate'.tr(context),
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
                                'Free Delivery'.tr(context),
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
                      setDialogState(() => selectedGovernorate = val);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: cityController,
                  decoration: InputDecoration(
                    labelText: 'City'.tr(context),
                    prefixIcon: const Icon(Icons.apartment_outlined, size: 20),
                  ),
                  validator: (v) => v!.isEmpty ? 'Required'.tr(context) : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: streetController,
                  decoration: InputDecoration(
                    labelText: 'Street Address'.tr(context),
                    prefixIcon: const Icon(Icons.signpost_outlined, size: 20),
                  ),
                  validator: (v) => v!.isEmpty ? 'Required'.tr(context) : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: zipController,
                  decoration: InputDecoration(
                    labelText: 'Zip Code'.tr(context),
                    prefixIcon: const Icon(Icons.pin_outlined, size: 20),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Required'.tr(context) : null,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      context.read<CheckoutCubit>().addAddress(
                        streetController.text.trim(),
                        cityController.text.trim(),
                        selectedGovernorate,
                        zipController.text.trim(),
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Save Address'.tr(context)),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      appBar: AppBar(title: Text('My Addresses'.tr(context))),
      body: BlocConsumer<CheckoutCubit, CheckoutState>(
        listener: (context, state) {
          if (state.status == CheckoutStatus.error &&
              state.errorMessage != null) {
            CustomSnackBar.showError(context, state.errorMessage!.tr(context));
          }
        },
        builder: (context, state) {
          if (state.status == CheckoutStatus.loading &&
              state.addresses.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.addresses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_off_outlined,
                    size: 64,
                    color: AppColors.muted(brightness),
                  ),
                  const SizedBox(height: 16),
                  Text('No addresses saved yet'.tr(context)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _showAddAddressDialog,
                    icon: const Icon(Icons.add),
                    label: Text('Add First Address'.tr(context)),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppDimensions.screenPadding),
            itemCount: state.addresses.length,
            itemBuilder: (context, index) {
              final address = state.addresses[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.only(left: 16, right: 8),
                  leading: const CircleAvatar(
                    child: Icon(Icons.location_on_outlined),
                  ),
                  title: Text(address.street),
                  subtitle: Text(
                    '${address.city}, ${address.state} ${address.zip}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppColors.error,
                    ),
                    onPressed: () {
                      _showDeleteConfirmation(context, address);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAddressDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, AddressModel address) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Address'.tr(context)),
        content: Text(
          'Are you sure you want to remove this address?'.tr(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'.tr(context)),
          ),
          TextButton(
            onPressed: () {
              this.context.read<CheckoutCubit>().removeAddress(address.id);
              Navigator.pop(context);
            },
            child: Text(
              'Delete'.tr(context),
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
