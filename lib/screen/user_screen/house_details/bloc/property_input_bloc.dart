import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:house_construction_pro/screen/user_screen/house_details/property_input_model.dart';
import 'package:house_construction_pro/screen/user_screen/house_details/property_input_service.dart';

part 'property_input_event.dart';
part 'property_input_state.dart';
part 'property_input_bloc.freezed.dart';

class PropertyInputBloc extends Bloc<PropertyInputEvent, PropertyInputState> {
 String? _currentRequestId; // Track current processing request
  
  PropertyInputBloc() : super(_Initial()) {
    on<_PropertySub>((event, emit) async {
      // Create unique request ID
      final requestId = '${event.userId}_${event.category}_${event.cent}_${DateTime.now().millisecondsSinceEpoch}';
      
      // If already processing the same request, ignore
      if (_currentRequestId == requestId) {
        return;
      }
      
      // If any request is being processed, block new ones
      if (state is _Loading) {
        return;
      }

      _currentRequestId = requestId;
      emit(const PropertyInputState.loading());
      
      try {
        final response = await fetchPropertyDetails(
          cent: event.cent,
          sqft: event.sgft,
          amount: event.amount,
          categoryId: event.category,
          userId: event.userId,
        );
        
        emit(PropertyInputState.success(response: response));
        _currentRequestId = null; // Reset after success
      } catch (e) {
        emit(PropertyInputState.error(error: e.toString()));
        _currentRequestId = null; // Reset after error
      }
    });
  }
}
