import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../logic/products_cubit.dart';
import 'widgets/product_card.dart';

/// Search screen with debounced text input and product results.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.role});
  final String role;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  Timer? _searchDebounce;
  String _lastSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchFocus.requestFocus();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    final trimmedQuery = query.trim();
    if (trimmedQuery == _lastSearchQuery) return;

    _lastSearchQuery = trimmedQuery;

    if (trimmedQuery.isEmpty) {
      context.read<ProductsCubit>().clearSearch();
      return;
    }

    context.read<ProductsCubit>().search(trimmedQuery);
  }

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      _onSearch(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Container(
          height: 42,
          margin: const EdgeInsets.only(right: 16),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocus,
            onChanged: _onSearchChanged,
            onSubmitted: _onSearch,
            textInputAction: TextInputAction.search,
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Search products...',
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
                borderSide: BorderSide(color: AppColors.border(brightness)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
                borderSide: BorderSide(color: AppColors.border(brightness)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
                borderSide: BorderSide(
                  color: AppColors.primary(brightness),
                  width: 1.5,
                ),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.search, size: 20),
                onPressed: () {
                  _searchDebounce?.cancel();
                  _onSearch(_searchController.text);
                },
              ),
              filled: true,
              fillColor: AppColors.muted(brightness).withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
      body: BlocBuilder<ProductsCubit, ProductsState>(
        builder: (context, state) {
          if (state.status == ProductsStatus.loading) {
            return Padding(
              padding: const EdgeInsets.all(AppDimensions.screenPadding),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.58,
                ),
                itemCount: 6,
                itemBuilder: (_, __) => const ShimmerProductCard(),
              ),
            );
          }

          if (state.products.isEmpty &&
              state.status != ProductsStatus.initial) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 56,
                    color: AppColors.foreground(
                      brightness,
                    ).withValues(alpha: 0.2),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No products found',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Try a different search term',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(AppDimensions.screenPadding),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.58,
              ),
              itemCount: state.products.length,
              itemBuilder: (_, index) => ProductCard(
                role: widget.role,
                product: state.products[index],
                index: index,
              ),
            ),
          );
        },
      ),
    );
  }
}
