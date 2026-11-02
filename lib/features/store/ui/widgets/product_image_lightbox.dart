import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

/// Full-screen luxury image gallery with pinch-to-zoom, pan, double-tap zoom,
/// horizontal swipe navigation, and bottom thumbnail selector.
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
  static void show(
    BuildContext context, {
    required List<String> images,
    int initialIndex = 0,
    required String heroTagPrefix,
  }) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
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

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.96),
      body: Stack(
        children: [
          // ─── Photo View Gallery ───
          PhotoViewGallery.builder(
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
                imageProvider: CachedNetworkImageProvider(widget.images[index]),
                initialScale: PhotoViewComputedScale.contained,
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 3.5,
                heroAttributes: PhotoViewHeroAttributes(
                  tag: '${widget.heroTagPrefix}_$index',
                ),
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

          // ─── Top Header Bar ───
          PositionBar(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Close Button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 44,
                    height: 44,
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
                      size: 22,
                    ),
                  ),
                ),

                // Image Counter Pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
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
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                ),

                // Spacer balance
                const SizedBox(width: 44),
              ],
            ),
          ),

          // ─── Bottom Thumbnail Strip & Zoom Hint ───
          PositionBar(
            bottom: MediaQuery.of(context).padding.bottom + 16,
            left: 0,
            right: 0,
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
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Pinch or double tap to zoom',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Thumbnails
                if (widget.images.length > 1)
                  SizedBox(
                    height: 56,
                    child: Center(
                      child: ListView.separated(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
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
                              width: 52,
                              height: 52,
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
                                  opacity: isSelected ? 1.0 : 0.6,
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
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper for positioned widgets
class PositionBar extends StatelessWidget {
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final Widget child;

  const PositionBar({
    super.key,
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: child,
    );
  }
}
