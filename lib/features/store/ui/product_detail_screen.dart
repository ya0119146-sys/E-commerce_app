import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/localization/app_translations.dart';
import '../../../core/utils/whatsapp_helper.dart';
import '../../../core/widgets/star_rating.dart';
import '../../reviews/logic/review_cubit.dart';
import '../../reviews/ui/widgets/review_list_widget.dart';
import '../data/models/category_model.dart';
import '../data/models/product_model.dart';
import '../logic/categories_cubit.dart';
import 'widgets/product_detail/product_bottom_action_bar.dart';
import 'widgets/product_detail/product_category_breadcrumbs.dart';
import 'widgets/product_detail/product_description_card.dart';
import 'widgets/product_detail/product_detail_app_bar.dart';
import 'widgets/product_detail/product_price_section.dart';
import 'widgets/product_detail/product_size_capsule.dart';
import 'widgets/product_detail/product_thumbnail_carousel.dart';
import 'widgets/product_image_lightbox.dart';

/// Full-screen product detail with image, info, and Add to Cart.
class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;
  final String role;

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.role,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _selectedImageIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReviewCubit>().fetchProductReviews(widget.product.id);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _openLightbox(List<String> allImages) async {
    final newIndex = await ProductImageLightbox.show(
      context,
      images: allImages,
      initialIndex: _selectedImageIndex,
      heroTagPrefix: 'product_${widget.product.id}',
    );
    if (newIndex != null && newIndex != _selectedImageIndex && mounted) {
      _pageController.jumpToPage(newIndex);
      setState(() => _selectedImageIndex = newIndex);
    }
  }

  void _launchProductWhatsApp(BuildContext context) {
    WhatsAppHelper.inquireAboutProduct(
      productName: widget.product.name,
      price: widget.product.displayPrice,
      originalPrice: widget.product.price,
      onSale: widget.product.onSale,
      size: widget.product.size,
      category: widget.product.category,
      subcategory: widget.product.subcategory,
      productId: widget.product.id,
      inStock: widget.product.inStock,
      isArabic: context.isArabic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final allImages = [
      if (product.cover != null) product.cover!,
      ...product.images,
    ];

    // ─── Resolve Category & Subcategory Names ───
    String? categoryName = product.category;
    if (categoryName == null ||
        categoryName.trim().isEmpty ||
        ProductModel.isHexObjectId(categoryName.trim())) {
      if (product.categoryId != null && product.categoryId!.isNotEmpty) {
        try {
          final cats = context.read<CategoriesCubit>().state.categories;
          final match = cats.firstWhere(
            (c) => c.id == product.categoryId,
            orElse: () => const CategoryModel(id: '', name: ''),
          );
          categoryName = match.name.isNotEmpty ? match.name : null;
        } catch (_) {
          categoryName = null;
        }
      } else {
        categoryName = null;
      }
    }

    String? subcategoryName = product.subcategory;
    if (subcategoryName != null &&
        (subcategoryName.trim().isEmpty ||
            ProductModel.isHexObjectId(subcategoryName.trim()))) {
      subcategoryName = null;
    }

    final isSameCategory =
        categoryName != null &&
        subcategoryName != null &&
        categoryName.trim().toLowerCase() ==
            subcategoryName.trim().toLowerCase();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          ProductDetailAppBar(
            product: product,
            allImages: allImages,
            selectedImageIndex: _selectedImageIndex,
            pageController: _pageController,
            onPageChanged: (i) => setState(() => _selectedImageIndex = i),
            onOpenLightbox: () => _openLightbox(allImages),
            onWhatsAppTap: () => _launchProductWhatsApp(context),
          ),

          if (allImages.length > 1)
            ProductThumbnailCarousel(
              allImages: allImages,
              selectedImageIndex: _selectedImageIndex,
              pageController: _pageController,
            ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.screenPadding,
                10,
                AppDimensions.screenPadding,
                AppDimensions.screenPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (categoryName != null || subcategoryName != null) ...[
                    ProductCategoryBreadcrumbs(
                      categoryName: categoryName,
                      categoryId: product.categoryId,
                      subcategoryName: subcategoryName,
                      isSameCategory: isSameCategory,
                    ),
                    const SizedBox(height: 6),
                  ],

                  // Title
                  Text(
                        product.name,
                        style: Theme.of(context).textTheme.headlineLarge,
                      )
                      .animate()
                      .fade(duration: 500.ms)
                      .moveY(begin: 15, end: 0, duration: 500.ms),

                  const SizedBox(height: 6),

                  // Rating
                  if (product.ratingAvg > 0) ...[
                    Row(
                      children: [
                        StarRating(rating: product.ratingAvg),
                        const SizedBox(width: 8),
                        Text(
                          '${product.ratingAvg.toStringAsFixed(1)} (${product.ratingCount})',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ).animate().fade(duration: 400.ms, delay: 150.ms),
                    const SizedBox(height: 8),
                  ] else
                    const SizedBox(height: 4),

                  ProductPriceSection(product: product),

                  const SizedBox(height: 10),

                  if (product.size != null &&
                      product.size!.trim().isNotEmpty) ...[
                    ProductSizeCapsule(size: product.size!),
                    const SizedBox(height: 8),
                  ],

                  // Stock status
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: product.inStock
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        product.inStock
                            ? '${'in_stock'.tr(context)} (${product.quantity})'
                            : 'out_of_stock'.tr(context),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: product.inStock
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                    ],
                  ),

                  if (product.description != null &&
                      product.description!.trim().isNotEmpty) ...[
                    const SizedBox(height: 10),
                    ProductDescriptionCard(description: product.description!),
                  ],

                  const SizedBox(height: 14),
                  const Divider(height: 16),
                  const SizedBox(height: 8),
                  ReviewListWidget(productId: product.id, role: widget.role),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: ProductBottomActionBar(
        product: product,
        role: widget.role,
      ),
    );
  }
}
