part of 'eng_profile_bloc.dart';

@freezed
class EngProfileEvent with _$EngProfileEvent {
  const factory EngProfileEvent.started() = _Started;
  const factory EngProfileEvent.engProfileMan(
    {
      required String name,
      required String email,
      required int phone,
      required String address,
      required String password,
      required XFile profilePic,
      required String status,
      required int emplId


    }
  ) = _EngProfileMan;
  
}