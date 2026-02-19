part of 'view_engineers_bloc.dart';

@freezed
class ViewEngineersEvent with _$ViewEngineersEvent {
  const factory ViewEngineersEvent.started() = _Started;
  const factory ViewEngineersEvent.getEngineerDetails({
    required int engineerId,
    required int workId
  }) = _GetEngineerDetails;
}