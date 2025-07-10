import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfa/Repositories/login_repo.dart';
import 'login_event.dart'; 
import 'login_state.dart';
//? emit ??
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginRepository loginRepository; 

  LoginBloc({required this.loginRepository}) : super(LoginInitial()) {
    on<LoginButtonPressed>(_onLoginButtonPressed);
  }

  
  Future<void> _onLoginButtonPressed(
    LoginButtonPressed event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading()); 

    try {
  //* Login Function
      final response = await loginRepository.loginUser(
        event.email,
        event.password,
      );
      if (response.status == 'success' &&
          response.token != null &&
          response.role != null &&
          response.username != null) {
        emit(
          LoginSuccess(
            token: response.token!,
            role: response.role!,
            username: response.username!,
          ),
        );
      } else {
        emit(LoginFailure(error: response.message));
      }
    } catch (e) {
      emit(
        LoginFailure(error: 'An unexpected error occurred: ${e.toString()}'),
      );
    }
  }
}
