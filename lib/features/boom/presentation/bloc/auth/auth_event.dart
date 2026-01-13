import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object> get props => [];
}
class LoginRequested extends AuthEvent {
  final String email, password;
  LoginRequested(this.email, this.password);
}
class RegisterRequested extends AuthEvent {
  final String email, password;
  RegisterRequested(this.email, this.password);
}