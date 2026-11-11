import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/localization/app_translations.dart';
import '../../../../../core/utils/auth_guard.dart';
import '../../../../../core/widgets/shimmer_loading.dart';
import '../../../../wishlist/logic/wishlist_cubit.dart';
import '../../../data/models/product_model.dart';

/// Sliver app bar displaying the edge-to-edge product gallery, floating controls,
/// zoom pill counter, pagination dots, and sale badge.
class ProductDetailAppBar extends StatelessWidget {
  final ProductModel product;
  final List<String> allImages;
  final int selectedImageIndex;
  final PageController pageController;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onOpenLightbox;
  final VoidCallback onWhatsAppTap;

  const ProductDetailAppBar({
    super.key,
    required this.product,
    required this.allImages,
    required this.selectedImageIndex,
    required this.pageController,
    required this.onPageChanged,
    required this.onOpenLightbox,
    required this.onWhatsAppTap,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return SliverAppBar(
      expandedHeight: 245.0 + MediaQuery.of(context).padding.top,
      pinned: true,
      backgroundColor: AppColors.background(brightness),
      leading: _GlassCircleButton(
        brightness: brightness,
        padding: const EdgeInsets.all(8.0),
        child: IconButton(
          padding: EdgeInsets.zero,
          icon: Icon(
            context.isArabic
                ? Icons.arrow_forward_ios
                : Icons.arrow_back_ios_new,
            size: 16,
            color: AppColors.foreground(brightness),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
        // WhatsApp Merchant Inquiry Button
        _GlassCircleButton(
          brightness: brightness,
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
          width: 40,
          height: 40,
          child: IconButton(
            padding: EdgeInsets.zero,
            tooltip: 'Contact on WhatsApp'.tr(context),
            icon: Image.asset(
              'assets/icons/whatsapp_icon.png',
              width: 22,
              height: 22,
              fit: BoxFit.contain,
            ),
            onPressed: onWhatsAppTap,
          ),
        ),
        BlocBuilder<WishlistCubit, WishlistState>(
          builder: (context, state) {
            final isFav = state.isInWishlist(product.id);
            return _GlassCircleButton(
              brightness: brightness,
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 8.0,
              ),
              width: 40,
              height: 40,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  size: 20,
                  color: isFav
                      ? AppColors.primary(brightness)
                      : AppColors.foreground(brightness),
                ),
                onPressed: () {
                  AuthGuard.requireAuth(
                    context,
                    action: AuthActionType.wishlist,
                    onAuthenticated: () {
                      context.read<WishlistCubit>().toggleWishlist(
                        product.id,
                        product,
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Full-width Edge-to-Edge Image PageView
            allImages.isNotEmpty
                ? PageView.builder(
                    controller: pageController,
                    onPageChanged: onPageChanged,
                    itemCount: allImages.length,
                    itemBuilder: (_, i) => GestureDetector(
                      onTap: onOpenLightbox,
                      child: Container(
                        width: double.infinity,
                        color: AppColors.card(brightness),
                        child: Hero(
                          tag: 'product_${product.id}_$i',
                          child: CachedNetworkImage(
                            imageUrl: allImages[i],
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                            placeholder: (_, __) => const ShimmerLoading(
                              width: double.infinity,
                              height: double.infinity,
                              borderRadius: 0,
                            ),
                            errorWidget: (_, __, ___) => Container(
                              color: AppColors.muted(brightness),
                              child: Center(
                                child: Icon(
                                  Icons.image_outlined,
                                  size: 60,
                                  color: AppColors.foreground(
                                    brightness,
                                  ).withValues(alpha: 0.15),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : Container(
                    width: double.infinity,
                    color: AppColors.muted(brightness),
                    child: Center(
                      child: Icon(
                        Icons.shopping_bag_outlined,
                        size: 80,
                        color: AppColors.foreground(
                          brightness,
                        ).withValues(alpha: 0.15),
                      ),
                    ),
                  ),

            // Floating Counter & Fullscreen Zoom Pill (with RTL fix)
            if (allImages.isNotEmpty)
              Positioned(
                bottom: 14,
                right: 14,
                child: GestureDetector(
                  onTap: onOpenLightbox,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.card(
                            brightness,
                          ).withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusXl,
                          ),
                          border: Border.all(
                            color: AppColors.border(
                              brightness,
                            ).withValues(alpha: 0.4),
                            width: 0.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.fullscreen,
                              size: 15,
                              color: AppColors.secondary(brightness),
                            ),
                            const SizedBox(width: 4),
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: Text(
                                '${selectedImageIndex + 1} / ${allImages.length}',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.foreground(brightness),
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

            // Floating Modern Dots Indicator (Centered at bottom of image)
            if (allImages.length > 1)
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    allImages.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: selectedImageIndex == i ? 18 : 6,
                      height: 5,
                      decoration: BoxDecoration(
                        color: selectedImageIndex == i
                            ? AppColors.secondary(brightness)
                            : (brightness == Brightness.dark
                                  ? Colors.white.withValues(alpha: 0.45)
                                  : Colors.black.withValues(alpha: 0.35)),
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Sale badge if product is on sale
            if (product.onSale)
              Positioned(
                bottom: 14,
                left: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary(brightness),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary(
                          brightness,
                        ).withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    'sale'.tr(context),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _GlassCircleButton extends StatelessWidget {
  final Brightness brightness;
  final EdgeInsetsGeometry padding;
  final double? width;
  final double? height;
  final Widget child;

  const _GlassCircleButton({
    required this.brightness,
    required this.padding,
    required this.child,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: AppColors.card(brightness).withValues(alpha: 0.85),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.border(brightness).withValues(alpha: 0.3),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
