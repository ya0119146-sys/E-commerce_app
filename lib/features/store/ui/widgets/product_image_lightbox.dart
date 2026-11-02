import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/localization/app_translations.dart';

/// Full-screen luxury image gallery with pinch-to-zoom, pan, double-tap zoom,
/// horizontal swipe navigation, and bottom thumbnail selector.
/// The viewing area is safe from controls overlap so no image is clipped.
class ProductImageLightbox extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final String heroTagPrefix;

  const ProductImageLightbox({
    super.key,
    required this.images,
    this.initialIndex = 0,
    required this.heroTagPrefix,
  });

  /// Static helper to display the lightbox via smooth modal route
  static Future<int?> show(
    BuildContext context, {
    required List<String> images,
    int initialIndex = 0,
    required String heroTagPrefix,
  }) {
    return Navigator.of(context).push<int>(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        barrierDismissible: true,
        pageBuilder: (context, _, __) => ProductImageLightbox(
          images: images,
          initialIndex: initialIndex,
          heroTagPrefix: heroTagPrefix,
        ),
        transitionsBuilder: (context, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  State<ProductImageLightbox> createState() => _ProductImageLightboxState();
}

class _ProductImageLightboxState extends State<ProductImageLightbox> {
  late int _currentIndex;
  late final PageController _pageController;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _close() {
    Navigator.of(context).pop(_currentIndex);
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _close();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: [
              // ─── Top Header Bar (Outside image area to prevent clipping) ───
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 200),
                crossFadeState: _showControls
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                firstChild: _buildTopBar(context),
                secondChild: const SizedBox(width: double.infinity, height: 0),
              ),

              // ─── Photo View Gallery (Safe middle area, 100% contained) ───
              Expanded(
                child: PhotoViewGallery.builder(
                  scrollPhysics: const BouncingScrollPhysics(),
                  pageController: _pageController,
                  itemCount: widget.images.length,
                  onPageChanged: (index) {
                    setState(() => _currentIndex = index);
                  },
                  backgroundDecoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                  builder: (context, index) {
                    return PhotoViewGalleryPageOptions(
                      imageProvider:
                          CachedNetworkImageProvider(widget.images[index]),
                      initialScale: PhotoViewComputedScale.contained,
                      minScale: PhotoViewComputedScale.contained,
                      maxScale: PhotoViewComputedScale.covered * 3.5,
                      heroAttributes: PhotoViewHeroAttributes(
                        tag: '${widget.heroTagPrefix}_$index',
                      ),
                      onTapUp: (context, details, controllerValue) {
                        _toggleControls();
                      },
                      errorBuilder: (_, __, ___) => Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: Colors.white.withValues(alpha: 0.4),
                          size: 60,
                        ),
                      ),
                    );
                  },
                  loadingBuilder: (context, event) => Center(
                    child: CircularProgressIndicator(
                      value: event == null
                          ? null
                          : event.cumulativeBytesLoaded /
                              (event.expectedTotalBytes ?? 1),
                      color: AppColors.secondary(brightness),
                      strokeWidth: 2.5,
                    ),
                  ),
                ),
              ),

              // ─── Bottom Thumbnail Strip & Controls (Outside image area) ───
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 200),
                crossFadeState: _showControls
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                firstChild: _buildBottomBar(context, brightness),
                secondChild: const SizedBox(width: double.infinity, height: 0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Close Button
          GestureDetector(
            onTap: _close,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                ),
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),

          // Image Counter Pill
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              '${_currentIndex + 1} / ${widget.images.length}',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),

          // Balance spacer
          const SizedBox(width: 42),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, Brightness brightness) {
    return Container(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      color: Colors.black,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Subtle hint
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.pinch_outlined,
                color: Colors.white.withValues(alpha: 0.5),
                size: 15,
              ),
              const SizedBox(width: 6),
              Text(
                'pinch_to_zoom'.tr(context),
                style: GoogleFonts.poppins(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          if (widget.images.length > 1) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 52,
              child: Center(
                child: ListView.separated(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: widget.images.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, i) {
                    final isSelected = _currentIndex == i;
                    return GestureDetector(
                      onTap: () {
                        _pageController.animateToPage(
                          i,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOutCubic,
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusMd,
                          ),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary(brightness)
                                : Colors.white.withValues(alpha: 0.25),
                            width: isSelected ? 2.5 : 1.0,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary(brightness)
                                        .withValues(alpha: 0.5),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusMd - 2,
                          ),
                          child: Opacity(
                            opacity: isSelected ? 1.0 : 0.55,
                            child: CachedNetworkImage(
                              imageUrl: widget.images[i],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
