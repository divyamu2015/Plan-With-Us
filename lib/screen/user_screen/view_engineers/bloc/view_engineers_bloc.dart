import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:house_construction_pro/screen/user_screen/view_engineers/view_engineers_model.dart';
import 'package:house_construction_pro/screen/user_screen/view_engineers/view_engineers_service.dart';


part 'view_engineers_event.dart';
part 'view_engineers_state.dart';
part 'view_engineers_bloc.freezed.dart';

class ViewEngineersBloc extends Bloc<ViewEngineersEvent, ViewEngineersState> {
  ViewEngineersBloc() : super(const ViewEngineersState.initial()) {
    on<_GetEngineerDetails>((event, emit) async {
      emit(const ViewEngineersState.loading());
      try {
        final response = await fetchEngineerProfile(event.engineerId,event.workId);
        emit(ViewEngineersState.success(response: response));
      } catch (e) {
        emit(ViewEngineersState.error(error: e.toString()));
      }
    });
  }
}