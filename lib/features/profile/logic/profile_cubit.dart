import 'package:e_commerce/features/profile/data/repos/profile_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _repository;

  ProfileCubit(this._repository) : super(ProfileInitial());

  Future<void> updateProfile({String? name, String? imagePath}) async {
    emit(ProfileLoading());
    try {
      final user = await _repository.updateProfile(
        name: name,
        imagePath: imagePath,
      );
      emit(
        ProfileSuccess(user: user, message: 'Profile updated successfully!'),
      );
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
