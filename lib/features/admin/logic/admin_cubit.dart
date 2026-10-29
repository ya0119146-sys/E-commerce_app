import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repos/admin_repository.dart';
import 'admin_state.dart';

class AdminCubit extends Cubit<AdminState> {
  final AdminRepository _repository;

  AdminCubit(this._repository) : super(const AdminState());

  // ─── Category Operations ───

  Future<void> createCategory(FormData data) async {
    emit(state.copyWith(status: AdminStatus.loading));
    try {
      await _repository.createCategory(data);
      emit(
        state.copyWith(
          status: AdminStatus.success,
          message: 'Category created successfully!',
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: AdminStatus.error, error: e.toString()));
    }
  }

  Future<void> updateCategory(String id, FormData data) async {
    emit(state.copyWith(status: AdminStatus.loading));
    try {
      await _repository.updateCategory(id, data);
      emit(
        state.copyWith(
          status: AdminStatus.success,
          message: 'Category updated successfully!',
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: AdminStatus.error, error: e.toString()));
    }
  }

  Future<void> deleteCategory(String id) async {
    emit(state.copyWith(status: AdminStatus.loading));
    try {
      await _repository.deleteCategory(id);
      emit(
        state.copyWith(
          status: AdminStatus.success,
          message: 'Category deleted successfully!',
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: AdminStatus.error, error: e.toString()));
    }
  }

  // ─── Subcategory Operations ───

  Future<void> createSubcategory(dynamic data) async {
    emit(state.copyWith(status: AdminStatus.loading));
    try {
      await _repository.createSubcategory(data);
      emit(
        state.copyWith(
          status: AdminStatus.success,
          message: 'Subcategory created successfully!',
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: AdminStatus.error, error: e.toString()));
    }
  }

  Future<void> updateSubcategory(String id, dynamic data) async {
    emit(state.copyWith(status: AdminStatus.loading));
    try {
      await _repository.updateSubcategory(id, data);
      emit(
        state.copyWith(
          status: AdminStatus.success,
          message: 'Subcategory updated successfully!',
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: AdminStatus.error, error: e.toString()));
    }
  }

  Future<void> deleteSubcategory(String id) async {
    emit(state.copyWith(status: AdminStatus.loading));
    try {
      await _repository.deleteSubcategory(id);
      emit(
        state.copyWith(
          status: AdminStatus.success,
          message: 'Subcategory deleted successfully!',
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: AdminStatus.error, error: e.toString()));
    }
  }

  // ─── Product Operations ───

  Future<void> createProduct(FormData data) async {
    emit(state.copyWith(status: AdminStatus.loading));
    try {
      await _repository.createProduct(data);
      emit(
        state.copyWith(
          status: AdminStatus.success,
          message: 'Product created successfully!',
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: AdminStatus.error, error: e.toString()));
    }
  }

  Future<void> updateProduct(String id, FormData data) async {
    emit(state.copyWith(status: AdminStatus.loading));
    try {
      await _repository.updateProduct(id, data);
      emit(
        state.copyWith(
          status: AdminStatus.success,
          message: 'Product updated successfully!',
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: AdminStatus.error, error: e.toString()));
    }
  }

  Future<void> deleteProduct(String id) async {
    emit(state.copyWith(status: AdminStatus.loading));
    try {
      await _repository.deleteProduct(id);
      emit(
        state.copyWith(
          status: AdminStatus.success,
          message: 'Product deleted successfully!',
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: AdminStatus.error, error: e.toString()));
    }
  }

  // ─── User Operations ───

  Future<void> createUser(FormData data) async {
    emit(state.copyWith(status: AdminStatus.loading));
    try {
      await _repository.createUser(data);
      emit(
        state.copyWith(
          status: AdminStatus.success,
          message: 'User created successfully!',
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: AdminStatus.error, error: e.toString()));
    }
  }

  Future<void> updateUser(String id, FormData data) async {
    emit(state.copyWith(status: AdminStatus.loading));
    try {
      await _repository.updateUser(id, data);
      emit(
        state.copyWith(
          status: AdminStatus.success,
          message: 'User updated successfully!',
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: AdminStatus.error, error: e.toString()));
    }
  }

  Future<void> deleteUser(String id) async {
    emit(state.copyWith(status: AdminStatus.loading));
    try {
      await _repository.deleteUser(id);
      emit(
        state.copyWith(
          status: AdminStatus.success,
          message: 'User deleted successfully!',
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: AdminStatus.error, error: e.toString()));
    }
  }

  void reset() {
    emit(const AdminState());
  }
}
