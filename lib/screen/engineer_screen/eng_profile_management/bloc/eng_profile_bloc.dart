import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:house_construction_pro/screen/engineer_screen/eng_profile_management/eng_profile_model.dart';
import 'package:house_construction_pro/screen/engineer_screen/eng_profile_management/eng_profile_service.dart';
import 'package:image_picker/image_picker.dart';

part 'eng_profile_event.dart';
part 'eng_profile_state.dart';
part 'eng_profile_bloc.freezed.dart';

class EngProfileBloc extends Bloc<EngProfileEvent, EngProfileState> {
  EngProfileBloc() : super(_Initial()) {
    on<EngProfileEvent>((event, emit) async {
      if (event is _EngProfileMan) {
        emit(const EngProfileState.loading());
        try {
          final response = await getEngineerProfile(
            profilePic: event.profilePic,
            name: event.name,
            email: event.email,
            password: event.password,
            address: event.address,
            status: event.status,
            phone: event.phone,
            emploId: event.emplId,
          );
          emit(EngProfileState.success(response: response));
        } catch (e) {
          emit(EngProfileState.error(error: e.toString()));
        }
      }
    });
  }
}
