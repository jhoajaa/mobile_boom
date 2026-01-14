import 'package:boom_mobile/core/constants/api_const.dart';
import 'package:boom_mobile/features/boom/data/models/user_model.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final Dio dio;

  ProfileBloc({required this.dio}) : super(ProfileInitial()) {
    on<GetProfileEvent>(_onGetProfile);
    on<UpdateNameEvent>(_onUpdateName);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onGetProfile(
    GetProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        emit(ProfileError("User tidak ditemukan"));
        return;
      }

      final response = await dio.get('${ApiConstants.auth}/${user.uid}');

      if (response.statusCode == 200) {
        final userData = UserModel.fromJson(response.data);
        emit(ProfileLoaded(userData));
      } else {
        emit(ProfileError("Gagal memuat profil"));
      }
    } catch (e) {
      emit(ProfileError("Error: $e"));
    }
  }

  Future<void> _onUpdateName(
    UpdateNameEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;

    try {
      final user = FirebaseAuth.instance.currentUser;

      await dio.post(
        '${ApiConstants.auth}/update-name',
        data: {'uid': user?.uid, 'full_name': event.newName},
      );

      add(GetProfileEvent());
    } catch (e) {
      if (currentState is ProfileLoaded) {
        print("Gagal update nama: $e");
      }
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<ProfileState> emit) async {
    try {
      await FirebaseAuth.instance.signOut();
      emit(LogoutSuccess());
    } catch (e) {
      emit(ProfileError("Gagal keluar: $e"));
    }
  }
}
