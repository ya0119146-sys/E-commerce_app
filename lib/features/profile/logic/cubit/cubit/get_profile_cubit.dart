import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_commerce/features/profile/data/repos/profile_repo.dart';
import 'package:e_commerce/features/profile/logic/cubit/cubit/get_profile_state.dart';

class GetProfileCubit extends Cubit<GetProfileState> {
  GetProfileCubit(this._repository) : super(GetProfileInitial());
  final ProfileRepository _repository;
  Future<void> getProfile() async {
    emit(GetProfileLoading());
    try {
      final user = await _repository.getProfile();
      emit(GetProfileSuccess(user: user));
    } catch (e) {
      emit(GetProfileError(e.toString()));
    }
  }
}
