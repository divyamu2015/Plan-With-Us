part of 'view_engineers_bloc.dart';

@freezed
class ViewEngineersState with _$ViewEngineersState {
  const factory ViewEngineersState.initial() = _Initial;
  const factory ViewEngineersState.loading() = _Loading;
  const factory ViewEngineersState.success({
    required EngineerProfileModel response,
  }) = _Success;
  const factory ViewEngineersState.error({required String error}) = _Error;
}
