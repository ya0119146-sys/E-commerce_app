import 'package:e_commerce/features/store/ui/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../store/ui/widgets/product_card.dart';
import '../logic/wishlist_cubit.dart';

/// Wishlist screen showing all favorited products.
class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key, required this.role});
  final String role;

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  @override
  void initState() {
    super.initState();
    context.read<WishlistCubit>().fetchWishlist();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<WishlistCubit, WishlistState>(
          builder: (context, state) {
            final count = state.products.length;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Wishlist'),
                if (count > 0)
                  Text(
                    '$count ${count == 1 ? 'item' : 'items'}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.secondary(brightness),
                      fontWeight: FontWeight.w600,
                    ),
                  ).animate().fadeIn(),
              ],
            );
          },
        ),
      ),
      body: BlocListener<WishlistCubit, WishlistState>(
        listenWhen: (prev, curr) =>
            prev.status != curr.status && curr.status == WishlistStatus.error,
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        child: RefreshIndicator(
          onRefresh: () => context.read<WishlistCubit>().fetchWishlist(),
          color: AppColors.primary(brightness),
          child: BlocBuilder<WishlistCubit, WishlistState>(
            builder: (context, state) {
              if (state.status == WishlistStatus.loading &&
                  state.products.isEmpty) {
                return _buildLoadingGrid();
              }

              if (state.products.isEmpty) {
                return _buildEmptyState(context, brightness);
              }

              return CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(AppDimensions.screenPadding),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 220,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.62,
                          ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return ProductCard(
                          role: widget.role,
                          product: state.products[index],
                          index: index,
                        );
                      }, childCount: state.products.length),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.screenPadding),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.62,
        ),
        itemCount: 6,
        itemBuilder: (_, __) => const ShimmerProductCard(),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, Brightness brightness) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child:
            Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppColors.primary(
                          brightness,
                        ).withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.favorite_border_rounded,
                        size: 80,
                        color: AppColors.primary(
                          brightness,
                        ).withValues(alpha: 0.4),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Your wishlist is empty',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'Save items you love to your wishlist and they\'ll show up here.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.foreground(
                            brightness,
                          ).withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate back or to store
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => HomeScreen(role: widget.role),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary(brightness),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusRound,
                          ),
                        ),
                      ),
                      child: const Text('Explore Products'),
                    ),
                  ],
                )
                .animate()
                .fade(duration: 600.ms)
                .scale(
                  begin: const Offset(0.9, 0.9),
                  curve: Curves.easeOutBack,
                ),
      ),
    );
  }
}
