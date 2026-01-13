import 'package:boom_mobile/features/boom/domain/repositories/auth_repository.dart';
import 'package:boom_mobile/features/boom/presentation/bloc/auth/auth_event.dart';
import 'package:boom_mobile/features/boom/presentation/bloc/auth/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;

  AuthBloc(this.repository) : super(AuthInitial()) {
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      final result = await repository.login(event.email, event.password);
      result.fold(
        (failure) => emit(AuthFailure(failure)),
        (user) => emit(AuthSuccess(user)),
      );
    });

    on<RegisterRequested>((event, emit) async {
      emit(AuthLoading());
      final result = await repository.register(event.email, event.password);
      result.fold(
        (failure) => emit(AuthFailure(failure)),
        (user) => emit(AuthSuccess(user)),
      );
    });
  }
}
