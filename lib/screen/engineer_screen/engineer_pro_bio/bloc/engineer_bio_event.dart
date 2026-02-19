part of 'engineer_bio_bloc.dart';

@freezed
class EngineerBioEvent with _$EngineerBioEvent {
  const factory EngineerBioEvent.started() = _Started;
  const factory EngineerBioEvent.uploadEngBio({
     required int engineerId,
    required String projectName,
    required int categoryId,
    required double cent,
    required double squareFeet,
    required int expectedAmount,
    required int additionalAmount,
    required double totalAmount,
    required List<int> additionalFeatures,
    required String timeDuration,
    required List<File> images,
     File? profileImage
  }) = _UploadEngBio;
  
}