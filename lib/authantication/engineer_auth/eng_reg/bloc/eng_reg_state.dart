part of 'eng_reg_bloc.dart';

@freezed
class EngRegState with _$EngRegState {
  const factory EngRegState.initial() = _Initial;
  const factory EngRegState.loading() = _Loading;
  const factory EngRegState.success({
    required EngineeringRegModel response,
  }) = _Success;
  const factory EngRegState.error({required String error}) = _Error;
  
  
  
}
