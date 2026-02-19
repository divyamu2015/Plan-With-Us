part of 'eng_reg_bloc.dart';

@freezed
class EngRegEvent with _$EngRegEvent {
  const factory EngRegEvent.started() = _Started;
  const factory EngRegEvent.engineerRegister({
     required String name,
    required String email,
    required String phone,
    required String password,
    required String address,
    required XFile profilePic, // Add profile picture file
    required XFile workCertificate,
  }) = _EngineerRegister;
  
}