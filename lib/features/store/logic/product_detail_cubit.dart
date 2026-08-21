import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/product_model.dart';
import '../data/repos/product_repository.dart';
import '../../../core/network/api_exception.dart';

part 'product_detail_state.dart';

/// Product Detail Cubit — fetches a single product's full details.
class ProductDetailCubit extends Cubit<ProductDetailState> {
  final ProductRepository _repository;

  ProductDetailCubit(this._repository) : super(ProductDetailInitial());

  /// Fetch product details by ID.
  Future<void> fetchProduct(String productId) async {
    emit(ProductDetailLoading());
    try {
      final product = await _repository.getProductById(productId);
      emit(ProductDetailLoaded(product));
    } on ApiException catch (e) {
      emit(ProductDetailError(e.message));
    } catch (_) {
      emit(const ProductDetailError('Failed to load product details'));
    }
  }
}
