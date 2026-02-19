part of 'register_bloc_bloc.dart';

@freezed
class RegisterBlocState with _$RegisterBlocState {
  const factory RegisterBlocState.initial() = _Initial;
  const factory RegisterBlocState.loading() = _Loading;
  const factory RegisterBlocState.success({
    required UserRegistrationModel response,
  }) = _Success;
  const factory RegisterBlocState.error({required String error}) = _Error;
}
