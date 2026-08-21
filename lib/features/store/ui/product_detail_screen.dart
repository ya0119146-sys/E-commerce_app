import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/star_rating.dart';
import '../../../core/widgets/hero_button.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../cart/logic/cart_cubit.dart';
import '../../wishlist/logic/wishlist_cubit.dart';
import '../../reviews/logic/review_cubit.dart';
import '../../reviews/ui/widgets/review_list_widget.dart';
import '../data/models/product_model.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReviewCubit>().fetchProductReviews(widget.product.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final product = widget.product;
    final allImages = [
      if (product.cover != null) product.cover!,
      ...product.images,
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ─── Image Header ───
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height * 0.45,
            pinned: true,
            backgroundColor: AppColors.background(brightness),
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.card(brightness).withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new, size: 18),
              ),
            ),
            actions: [
              BlocBuilder<WishlistCubit, WishlistState>(
                builder: (context, state) {
                  final isFav = state.isInWishlist(product.id);
                  return GestureDetector(
                    onTap: () => context.read<WishlistCubit>().toggleWishlist(
                      product.id,
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.card(
                          brightness,
                        ).withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        size: 20,
                        color: isFav
                            ? AppColors.primary(brightness)
                            : AppColors.foreground(brightness),
                      ),
                    ),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: allImages.isNotEmpty
                  ? PageView.builder(
                      onPageChanged: (i) =>
                          setState(() => _selectedImageIndex = i),
                      itemCount: allImages.length,
                      itemBuilder: (_, i) => CachedNetworkImage(
                        imageUrl: allImages[i],
                        fit: BoxFit.cover,
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
                    )
                  : Container(
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
            ),
          ),

          // ─── Image Indicators ───
          if (allImages.length > 1)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    allImages.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: _selectedImageIndex == i ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _selectedImageIndex == i
                            ? AppColors.secondary(brightness)
                            : AppColors.border(brightness),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // ─── Product Info ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category
                  if (product.category != null) ...[
                    Text(
                      product.category!.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        letterSpacing: 1.5,
                        color: AppColors.accent(brightness),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Title
                  Text(
                        product.name,
                        style: Theme.of(context).textTheme.headlineLarge,
                      )
                      .animate()
                      .fade(duration: 500.ms)
                      .moveY(begin: 15, end: 0, duration: 500.ms),

                  const SizedBox(height: 12),

                  // Rating
                  if (product.ratingAvg > 0)
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

                  const SizedBox(height: 16),

                  // Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${product.displayPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondary(brightness),
                        ),
                      ),
                      if (product.onSale) ...[
                        const SizedBox(width: 12),
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.foreground(
                              brightness,
                            ).withValues(alpha: 0.4),
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent(brightness),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '-${product.discountPercent.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ).animate().fade(duration: 400.ms, delay: 250.ms),

                  const SizedBox(height: 24),

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
                            ? 'In Stock (${product.quantity})'
                            : 'Out of Stock',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: product.inStock
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                    ],
                  ),

                  if (product.description != null) ...[
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.description!,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(height: 1.6),
                    ).animate().fade(duration: 400.ms, delay: 350.ms),
                  ],

                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),
                  ReviewListWidget(productId: product.id, role: widget.role),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      // ─── Bottom Action Bar ───
      bottomNavigationBar: widget.role != 'admin'
          ? Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              decoration: BoxDecoration(
                color: AppColors.card(brightness),
                border: Border(
                  top: BorderSide(
                    color: AppColors.border(brightness).withValues(alpha: 0.5),
                  ),
                ),
              ),
              child: HeroButton(
                text: product.inStock ? 'Add to Cart' : 'Out of Stock',
                icon: Icons.shopping_bag_outlined,
                onPressed: product.inStock
                    ? () {
                        context.read<CartCubit>().addToCart(product.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Added to cart ✨'),
                            duration: Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    : null,
              ),
            )
          : Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              decoration: BoxDecoration(
                color: AppColors.card(brightness),
                border: Border(
                  top: BorderSide(
                    color: AppColors.border(brightness).withValues(alpha: 0.5),
                  ),
                ),
              ),
              child: HeroButton(
                text: product.inStock ? 'In Stock' : 'Out of Stock',
                icon: Icons.shopping_bag_outlined,
                onPressed: null,
              ),
            ),
    );
  }
}
