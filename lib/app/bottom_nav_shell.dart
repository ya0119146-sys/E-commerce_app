import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/constants/app_colors.dart';
import '../features/store/ui/home_screen.dart';
import '../features/store/ui/search_screen.dart';
import '../features/cart/ui/cart_screen.dart';
import '../features/wishlist/ui/wishlist_screen.dart';
import '../features/profile/ui/profile_screen.dart';
import '../features/admin/ui/admin_screen.dart';
import '../features/cart/logic/cart_cubit.dart';
import '../core/localization/app_translations.dart';

/// Concept 1: Ultra-luxury Floating Glassmorphism Bottom Navigation Bar Shell.
/// Features:
/// - Custom hand-crafted Flutter UI (not a restrictive package — fully customizable!)
/// - Auto-hide on scroll down, reveal on scroll up
/// - Enlarged comfortable touch targets and icons
/// - Frosted glass backdrop blur with illuminated active pill
class BottomNavShell extends StatefulWidget {
  const BottomNavShell({super.key, required this.role});

  final String role;
  @override
  State<BottomNavShell> createState() => _BottomNavShellState();
}

class _BottomNavShellState extends State<BottomNavShell> {
  int _currentIndex = 0;
  bool _isNavVisible = true;

  List<Widget> get _screens => [
    HomeScreen(role: widget.role),
    SearchScreen(role: widget.role),
    WishlistScreen(role: widget.role),
    if (widget.role != 'admin') CartScreen(role: widget.role),
    const ProfileScreen(),
    if (widget.role == 'admin') const AdminScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
            _isNavVisible = true;
          });
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background(brightness),
        extendBody: true,
        body: NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.axis != Axis.vertical) return false;
          if (notification.direction == ScrollDirection.reverse) {
            // User scrolled down -> hide navbar
            if (_isNavVisible) {
              setState(() => _isNavVisible = false);
            }
          } else if (notification.direction == ScrollDirection.forward) {
            // User scrolled up -> reveal navbar
            if (!_isNavVisible) {
              setState(() => _isNavVisible = true);
            }
          }
          return false;
        },
        child: IndexedStack(index: _currentIndex, children: _screens),
      ),
      bottomNavigationBar: BlocBuilder<CartCubit, CartState>(
        builder: (context, cartState) {
          final items = <_NavItemData>[
            _NavItemData(
              icon: Icons.home_outlined,
              activeIcon: Icons.home_rounded,
              label: 'nav_home'.tr(context),
            ),
            _NavItemData(
              icon: Icons.search_rounded,
              activeIcon: Icons.search_rounded,
              label: 'nav_store'.tr(context),
            ),
            _NavItemData(
              icon: Icons.favorite_border_rounded,
              activeIcon: Icons.favorite_rounded,
              label: 'nav_wishlist'.tr(context),
            ),
            if (widget.role != 'admin')
              _NavItemData(
                icon: Icons.shopping_bag_outlined,
                activeIcon: Icons.shopping_bag_rounded,
                label: 'nav_cart'.tr(context),
                badgeCount: cartState.cartItemCount,
              ),
            _NavItemData(
              icon: Icons.person_outline_rounded,
              activeIcon: Icons.person_rounded,
              label: 'nav_profile'.tr(context),
            ),
            if (widget.role == 'admin')
              _NavItemData(
                icon: Icons.admin_panel_settings_outlined,
                activeIcon: Icons.admin_panel_settings_rounded,
                label: 'Admin'.tr(context),
              ),
          ];

          return AnimatedSlide(
            offset: _isNavVisible ? Offset.zero : const Offset(0, 1.8),
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeInOutCubic,
            child: AnimatedOpacity(
              opacity: _isNavVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 220),
              child: Container(
                margin: EdgeInsets.fromLTRB(
                  16,
                  0,
                  16,
                  bottomPadding > 0 ? bottomPadding + 6 : 16,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: Container(
                      height: 70,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF241020).withValues(alpha: 0.88)
                            : Colors.white.withValues(alpha: 0.90),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: AppColors.secondary(
                            brightness,
                          ).withValues(alpha: 0.22),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.secondary(
                              brightness,
                            ).withValues(alpha: 0.16),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(items.length, (index) {
                          final item = items[index];
                          final isSelected = _currentIndex == index;

                          Widget iconWidget = Icon(
                            isSelected ? item.activeIcon : item.icon,
                            size: isSelected ? 22 : 24,
                            color: isSelected
                                ? AppColors.secondary(brightness)
                                : AppColors.foreground(
                                    brightness,
                                  ).withValues(alpha: 0.5),
                          );

                          if (item.badgeCount != null && item.badgeCount! > 0) {
                            iconWidget = Badge(
                              label: Text(
                                '${item.badgeCount}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              backgroundColor: AppColors.accent(brightness),
                              child: iconWidget,
                            );
                          }

                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() {
                                _currentIndex = index;
                                _isNavVisible = true;
                              });
                            },
                            behavior: HitTestBehavior.opaque,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 260),
                              curve: Curves.easeOutCubic,
                              padding: isSelected
                                  ? const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 9,
                                    )
                                  : const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.secondary(
                                        brightness,
                                      ).withValues(alpha: 0.12)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(24),
                                border: isSelected
                                    ? Border.all(
                                        color: AppColors.secondary(
                                          brightness,
                                        ).withValues(alpha: 0.2),
                                        width: 1.0,
                                      )
                                    : null,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  iconWidget,
                                  if (isSelected) ...[
                                    const SizedBox(width: 6),
                                    Text(
                                      item.label,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.secondary(brightness),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int? badgeCount;

  const _NavItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.badgeCount,
  });
}
