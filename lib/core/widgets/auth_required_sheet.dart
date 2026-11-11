import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../localization/app_translations.dart';
import 'hero_button.dart';
import '../../features/auth/ui/screens/login_screen.dart';
import '../../features/auth/ui/screens/signup_screen.dart';

/// The action context that triggered the authentication requirement.
enum AuthActionType { wishlist, cart, checkout, profile, generic }

/// Displays an ultra-luxury, localized modal bottom sheet prompting the guest
/// user to sign in or create an account before accessing a protected feature.
Future<void> showAuthRequiredSheet(
  BuildContext context, {
  required AuthActionType action,
}) {
  final brightness = Theme.of(context).brightness;

  IconData icon;
  String messageKey;

  switch (action) {
    case AuthActionType.wishlist:
      icon = Icons.favorite_rounded;
      messageKey = 'Please sign in to add products to your wishlist.';
      break;
    case AuthActionType.cart:
      icon = Icons.shopping_bag_outlined;
      messageKey = 'Please sign in to add products to your cart.';
      break;
    case AuthActionType.checkout:
      icon = Icons.shopping_cart_checkout_rounded;
      messageKey = 'Please sign in to complete your purchase.';
      break;
    case AuthActionType.profile:
    case AuthActionType.generic:
      icon = Icons.lock_outline_rounded;
      messageKey = 'Please sign in to access your personal account.';
      break;
  }

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    builder: (sheetContext) {
      final bottomInset = MediaQuery.of(sheetContext).padding.bottom;

      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: EdgeInsets.fromLTRB(24, 20, 24, bottomInset + 20),
          decoration: BoxDecoration(
            color: AppColors.card(brightness),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: AppColors.border(brightness).withValues(alpha: 0.4),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: brightness == Brightness.dark ? 0.35 : 0.08,
                ),
                blurRadius: 24,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ─── Drag Handle ───
              Container(
                width: 44,
                height: 4.5,
                decoration: BoxDecoration(
                  color: AppColors.foreground(
                    brightness,
                  ).withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 22),

              // ─── Luxury Icon Aura ───
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary(
                    brightness,
                  ).withValues(alpha: 0.10),
                  border: Border.all(
                    color: AppColors.secondary(
                      brightness,
                    ).withValues(alpha: 0.28),
                    width: 1.2,
                  ),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 32,
                    color: AppColors.secondary(brightness),
                  ),
                ),
              ).animate().scale(
                duration: 400.ms,
                curve: Curves.easeOutBack,
                begin: const Offset(0.7, 0.7),
              ),
              const SizedBox(height: 18),

              // ─── Title ───
              Text(
                'Sign in required'.tr(sheetContext),
                style: Theme.of(sheetContext).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.foreground(brightness),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              // ─── Action-Specific Description ───
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  messageKey.tr(sheetContext),
                  style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
                    color: AppColors.foreground(
                      brightness,
                    ).withValues(alpha: 0.65),
                    height: 1.45,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 26),

              // ─── Primary Action: Sign In ───
              HeroButton(
                text: 'Sign In'.tr(sheetContext),
                icon: Icons.login_rounded,
                onPressed: () {
                  Navigator.pop(sheetContext);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
              ),
              const SizedBox(height: 12),

              // ─── Secondary Action: Create Account ───
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.person_add_outlined, size: 18),
                  label: Text(
                    'Create Account'.tr(sheetContext),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.secondary(brightness),
                    side: BorderSide(
                      color: AppColors.secondary(
                        brightness,
                      ).withValues(alpha: 0.35),
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMd,
                      ),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignupScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),

              // ─── Dismiss: Not Now ───
              TextButton(
                onPressed: () => Navigator.pop(sheetContext),
                child: Text(
                  'Not Now'.tr(sheetContext),
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.foreground(
                      brightness,
                    ).withValues(alpha: 0.5),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
