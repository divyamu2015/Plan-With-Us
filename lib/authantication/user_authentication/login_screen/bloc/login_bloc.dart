import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:house_construction_pro/authantication/user_authentication/login_screen/login_model_page.dart';
import 'package:house_construction_pro/authantication/user_authentication/login_screen/login_service_page.dart';

part 'login_event.dart';
part 'login_state.dart';
part 'login_bloc.freezed.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(_Initial()) {
    on<LoginEvent>((event, emit) async {
      if (event is _UserLogin) {
        emit(const LoginState.loading());
        try {
          final response = await userLogin(
            role: event.role,
            password: event.password,
            email: event.email,
          //  userId: event.userI,
          );
          emit(LoginState.success(response: response));
        } catch (e) {
          emit(LoginState.error(error: e.toString()));
        }
      }
    });
  }
}
