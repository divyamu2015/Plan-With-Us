part of 'engineer_bio_bloc.dart';

@freezed
class EngineerBioState with _$EngineerBioState {
  const factory EngineerBioState.initial() = _Initial;
  const factory EngineerBioState.loading() = _Loading;
  const factory EngineerBioState.success({required EngineerBioModel response}) = _Success;
  const factory EngineerBioState.error({
    required String error
  }) = _Error;
  
  
  
}
