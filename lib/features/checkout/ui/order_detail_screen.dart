import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/localization/app_translations.dart';
import '../data/models/order_model.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/checkout_cubit.dart';

/// Screen showing full details of a single order.
class OrderDetailScreen extends StatelessWidget {
  final OrderModel order;
  final bool isAdmin;
  final VoidCallback? onStatusUpdate;

  const OrderDetailScreen({
    super.key,
    required this.order,
    this.isAdmin = false,
    this.onStatusUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');

    return BlocListener<CheckoutCubit, CheckoutState>(
      listener: (context, state) {
        if (state.errorMessage != null && isAdmin) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!.tr(context)),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Order Details'.tr(context),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Order Header ───
              _buildHeader(context, dateFormat, brightness),
              const SizedBox(height: 24),

              // ─── Order Items ───
              Text(
                'Items'.tr(context),
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 12),
              ...order.items.map(
                (item) => _buildItemCard(context, item, brightness),
              ),
              const SizedBox(height: 24),

              // ─── Shipping Address ───
              Text(
                'Shipping Address'.tr(context),
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 12),
              _buildAddressCard(context, brightness),
              const SizedBox(height: 24),

              // ─── Order Summary ───
              Text(
                'Order Summary'.tr(context),
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 12),
              _buildSummaryCard(context, brightness),
              const SizedBox(height: 32),

              // ─── Admin Actions ───
              if (isAdmin) _buildAdminActions(context, brightness),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminActions(BuildContext context, Brightness b) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!order.isDelivered)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ElevatedButton.icon(
              onPressed: () {
                context.read<CheckoutCubit>().deliverOrder(order.id);
                onStatusUpdate?.call();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.local_shipping_outlined),
              label: Text('Mark as Delivered'.tr(context)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        if (!order.isPaid && !order.isDepositePaid && order.depositeAmount > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ElevatedButton.icon(
              onPressed: () {
                context.read<CheckoutCubit>().depositeOrder(order.id);
                onStatusUpdate?.call();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.account_balance_wallet_outlined),
              label: Text('Mark Deposit as Paid'.tr(context)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.shade800,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        if (!order.isPaid)
          ElevatedButton.icon(
            onPressed: () {
              context.read<CheckoutCubit>().payOrder(order.id);
              onStatusUpdate?.call();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.payment_outlined),
            label: Text('Mark as Paid'.tr(context)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, DateFormat df, Brightness b) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary(b).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppDimensions.radiusDefault),
        border: Border.all(color: AppColors.primary(b).withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${'Order ID'.tr(context)}: #${order.id.substring(order.id.length > 12 ? order.id.length - 12 : 0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _statusChip(context, order.status ?? 'pending', b),
            ],
          ),
          const SizedBox(height: 8),
          if (order.createdAt != null)
            Text(
              df.format(order.createdAt!),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _paymentChip(context, order.paymentMethod, b),
              _paymentStatusChip(context, order.isPaid, b),
              if (order.depositeAmount > 0)
                _depositStatusChip(context, order.isDepositePaid, b),
              _deliveryStatusChip(context, order.isDelivered, b),
            ],
          ),
          if (isAdmin && order.userName != null) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundImage: order.userImage != null
                      ? NetworkImage(order.userImage!)
                      : null,
                  child: order.userImage == null
                      ? const Icon(Icons.person, size: 16)
                      : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${'Customer'.tr(context)}: ${order.userName}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildItemCard(
    BuildContext context,
    OrderItemModel item,
    Brightness b,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card(b),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.border(b).withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 60,
              height: 60,
              child: item.image != null
                  ? CachedNetworkImage(
                      imageUrl: item.image!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          Container(color: AppColors.muted(b)),
                      errorWidget: (_, __, ___) => Container(
                        color: AppColors.muted(b),
                        child: const Icon(Icons.image_outlined),
                      ),
                    )
                  : Container(
                      color: AppColors.muted(b),
                      child: const Icon(Icons.image_outlined),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title ?? 'Product',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${'Quantity'.tr(context)}: ${item.quantity}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            '\$${item.price.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.secondary(b),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(BuildContext context, Brightness b) {
    final addr = order.address;
    if (addr == null) return Text('No address provided'.tr(context));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card(b),
        borderRadius: BorderRadius.circular(AppDimensions.radiusDefault),
        border: Border.all(color: AppColors.border(b).withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            addr.displayAddress,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, Brightness b) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card(b),
        borderRadius: BorderRadius.circular(AppDimensions.radiusDefault),
        border: Border.all(color: AppColors.border(b).withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          _summaryRow('Subtotal'.tr(context), order.subtotal, b),
          const SizedBox(height: 8),
          _summaryRow(
            'Tax & Shipping'.tr(context),
            order.tax + order.shipping,
            b,
          ),
          if (order.depositeAmount > 0) ...[
            const SizedBox(height: 8),
            _summaryRow(
              '${'Deposit'.tr(context)} (${order.isDepositePaid ? 'Deposit Paid'.tr(context) : 'Deposit Pending'.tr(context)})',
              order.depositeAmount,
              b,
            ),
          ],
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Total'.tr(context),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '\$${order.totalPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary(b),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, double value, Brightness b) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Colors.grey),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '\$${value.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _statusChip(BuildContext context, String status, Brightness b) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary(b).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.tr(context).toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: AppColors.primary(b),
        ),
      ),
    );
  }

  Widget _paymentChip(BuildContext context, String method, Brightness b) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.secondary(b).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        method.tr(context).toUpperCase(),
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: AppColors.secondary(b),
        ),
      ),
    );
  }

  Widget _paymentStatusChip(BuildContext context, bool isPaid, Brightness b) {
    final statusText = isPaid ? 'PAID' : 'UNPAID';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: (isPaid ? Colors.green : Colors.orange).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        statusText.tr(context),
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: isPaid ? Colors.green : Colors.orange,
        ),
      ),
    );
  }

  Widget _depositStatusChip(BuildContext context, bool isPaid, Brightness b) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: (isPaid ? Colors.green : Colors.amber.shade800).withValues(
          alpha: 0.1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        (isPaid ? 'Deposit Paid' : 'Deposit Pending').tr(context),
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: isPaid ? Colors.green : Colors.amber.shade800,
        ),
      ),
    );
  }

  Widget _deliveryStatusChip(
    BuildContext context,
    bool isDelivered,
    Brightness b,
  ) {
    final deliveryText = isDelivered ? 'DELIVERED' : 'PENDING DELIVERY';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: (isDelivered ? Colors.blue : Colors.grey).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        deliveryText.tr(context),
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: isDelivered ? Colors.blue : Colors.grey,
        ),
      ),
    );
  }
}
