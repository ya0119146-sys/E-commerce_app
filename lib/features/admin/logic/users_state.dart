import 'package:equatable/equatable.dart';
import '../../../features/auth/data/models/user_model.dart';

enum UsersStatus { initial, loading, loaded, error }

class UsersState extends Equatable {
  final UsersStatus status;
  final List<UserModel> users;
  final String? error;

  const UsersState({
    this.status = UsersStatus.initial,
    this.users = const [],
    this.error,
  });

  UsersState copyWith({
    UsersStatus? status,
    List<UserModel>? users,
    String? error,
  }) {
    return UsersState(
      status: status ?? this.status,
      users: users ?? this.users,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, users, error];
}
