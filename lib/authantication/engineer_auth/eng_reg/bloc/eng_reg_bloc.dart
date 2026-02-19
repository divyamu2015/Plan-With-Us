import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:house_construction_pro/authantication/engineer_auth/eng_reg/eng_registration_page_model.dart';
import 'package:house_construction_pro/authantication/engineer_auth/eng_reg/eng_registration_page_services.dart';
import 'package:image_picker/image_picker.dart';

part 'eng_reg_event.dart';
part 'eng_reg_state.dart';
part 'eng_reg_bloc.freezed.dart';

class EngRegBloc extends Bloc<EngRegEvent, EngRegState> {
  EngRegBloc() : super(_Initial()) {
    on<EngRegEvent>((event, emit) async {
      
      if (event is _EngineerRegister) {
        emit(const EngRegState.loading());
        try {
          final response = await engineerRegister(
            name: event.name,
            password: event.password,
            email: event.email,
            phone: int.parse(event.phone),
            address: event.address,
            profilePic: event.profilePic,
            workCertificate: event.workCertificate,
          );
          emit(EngRegState.success(response: response));
        } catch (e) {
          emit(EngRegState.error(error: e.toString()));
        }
      }
    });
  }
}
