import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:house_construction_pro/authantication/user_authentication/registration_screen/registration_page_model.dart';
import 'package:house_construction_pro/authantication/user_authentication/registration_screen/registration_page_services.dart';

part 'register_bloc_bloc.freezed.dart';
part 'register_bloc_event.dart';
part 'register_bloc_state.dart';

class RegisterBlocBloc extends Bloc<RegisterBlocEvent, RegisterBlocState> {
  RegisterBlocBloc() : super(RegisterBlocState.initial()) {
    on<RegisterBlocEvent>((event, emit) async {
      if (event is _UserRegister) {
        emit(const RegisterBlocState.loading());
        try {
          final response = await userRegister(
            name: event.name,
            password: event.password,
            email: event.email,
            phone: event.phone,
            address: event.address,
            //id: event.id,
          );
          emit(RegisterBlocState.success(response: response));
        } catch (e) {
          emit(RegisterBlocState.error(error: e.toString()));
         // print('error:${e.toString()}');
        }
      }
    });
  }
}
