import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:house_construction_pro/screen/engineer_screen/engineer_pro_bio/engineer_bio_model.dart';
import 'package:house_construction_pro/screen/engineer_screen/engineer_pro_bio/engineer_bio_services.dart';

part 'engineer_bio_event.dart';
part 'engineer_bio_state.dart';
part 'engineer_bio_bloc.freezed.dart';

class EngineerBioBloc extends Bloc<EngineerBioEvent, EngineerBioState> {
  EngineerBioBloc() : super(_Initial()) {
    on<_UploadEngBio>((event, emit) async {
      emit(const EngineerBioState.loading());
      try {
        final response = await uploadEngineerBio(
          engineerId: event.engineerId,
          projectName: event.projectName,
          categoryId: event.categoryId,
          cent: event.cent,
          squareFeet: event.squareFeet,
          expectedAmount: event.expectedAmount,
          additionalAmount: event.additionalAmount,
          totalAmount: event.totalAmount,
          additionalFeatures: event.additionalFeatures,
          timeDuration: event.timeDuration,
          images: event.images,
         profileImage: event.profileImage!
        );
       // print(response);
      //  print("Bloc response: $response");
          emit(EngineerBioState.success(response: response));
        } catch (e) {
          emit(EngineerBioState.error(error: e.toString()));
        //  print('error:${e.toString()}');
        }
    });
  }
}
