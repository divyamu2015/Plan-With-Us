part of 'eng_profile_bloc.dart';

@freezed
class EngProfileState with _$EngProfileState {
  const factory EngProfileState.initial() = _Initial;
  const factory EngProfileState.loading() = _Loading;
  const factory EngProfileState.success({required EngiProManagModel response}) = _Success;
  const factory EngProfileState.error({required String error}) = _Error;
  
  
  
}
