import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../logic/products_cubit.dart';
import 'widgets/product_card.dart';
import '../../../core/localization/app_translations.dart';

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
  final _scrollController = ScrollController();
  Timer? _searchDebounce;
  String _lastSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchDebounce?.cancel();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= 250) {
      context.read<ProductsCubit>().loadMore();
    }
  }

  void _executeSearch(String query) {
    final trimmedQuery = query.trim();
    if (trimmedQuery == _lastSearchQuery) return;

    _lastSearchQuery = trimmedQuery;

    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0.0);
    }

    if (trimmedQuery.isEmpty) {
      context.read<ProductsCubit>().clearSearch();
      return;
    }

    context.read<ProductsCubit>().search(trimmedQuery);
  }

  void _onSubmitted(String query) {
    _searchDebounce?.cancel();
    _searchFocus.unfocus();
    _executeSearch(query);
  }

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      _executeSearch(query);
    });
    setState(() {});
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
            onSubmitted: _onSubmitted,
            textInputAction: TextInputAction.search,
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Search products...'.tr(context),
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
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        _executeSearch('');
                        setState(() {});
                      },
                    ),
                  IconButton(
                    icon: const Icon(Icons.search, size: 20),
                    onPressed: () {
                      _searchDebounce?.cancel();
                      _onSubmitted(_searchController.text);
                    },
                  ),
                ],
              ),
              filled: true,
              fillColor: AppColors.muted(brightness).withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
      body: BlocConsumer<ProductsCubit, ProductsState>(
        listener: (context, state) {
          if (state.status == ProductsStatus.loading &&
              _scrollController.hasClients &&
              _scrollController.offset > 0) {
            _scrollController.jumpTo(0.0);
          }
        },
        builder: (context, state) {
          if (state.status == ProductsStatus.loading) {
            return Padding(
              padding: const EdgeInsets.all(AppDimensions.screenPadding),
              child: CustomScrollView(
                slivers: [
                  SliverMasonryGrid.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childCount: 6,
                    itemBuilder: (_, __) => const ShimmerProductCard(),
                  ),
                ],
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
                    'No products found'.tr(context),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Try a different search term'.tr(context),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            key: ValueKey('search_scroll_${_lastSearchQuery}_${state.products.length}'),
            controller: _scrollController,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(AppDimensions.screenPadding),
                sliver: SliverMasonryGrid.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childCount: state.products.length,
                  itemBuilder: (_, index) => ProductCard(
                    key: ValueKey(state.products[index].id),
                    role: widget.role,
                    product: state.products[index],
                    index: index,
                  ),
                ),
              ),
              if (state.status == ProductsStatus.loadingMore)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.primary(brightness),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
