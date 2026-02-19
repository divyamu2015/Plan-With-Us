part of 'request_bloc.dart';

@freezed
class RequestState with _$RequestState {
  const factory RequestState.initial() = _Initial;
  const factory RequestState.loading() = _Loading;
  const factory RequestState.success({
    required GetPropertyInputModel response,
  }) = _Success;
  const factory RequestState.error({required String error}) = _Error;
}
