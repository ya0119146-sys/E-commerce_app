part of 'products_cubit.dart';

enum ProductsStatus { initial, loading, loaded, loadingMore, error }

class ProductsState extends Equatable {
  final ProductsStatus status;
  final List<ProductModel> products;
  final int page;
  final bool hasMore;
  final String? keyword;
  final String? category;
  final String? sort;
  final String? errorMessage;

  const ProductsState({
    this.status = ProductsStatus.initial,
    this.products = const [],
    this.page = 1,
    this.hasMore = true,
    this.keyword,
    this.category,
    this.sort,
    this.errorMessage,
  });

  ProductsState copyWith({
    ProductsStatus? status,
    List<ProductModel>? products,
    int? page,
    bool? hasMore,
    String? keyword,
    String? category,
    String? sort,
    String? errorMessage,
  }) {
    return ProductsState(
      status: status ?? this.status,
      products: products ?? this.products,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      keyword: keyword ?? this.keyword,
      category: category ?? this.category,
      sort: sort ?? this.sort,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    products.length,
    page,
    hasMore,
    keyword,
    category,
    sort,
  ];
}
