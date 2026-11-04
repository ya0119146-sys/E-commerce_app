import '../../../app/bottom_nav_shell.dart';

import 'package:flutter/material.dart';

import 'package:flutter_animate/flutter_animate.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';

import '../../../core/constants/app_dimensions.dart';

import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../../core/widgets/product_grid_delegate.dart';
import '../../store/ui/widgets/product_card.dart';

import '../logic/wishlist_cubit.dart';

import '../../../core/localization/app_translations.dart';

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
                Text('Wishlist'.tr(context)),

                if (count > 0)
                  Text(
                    context.isArabic
                        ? '$count ${'items'.tr(context)}'
                        : '$count ${count == 1 ? 'item' : 'items'}',

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
            CustomSnackBar.showError(context, state.errorMessage!.tr(context));
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
                      gridDelegate: ProductGridDelegate.create(context),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => ProductCard(
                          key: ValueKey(state.products[index].id),
                          role: widget.role,
                          product: state.products[index],
                          index: index,
                        ),
                        childCount: state.products.length,
                      ),
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

      child: CustomScrollView(
        slivers: [
          SliverGrid(
            gridDelegate: ProductGridDelegate.create(context),
            delegate: SliverChildBuilderDelegate(
              (_, __) => const ShimmerProductCard(),
              childCount: 6,
            ),
          ),
        ],
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
                      'Your wishlist is empty'.tr(context),

                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 12),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),

                      child: Text(
                        'Save items you love to your wishlist and they will appear here.'
                            .tr(context),

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
                        // Navigate to store home with full navigation shell
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BottomNavShell(
                              role: widget.role,
                              initialIndex: 0,
                            ),
                          ),
                          (route) => false,
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

                      child: Text('Explore Products'.tr(context)),
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
