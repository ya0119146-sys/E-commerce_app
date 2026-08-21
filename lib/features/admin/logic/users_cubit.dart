import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repos/admin_repository.dart';
import 'users_state.dart';

class UsersCubit extends Cubit<UsersState> {
  final AdminRepository _repository;

  UsersCubit(this._repository) : super(const UsersState());

  Future<void> fetchUsers() async {
    emit(state.copyWith(status: UsersStatus.loading));
    try {
      final users = await _repository.getUsers();
      emit(state.copyWith(status: UsersStatus.loaded, users: users));
    } catch (e) {
      emit(state.copyWith(status: UsersStatus.error, error: e.toString()));
    }
  }
}
