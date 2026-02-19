import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:house_construction_pro/screen/user_screen/request_view/request_model.dart';
import 'package:house_construction_pro/screen/user_screen/request_view/request_service.dart';

part 'request_event.dart';
part 'request_state.dart';
part 'request_bloc.freezed.dart';

class RequestBloc extends Bloc<RequestEvent, RequestState> {
  RequestBloc() : super(_Initial()) {
    on<_getUserDetails>((event, emit) async {
      emit(const RequestState.loading());
      try {
        final response = await getUserRequests(
          event.userId,
          event.requestId);
        emit(RequestState.success(response: response));
      } catch (e) {
     
        emit(RequestState.error(error: e.toString()));
      }
    });
  }
}
