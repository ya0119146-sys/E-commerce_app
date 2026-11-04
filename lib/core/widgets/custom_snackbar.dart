import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Notification types for CustomSnackBar.
enum SnackBarType { success, error, info, warning, cart }

/// Display position for the notification.
enum SnackBarPosition { top, bottom }

/// High-fashion luxury notification pill for Labella.
///
/// Features:
/// - Floats at the top (under status bar/app bar) or bottom with smooth slide & fade animation.
/// - Frosted glass card appearance with tailored icon, tinted badge, and border.
/// - Auto-dismisses with configurable timer (default: 2.2 seconds).
/// - Tap or swipe to dismiss immediately.
/// - Single-instance queue: dismisses active toast when a new one is requested.
class CustomSnackBar {
  CustomSnackBar._();

  static OverlayEntry? _activeEntry;
  static Timer? _dismissTimer;

  /// General display method.
  static void show(
    BuildContext context, {
    required String message,
    SnackBarType type = SnackBarType.info,
    SnackBarPosition position = SnackBarPosition.top,
    Duration duration = const Duration(milliseconds: 2400),
    IconData? customIcon,
  }) {
    // Dismiss any existing toast first
    dismiss();

    final overlay =
        Overlay.maybeOf(context, rootOverlay: true) ?? Overlay.of(context);

    late final OverlayEntry entry;

    entry = OverlayEntry(
      builder: (ctx) => _ToastWidget(
        message: message,
        type: type,
        position: position,
        duration: duration,
        customIcon: customIcon,
        onDismiss: () {
          if (_activeEntry == entry) {
            dismiss();
          }
        },
      ),
    );

    _activeEntry = entry;
    overlay.insert(entry);

    _dismissTimer = Timer(duration + const Duration(milliseconds: 300), () {
      if (_activeEntry == entry) {
        dismiss();
      }
    });
  }

  /// Convenience helper for success messages (e.g. "Order placed", "Profile updated").
  static void showSuccess(
    BuildContext context,
    String message, {
    SnackBarPosition position = SnackBarPosition.top,
    Duration duration = const Duration(milliseconds: 2400),
  }) {
    show(
      context,
      message: message,
      type: SnackBarType.success,
      position: position,
      duration: duration,
    );
  }

  /// Convenience helper for error messages (e.g. "Network error", "Invalid password").
  static void showError(
    BuildContext context,
    String message, {
    SnackBarPosition position = SnackBarPosition.top,
    Duration duration = const Duration(milliseconds: 2800),
  }) {
    show(
      context,
      message: message,
      type: SnackBarType.error,
      position: position,
      duration: duration,
    );
  }

  /// Convenience helper for informative messages (e.g. "Press back again to exit").
  static void showInfo(
    BuildContext context,
    String message, {
    SnackBarPosition position = SnackBarPosition.top,
    Duration duration = const Duration(milliseconds: 2200),
  }) {
    show(
      context,
      message: message,
      type: SnackBarType.info,
      position: position,
      duration: duration,
    );
  }

  /// Convenience helper for cart actions (e.g. "+ Added to cart ✨").
  static void showCart(
    BuildContext context,
    String message, {
    SnackBarPosition position = SnackBarPosition.top,
    Duration duration = const Duration(milliseconds: 2000),
  }) {
    show(
      context,
      message: message,
      type: SnackBarType.cart,
      position: position,
      duration: duration,
    );
  }

  /// Instantly dismisses active toast.
  static void dismiss() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    if (_activeEntry != null) {
      final entry = _activeEntry!;
      _activeEntry = null;
      if (entry.mounted) {
        entry.remove();
      }
    }
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final SnackBarType type;
  final SnackBarPosition position;
  final Duration duration;
  final IconData? customIcon;
  final VoidCallback onDismiss;

  const _ToastWidget({
    required this.message,
    required this.type,
    required this.position,
    required this.duration,
    required this.onDismiss,
    this.customIcon,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );

    final isTop = widget.position == SnackBarPosition.top;
    _slideAnimation =
        Tween<Offset>(
          begin: Offset(0, isTop ? -0.8 : 0.8),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
        );

    _animController.forward();
  }

  Future<void> _animateOut() async {
    if (!mounted) return;
    await _animController.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    final typeColor = _getTypeColor(widget.type, brightness);
    final iconData = widget.customIcon ?? _getTypeIcon(widget.type);

    final isTop = widget.position == SnackBarPosition.top;
    final topPadding = isTop ? (mediaQuery.padding.top + 10.0) : null;
    final bottomPadding = !isTop ? (mediaQuery.padding.bottom + 85.0) : null;

    return Positioned(
      top: topPadding,
      bottom: bottomPadding,
      left: 16,
      right: 16,
      child: Material(
        type: MaterialType.transparency,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: GestureDetector(
              onTap: _animateOut,
              onVerticalDragEnd: (_) => _animateOut(),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 420),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF241E20).withValues(alpha: 0.96)
                        : Colors.white.withValues(alpha: 0.98),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: typeColor.withValues(alpha: isDark ? 0.45 : 0.3),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.35 : 0.12,
                        ),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                      BoxShadow(
                        color: typeColor.withValues(alpha: 0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon Pill
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: typeColor.withValues(alpha: 0.14),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(iconData, size: 16, color: typeColor),
                      ),
                      const SizedBox(width: 10),

                      // Text Message
                      Flexible(
                        child: Text(
                          widget.message,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.foreground(brightness),
                            height: 1.25,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(SnackBarType type, Brightness brightness) {
    switch (type) {
      case SnackBarType.success:
        return const Color(0xFF2E7D32); // Emerald Green
      case SnackBarType.error:
        return AppColors.error;
      case SnackBarType.warning:
        return const Color(0xFFED6C02); // Warm Amber
      case SnackBarType.cart:
        return AppColors.secondary(brightness); // Labella Rose Gold
      case SnackBarType.info:
        return AppColors.secondary(brightness);
    }
  }

  IconData _getTypeIcon(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return Icons.check_circle_rounded;
      case SnackBarType.error:
        return Icons.error_outline_rounded;
      case SnackBarType.warning:
        return Icons.warning_amber_rounded;
      case SnackBarType.cart:
        return Icons.shopping_bag_outlined;
      case SnackBarType.info:
        return Icons.info_outline_rounded;
    }
  }
}
