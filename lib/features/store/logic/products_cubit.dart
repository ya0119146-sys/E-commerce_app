import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/product_model.dart';
import '../data/repos/product_repository.dart';
import '../../../core/network/api_exception.dart';

part 'products_state.dart';

/// Products Cubit — manages product listing, search, and pagination.
class ProductsCubit extends Cubit<ProductsState> {
  final ProductRepository _repository;

  ProductsCubit(this._repository) : super(const ProductsState());

  /// Fetch products (initial load or refresh).
  Future<void> fetchProducts({
    String? keyword,
    String? category,
    String? sort,
    bool refresh = false,
  }) async {
    if (refresh) {
      emit(state.copyWith(
        status: ProductsStatus.loading,
        products: [],
        page: 1,
        hasMore: true,
      ));
    } else {
      emit(state.copyWith(status: ProductsStatus.loading));
    }

    try {
      final products = await _repository.getProducts(
        keyword: keyword ?? state.keyword,
        category: category ?? state.category,
        sort: sort ?? state.sort,
        page: 1,
      );
      emit(state.copyWith(
        status: ProductsStatus.loaded,
        products: products,
        page: 1,
        hasMore: products.length >= 10,
        keyword: keyword,
        category: category,
        sort: sort,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: ProductsStatus.error,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: ProductsStatus.error,
        errorMessage: 'Failed to load products',
      ));
    }
  }

  /// Load next page of products.
  Future<void> loadMore() async {
    if (!state.hasMore || state.status == ProductsStatus.loadingMore) return;

    emit(state.copyWith(status: ProductsStatus.loadingMore));

    try {
      final nextPage = state.page + 1;
      final newProducts = await _repository.getProducts(
        keyword: state.keyword,
        category: state.category,
        sort: state.sort,
        page: nextPage,
      );
      emit(state.copyWith(
        status: ProductsStatus.loaded,
        products: [...state.products, ...newProducts],
        page: nextPage,
        hasMore: newProducts.length >= 10,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: ProductsStatus.error,
        errorMessage: e.message,
      ));
    }
  }

  /// Search products by keyword.
  Future<void> search(String keyword) async {
    await fetchProducts(keyword: keyword, refresh: true);
  }

  /// Clear search and reload.
  Future<void> clearSearch() async {
    emit(state.copyWith(keyword: ''));
    await fetchProducts(refresh: true);
  }
}
