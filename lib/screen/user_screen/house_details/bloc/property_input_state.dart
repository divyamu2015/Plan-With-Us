part of 'property_input_bloc.dart';

@freezed
class PropertyInputState with _$PropertyInputState {
  const factory PropertyInputState.initial() = _Initial;
  const factory PropertyInputState.loading() = _Loading;
  const factory PropertyInputState.success({required PropertyDetailModel response}) = _Success;
  const factory PropertyInputState.error({
    required String error
  }) = _Error;
  
  
}
