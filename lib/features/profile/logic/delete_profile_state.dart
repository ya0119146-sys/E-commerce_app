import 'package:equatable/equatable.dart';

abstract class DeleteProfileState extends Equatable {
  const DeleteProfileState();

  @override
  List<Object?> get props => [];
}

class DeleteProfileInitial extends DeleteProfileState {}

class DeleteProfileLoading extends DeleteProfileState {}

class DeleteProfileSuccess extends DeleteProfileState {
  @override
  List<Object?> get props => [];
}

class DeleteProfileError extends DeleteProfileState {
  final String message;

  const DeleteProfileError({required this.message});

  @override
  List<Object?> get props => [message];
}
