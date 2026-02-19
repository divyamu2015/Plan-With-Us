part of 'request_bloc.dart';

@freezed
class RequestEvent with _$RequestEvent {
  const factory RequestEvent.started() = _Started;
  const factory RequestEvent.getUserDetails({
    required int userId,
    required int requestId,
  }) = _getUserDetails;
  
}