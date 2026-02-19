part of 'property_input_bloc.dart';

@freezed
class PropertyInputEvent with _$PropertyInputEvent {
  const factory PropertyInputEvent.started() = _Started;
  const factory PropertyInputEvent.propertySub(
    {
      required int userId,
      required double sgft,
      required double cent,
      required double amount,
      required int category,
    }
  ) = _PropertySub;
  
}