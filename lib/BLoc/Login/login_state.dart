
import 'package:equatable/equatable.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object> get props => [];
}

//* Initial State
class LoginInitial extends LoginState {}

//*Loading State
class LoginLoading extends LoginState {}

//*Success State
class LoginSuccess extends LoginState {
  final String token;
  final String role;
  final String username;

  const LoginSuccess({
    required this.token,
    required this.role,
    required this.username,
  });

  @override
  List<Object> get props => [token, role, username];
}

class LoginFailure extends LoginState {
  final String error;

  const LoginFailure({required this.error});

  @override
  List<Object> get props => [error];
}
