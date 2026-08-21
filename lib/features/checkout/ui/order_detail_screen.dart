import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
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
            SnackBar(content: Text(state.errorMessage!), backgroundColor: AppColors.error),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Order Details', style: Theme.of(context).textTheme.titleMedium),
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
              Text('Items', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 12),
              ...order.items.map((item) => _buildItemCard(context, item, brightness)),
              const SizedBox(height: 24),

              // ─── Shipping Address ───
              Text('Shipping Address', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 12),
              _buildAddressCard(context, brightness),
              const SizedBox(height: 24),

              // ─── Order Summary ───
              Text('Order Summary', style: Theme.of(context).textTheme.titleSmall),
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
              label: const Text('Mark as Delivered'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
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
            label: const Text('Mark as Paid'),
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
              Text(
                'Order ID: #${order.id.substring(order.id.length > 12 ? order.id.length - 12 : 0)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              _statusChip(order.status ?? 'pending', b),
            ],
          ),
          const SizedBox(height: 8),
          if (order.createdAt != null)
            Text(df.format(order.createdAt!), style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          Row(
            children: [
              _paymentChip(order.paymentMethod, b),
              const SizedBox(width: 8),
              _paymentStatusChip(order.isPaid, b),
              const SizedBox(width: 8),
              _deliveryStatusChip(order.isDelivered, b),
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
                Text(
                  'Customer: ${order.userName}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, OrderItemModel item, Brightness b) {
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
                      placeholder: (_, __) => Container(color: AppColors.muted(b)),
                      errorWidget: (_, __, ___) => Container(color: AppColors.muted(b), child: const Icon(Icons.image_outlined)),
                    )
                  : Container(color: AppColors.muted(b), child: const Icon(Icons.image_outlined)),
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
                Text('Qty: ${item.quantity}', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Text(
            '\$${item.price.toStringAsFixed(2)}',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary(b)),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(BuildContext context, Brightness b) {
    final addr = order.address;
    if (addr == null) return const Text('No address provided');

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
          _summaryRow('Subtotal', order.subtotal, b),
          const SizedBox(height: 8),
          _summaryRow('Tax & Shipping', order.tax + order.shipping, b),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text('\$${value.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _statusChip(String status, Brightness b) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary(b).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary(b)),
      ),
    );
  }

  Widget _paymentChip(String method, Brightness b) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.secondary(b).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        method.toUpperCase(),
        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.secondary(b)),
      ),
    );
  }

  Widget _paymentStatusChip(bool isPaid, Brightness b) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: (isPaid ? Colors.green : Colors.orange).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isPaid ? 'PAID' : 'UNPAID',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: isPaid ? Colors.green : Colors.orange,
        ),
      ),
    );
  }

  Widget _deliveryStatusChip(bool isDelivered, Brightness b) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: (isDelivered ? Colors.blue : Colors.grey).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isDelivered ? 'DELIVERED' : 'PENDING DELIVERY',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: isDelivered ? Colors.blue : Colors.grey,
        ),
      ),
    );
  }
}
