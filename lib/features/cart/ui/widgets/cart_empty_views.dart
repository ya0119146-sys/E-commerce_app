import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../app/bottom_nav_shell.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/widgets/hero_button.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../auth/ui/login_screen.dart';

/// Shimmer loading list for cart items.
class CartLoadingList extends StatelessWidget {
  const CartLoadingList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppDimensions.screenPadding),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (_, __) =>
          const ShimmerLoading(width: double.infinity, height: 100),
    );
  }
}

/// Empty state view when the authenticated user's cart has no items.
class CartEmptyView extends StatelessWidget {
  final String role;

  const CartEmptyView({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Center(
      child:
          Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.primary(
                        brightness,
                      ).withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.shopping_cart_outlined,
                      size: 80,
                      color: AppColors.primary(
                        brightness,
                      ).withValues(alpha: 0.3),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Your cart is empty'.tr(context),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Add some items to get started'.tr(context),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.foreground(
                        brightness,
                      ).withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: HeroButton(
                      text: 'Start Shopping'.tr(context),
                      icon: Icons.shopping_bag_outlined,
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                BottomNavShell(role: role, initialIndex: 0),
                          ),
                          (route) => false,
                        );
                      },
                    ),
                  ),
                ],
              )
              .animate()
              .fade(duration: 500.ms)
              .scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOutBack),
    );
  }
}

/// Guest state prompting sign-in or store exploration from the Cart screen.
class CartGuestView extends StatelessWidget {
  final String role;

  const CartGuestView({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.screenPadding),
        child:
            Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.secondary(
                          brightness,
                        ).withValues(alpha: 0.10),
                        border: Border.all(
                          color: AppColors.secondary(
                            brightness,
                          ).withValues(alpha: 0.28),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.shopping_bag_outlined,
                          size: 46,
                          color: AppColors.secondary(brightness),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Your cart is waiting'.tr(context),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Please sign in to view your cart and start shopping.'.tr(
                        context,
                      ),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.foreground(
                          brightness,
                        ).withValues(alpha: 0.65),
                        height: 1.45,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    HeroButton(
                      text: 'Sign In'.tr(context),
                      icon: Icons.login_rounded,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  BottomNavShell(role: role, initialIndex: 0),
                            ),
                            (route) => false,
                          );
                        },
                        icon: Icon(
                          Icons.storefront_outlined,
                          size: 20,
                          color: AppColors.secondary(brightness),
                        ),
                        label: Text(
                          'Explore Store'.tr(context),
                          style: TextStyle(
                            height: 1.2,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.secondary(brightness),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.secondary(brightness),
                          backgroundColor: AppColors.secondary(
                            brightness,
                          ).withValues(alpha: 0.08),
                          side: BorderSide(
                            color: AppColors.secondary(brightness),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusDefault,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
                .animate()
                .fade(duration: 400.ms)
                .scale(begin: const Offset(0.92, 0.92)),
      ),
    );
  }
}
