import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../logic/checkout_cubit.dart';
import 'order_detail_screen.dart';

/// Order history screen listing past orders.
class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CheckoutCubit>().fetchOrderHistory();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Scaffold(
      appBar: AppBar(title: const Text('Order History')),
      body: BlocBuilder<CheckoutCubit, CheckoutState>(
        builder: (context, state) {
          if (state.ordersStatus == OrdersStatus.loading) {
            return ListView.builder(
              padding: const EdgeInsets.all(AppDimensions.screenPadding),
              itemCount: 4,
              itemBuilder: (_, __) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ShimmerLoading(
                  width: double.infinity,
                  height: 90,
                  borderRadius: AppDimensions.radiusDefault,
                ),
              ),
            );
          }

          if (state.orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: AppColors.primary(brightness).withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No orders yet',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppDimensions.screenPadding),
            itemCount: state.orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final order = state.orders[index];
              return InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OrderDetailScreen(order: order),
                  ),
                ),
                borderRadius: BorderRadius.circular(AppDimensions.radiusDefault),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card(brightness),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusDefault),
                    border: Border.all(
                      color: AppColors.border(brightness).withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Order #${order.id.substring(order.id.length > 8 ? order.id.length - 8 : 0)}',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          if (order.status != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accent(brightness)
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusSm,
                                ),
                              ),
                              child: Text(
                                order.status!,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.accent(brightness),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (order.createdAt != null)
                            Text(
                              dateFormat.format(order.createdAt!),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          Text(
                            '\$${order.totalPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.secondary(brightness),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      if (order.items.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          '${order.items.length} item${order.items.length > 1 ? 's' : ''}',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ],
                  ),
                ),
              )
                  .animate()
                  .fade(
                    duration: 350.ms,
                    delay: Duration(milliseconds: 60 * index),
                  )
                  .moveY(
                    begin: 15,
                    end: 0,
                    duration: 350.ms,
                    delay: Duration(milliseconds: 60 * index),
                  );
            },
          );
        },
      ),
    );
  }
}
