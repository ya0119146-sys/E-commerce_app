import 'package:equatable/equatable.dart';

enum AdminStatus { initial, loading, success, error }

class AdminState extends Equatable {
  final AdminStatus status;
  final String? message;
  final String? error;

  const AdminState({
    this.status = AdminStatus.initial,
    this.message,
    this.error,
  });

  AdminState copyWith({
    AdminStatus? status,
    String? message,
    String? error,
  }) {
    return AdminState(
      status: status ?? this.status,
      message: message ?? this.message,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, message, error];
}
