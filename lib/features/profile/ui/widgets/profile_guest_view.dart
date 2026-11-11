import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/utils/auth_guard.dart';
import '../../../../core/widgets/hero_button.dart';
import '../../../auth/ui/screens/login_screen.dart';
import '../../../auth/ui/screens/signup_screen.dart';
import '../../../checkout/ui/screens/order_history_screen.dart';
import '../screens/address_screen.dart';
import 'profile_settings_tiles.dart';

/// Profile screen body shown when browsing in guest mode.
class ProfileGuestView extends StatelessWidget {
  const ProfileGuestView({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.screenPadding,
        12,
        AppDimensions.screenPadding,
        120,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ─── Guest Welcome Card ───
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacingLg),
            decoration: BoxDecoration(
              color: AppColors.card(brightness),
              borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
              border: Border.all(
                color: AppColors.border(brightness).withValues(alpha: 0.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary(brightness).withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.secondary(brightness),
                        AppColors.primary(brightness),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary(
                          brightness,
                        ).withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.person_outline_rounded,
                      size: 42,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Welcome to Labella'.tr(context),
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.foreground(brightness),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'Sign in or create an account to enjoy your complete shopping experience.'
                      .tr(context),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.foreground(
                      brightness,
                    ).withValues(alpha: 0.7),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                HeroButton(
                  text: 'Sign In'.tr(context),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignupScreen()),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: AppColors.secondary(
                          brightness,
                        ).withValues(alpha: 0.6),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusDefault,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      'create_account'.tr(context),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondary(brightness),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fade(duration: 400.ms).moveY(begin: 15, end: 0),

          const SizedBox(height: 18),

          // ─── Member Benefits Card ───
          Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.card(brightness),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  border: Border.all(
                    color: AppColors.border(brightness).withValues(alpha: 0.4),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4.0, top: 2.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.workspace_premium_outlined,
                            size: 18,
                            color: AppColors.secondary(brightness),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Member Benefits'.tr(context),
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 12),
                    _BenefitRow(
                      brightness: brightness,
                      icon: Icons.local_shipping_outlined,
                      title: 'Order Tracking'.tr(context),
                      description:
                          'Track your orders and follow their delivery status.'
                              .tr(context),
                    ),
                    _BenefitRow(
                      brightness: brightness,
                      icon: Icons.favorite_border_rounded,
                      title: 'nav_wishlist'.tr(context),
                      description:
                          'Save your favorite products and access them anytime.'
                              .tr(context),
                    ),
                    _BenefitRow(
                      brightness: brightness,
                      icon: Icons.bolt_rounded,
                      title: 'Faster Checkout'.tr(context),
                      description:
                          'Save your delivery information for a smoother shopping experience.'
                              .tr(context),
                    ),
                    _BenefitRow(
                      brightness: brightness,
                      icon: Icons.person_outline_rounded,
                      title: 'Personal Account'.tr(context),
                      description:
                          'Manage your profile and view your shopping history.'
                              .tr(context),
                    ),
                  ],
                ),
              )
              .animate()
              .fade(duration: 400.ms, delay: 150.ms)
              .moveY(begin: 15, end: 0),

          const SizedBox(height: 24),

          // ─── Settings & Actions ───
          ProfileMenuTile(
            icon: Icons.receipt_long_outlined,
            title: 'my_orders'.tr(context),
            onTap: () => AuthGuard.requireAuth(
              context,
              action: AuthActionType.profile,
              onAuthenticated: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
              ),
            ),
            index: 0,
          ),
          ProfileMenuTile(
            icon: Icons.location_on_outlined,
            title: 'shipping_address'.tr(context),
            onTap: () => AuthGuard.requireAuth(
              context,
              action: AuthActionType.profile,
              onAuthenticated: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddressScreen()),
              ),
            ),
            index: 1,
          ),
          const ProfileWhatsAppTile(index: 2),
          const ProfileDarkModeTile()
              .animate()
              .fade(duration: 300.ms, delay: 350.ms)
              .moveY(begin: 15, end: 0),
          const ProfileLanguageTile()
              .animate()
              .fade(duration: 300.ms, delay: 400.ms)
              .moveY(begin: 15, end: 0),
        ],
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final Brightness brightness;
  final IconData icon;
  final String title;
  final String description;

  const _BenefitRow({
    required this.brightness,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.secondary(brightness).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 16, color: AppColors.secondary(brightness)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.foreground(brightness),
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: AppColors.foreground(
                      brightness,
                    ).withValues(alpha: 0.6),
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
