part of 'categories_cubit.dart';

enum CategoriesStatus { initial, loading, loaded, error }

class CategoriesState extends Equatable {
  final CategoriesStatus status;
  final List<CategoryModel> categories;
  final String? selectedCategoryId;
  final String? errorMessage;

  const CategoriesState({
    this.status = CategoriesStatus.initial,
    this.categories = const [],
    this.selectedCategoryId,
    this.errorMessage,
  });

  CategoriesState copyWith({
    CategoriesStatus? status,
    List<CategoryModel>? categories,
    String? selectedCategoryId,
    String? errorMessage,
  }) {
    return CategoriesState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, categories.length, selectedCategoryId];
}
