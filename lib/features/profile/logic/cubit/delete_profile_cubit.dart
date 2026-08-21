import 'package:e_commerce/core/network/dio_client.dart';
import 'package:e_commerce/features/profile/logic/cubit/delete_profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repos/profile_repo.dart';
import '../../../../core/network/api_exception.dart';

class DeleteProfileCubit extends Cubit<DeleteProfileState> {
  DeleteProfileCubit(this._repository, this._client)
    : super(DeleteProfileInitial());
  final ProfileRepository _repository;
  final DioClient _client;

  // /// Delete profile.
  Future<void> deleteProfile() async {
    emit(DeleteProfileLoading());
    try {
      await _repository.deleteProfile();
      await _client.clearToken();
      emit(DeleteProfileSuccess());
    } on ApiException catch (e) {
      emit(DeleteProfileError(message: e.message));
    } catch (e) {
      emit(const DeleteProfileError(message: 'Failed to delete profile.'));
    }
  }
}
