import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/category_model.dart';
import '../data/repos/category_repository.dart';
import '../../../core/network/api_exception.dart';

part 'categories_state.dart';

/// Categories Cubit — fetches and manages categories.
class CategoriesCubit extends Cubit<CategoriesState> {
  final CategoryRepository _repository;

  CategoriesCubit(this._repository) : super(const CategoriesState());

  /// Fetch all categories.
  Future<void> fetchCategories() async {
    emit(state.copyWith(status: CategoriesStatus.loading));
    try {
      final categories = await _repository.getCategories();
      emit(state.copyWith(
        status: CategoriesStatus.loaded,
        categories: categories,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: CategoriesStatus.error,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: CategoriesStatus.error,
        errorMessage: 'Failed to load categories',
      ));
    }
  }

  /// Select a category.
  void selectCategory(String? categoryId) {
    emit(state.copyWith(selectedCategoryId: categoryId ?? ''));
  }
}
