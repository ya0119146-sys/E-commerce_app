import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/hero_button.dart';

import '../data/models/order_model.dart';
import 'order_detail_screen.dart';

/// Order success screen shown after placing an order.
class OrderSuccessScreen extends StatelessWidget {
  final OrderModel order;
  const OrderSuccessScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.screenPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.success.withValues(alpha: 0.1),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    size: 60,
                    color: AppColors.success,
                  ),
                )
                    .animate()
                    .scale(
                      begin: const Offset(0.0, 0.0),
                      end: const Offset(1.0, 1.0),
                      duration: 600.ms,
                      curve: Curves.elasticOut,
                    )
                    .fade(duration: 300.ms),

                const SizedBox(height: 32),

                Text(
                  'Order Confirmed!',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.foreground(brightness),
                  ),
                )
                    .animate()
                    .fade(duration: 500.ms, delay: 300.ms)
                    .moveY(begin: 15, end: 0, duration: 500.ms, delay: 300.ms),

                const SizedBox(height: 12),

                Text(
                  'Thank you for your purchase.\nYour order is being processed.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                      ),
                ).animate().fade(duration: 500.ms, delay: 500.ms),

                const SizedBox(height: 40),

                HeroButton(
                  text: 'View Order Details',
                  icon: Icons.receipt_long_outlined,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrderDetailScreen(order: order),
                      ),
                    );
                  },
                ).animate().fade(duration: 400.ms, delay: 700.ms).moveY(
                      begin: 20,
                      end: 0,
                      duration: 400.ms,
                      delay: 700.ms,
                    ),

                const SizedBox(height: 16),

                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  icon: const Icon(Icons.shopping_bag_outlined),
                  label: const Text('Continue Shopping'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusDefault),
                    ),
                  ),
                ).animate().fade(duration: 400.ms, delay: 850.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
