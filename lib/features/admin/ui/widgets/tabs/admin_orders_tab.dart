import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/localization/app_translations.dart';
import '../../../../checkout/logic/checkout_cubit.dart';
import '../../../../checkout/ui/order_detail_screen.dart';

/// Admin orders management tab.
class AdminOrdersTab extends StatelessWidget {
  final VoidCallback onStatusUpdate;

  const AdminOrdersTab({super.key, required this.onStatusUpdate});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return BlocBuilder<CheckoutCubit, CheckoutState>(
      builder: (context, state) {
        if (state.ordersStatus == OrdersStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.orders.isEmpty) {
          return Center(child: Text('No orders found'.tr(context)));
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.screenPadding,
            AppDimensions.screenPadding,
            AppDimensions.screenPadding,
            100,
          ),
          itemCount: state.orders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final order = state.orders[index];
            final orderIdSnippet = order.id.substring(
              order.id.length > 8 ? order.id.length - 8 : 0,
            );
            return Card(
              child: ListTile(
                contentPadding: const EdgeInsets.only(left: 12, right: 8),
                leading: CircleAvatar(
                  backgroundColor: AppColors.muted(brightness),
                  backgroundImage: order.userImage != null
                      ? NetworkImage(order.userImage!)
                      : null,
                  child: order.userImage == null
                      ? const Icon(Icons.person_outline)
                      : null,
                ),
                title: Text(
                  '${'Order ID'.tr(context)} #$orderIdSnippet',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (order.userName != null)
                      Text(
                        '${'By'.tr(context)}: ${order.userName}',
                        style: TextStyle(
                          color: AppColors.primary(brightness),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    if (order.createdAt != null)
                      Text(
                        DateFormat(
                          "MMMM dd, yyyy 'at' h:mm a",
                        ).format(order.createdAt!),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    Text(
                      '${'Total'.tr(context)}: \$${order.totalPrice.toStringAsFixed(2)} • ${order.items.length} ${'items'.tr(context)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      '${'Status'.tr(context)}: ${order.isDelivered ? 'Delivered'.tr(context) : 'Pending'.tr(context)} • ${order.isPaid ? 'Paid'.tr(context) : 'Unpaid'.tr(context)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: order.isDelivered ? Colors.green : Colors.orange,
                      ),
                    ),
                  ],
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderDetailScreen(
                        order: order,
                        isAdmin: true,
                        onStatusUpdate: onStatusUpdate,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
