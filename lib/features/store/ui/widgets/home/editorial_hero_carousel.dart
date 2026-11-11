import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/localization/app_translations.dart';

class _BannerSlideData {
  final String tag;
  final String title;
  final String subtitle;
  final List<Color> gradientColors;
  final String ctaText;

  const _BannerSlideData({
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.gradientColors,
    required this.ctaText,
  });
}

/// Concept 1: Luxury Editorial Auto-Scrolling Hero Banner Carousel.
class EditorialHeroCarousel extends StatefulWidget {
  final VoidCallback onShopNow;

  const EditorialHeroCarousel({super.key, required this.onShopNow});

  @override
  State<EditorialHeroCarousel> createState() => _EditorialHeroCarouselState();
}

class _EditorialHeroCarouselState extends State<EditorialHeroCarousel> {
  late PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;
  bool _isProgrammaticScroll = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_pageController.hasClients) return;
      _isProgrammaticScroll = true;
      _currentPage = (_currentPage + 1) % 3;
      _pageController
          .animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 650),
            curve: Curves.easeInOutCubic,
          )
          .then((_) {
            if (mounted) _isProgrammaticScroll = false;
          });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slides = [
      _BannerSlideData(
        tag: 'Exclusive Collection'.tr(context),
        title: 'New Collection'.tr(context),
        subtitle: 'Discover luxury beauty essentials'.tr(context),
        gradientColors: const [
          Color(0xFF6B204D),
          Color(0xFF4A1236),
          Color(0xFF2E0921),
        ],
        ctaText: 'Shop Now'.tr(context),
      ),
      _BannerSlideData(
        tag: 'Special Offers'.tr(context),
        title: 'Up to 50% Off'.tr(context),
        subtitle: 'On luxury skincare and premium fragrances'.tr(context),
        gradientColors: const [
          Color(0xFF8E3A59),
          Color(0xFF5A1C36),
          Color(0xFF380E21),
        ],
        ctaText: 'Shop Now'.tr(context),
      ),
      _BannerSlideData(
        tag: 'Trending Now'.tr(context),
        title: 'Radiant Beauty'.tr(context),
        subtitle: 'Selected from world-class luxury beauty brands'.tr(context),
        gradientColors: const [
          Color(0xFF531E4D),
          Color(0xFF3B1036),
          Color(0xFF230820),
        ],
        ctaText: 'Shop Now'.tr(context),
      ),
    ];

    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final bannerHeight = (152.0 * (textScale > 1.0 ? textScale : 1.0)).clamp(
      148.0,
      180.0,
    );

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.screenPadding,
        vertical: 8,
      ),
      height: bannerHeight,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (idx) {
              setState(() => _currentPage = idx);
              if (!_isProgrammaticScroll) {
                _startTimer();
              }
            },
            itemCount: slides.length,
            itemBuilder: (context, index) {
              final slide = slides[index];
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: slide.gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: slide.gradientColors[1].withValues(alpha: 0.35),
                      blurRadius: 28,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                  child: Stack(
                    children: [
                      // Background Glowing Shapes
                      Positioned(
                        top: -40,
                        right: -30,
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(
                              0xFFE8A598,
                            ).withValues(alpha: 0.12),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -50,
                        left: -20,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.05),
                          ),
                        ),
                      ),

                      // Content
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Capsule Tag
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2.5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusRound,
                                ),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.25),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.auto_awesome,
                                    size: 10.5,
                                    color: Color(0xFFFFD194),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    slide.tag,
                                    style: const TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 5),

                            // Heading
                            Text(
                              slide.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 2),

                            // Subtitle
                            Text(
                              slide.subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.cairo(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                height: 1.2,
                                color: Colors.white.withValues(alpha: 0.88),
                              ),
                            ),

                            const Spacer(),

                            // Action Row (Shop Now Button + Carousel Dots)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    widget.onShopNow();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 13,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(
                                        AppDimensions.radiusRound,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.12,
                                          ),
                                          blurRadius: 10,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          slide.ctaText,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: slide.gradientColors[0],
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          Directionality.of(context) ==
                                                  TextDirection.rtl
                                              ? Icons.arrow_back_rounded
                                              : Icons.arrow_forward_rounded,
                                          size: 12,
                                          color: slide.gradientColors[0],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: List.generate(slides.length, (
                                    dotIdx,
                                  ) {
                                    final isActive = _currentPage == dotIdx;
                                    return GestureDetector(
                                      onTap: () {
                                        _pageController.animateToPage(
                                          dotIdx,
                                          duration: const Duration(
                                            milliseconds: 400,
                                          ),
                                          curve: Curves.easeInOut,
                                        );
                                      },
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 2.5,
                                        ),
                                        width: isActive ? 16 : 5.5,
                                        height: 4.5,
                                        decoration: BoxDecoration(
                                          color: isActive
                                              ? const Color(0xFFFFD194)
                                              : Colors.white.withValues(
                                                  alpha: 0.4,
                                                ),
                                          borderRadius: BorderRadius.circular(
                                            3,
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
