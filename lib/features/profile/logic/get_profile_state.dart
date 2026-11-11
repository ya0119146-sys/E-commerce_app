import 'package:e_commerce/features/auth/data/models/user_model.dart';
import 'package:equatable/equatable.dart';

abstract class GetProfileState extends Equatable {
  const GetProfileState();

  @override
  List<Object?> get props => [];
}

class GetProfileInitial extends GetProfileState {}

class GetProfileLoading extends GetProfileState {}

class GetProfileSuccess extends GetProfileState {
  final String? message;
  final UserModel user;
  const GetProfileSuccess({this.message, required this.user});

  @override
  List<Object?> get props => [message];
}

class GetProfileError extends GetProfileState {
  final String message;

  const GetProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
