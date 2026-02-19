import 'dart:convert';
import 'dart:io';
import 'package:house_construction_pro/constant_page.dart';
import 'package:house_construction_pro/screen/engineer_screen/engineer_pro_bio/engineer_bio_model.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

Future<EngineerBioModel> uploadEngineerBio({
  required int engineerId,
  required String projectName,
  required int categoryId,
  required double cent,
  required double squareFeet,
  required int expectedAmount,
  required int additionalAmount,
  required double totalAmount, // If this is int, use int and .toString()
  required List<int> additionalFeatures,
  required String timeDuration,
  required List<File> images,
  required File profileImage,
}) async {
  final url = Uri.parse(Urlss.engineerBioUpload);

  var request = http.MultipartRequest('POST', url);

  request.fields['engineer'] = engineerId.toString();
  request.fields['project_name'] = projectName;
  request.fields['category'] = categoryId.toString();
  request.fields['cent'] = cent.toString();
  request.fields['squarefeet'] = squareFeet.toString();
  request.fields['expected_amount'] = expectedAmount.toString();
  request.fields['additional_amount'] = additionalAmount.toString();
  request.fields['total_amount'] = totalAmount.toString();
  request.fields['time_duration'] = timeDuration;

  // Attach each feature as additional_features[], as per standard multipart and your backend
  for (var i = 0; i < additionalFeatures.length; i++) {
    request.fields['additional_features[$i]'] = additionalFeatures[i]
        .toString();
  }
  request.files.add(
    await http.MultipartFile.fromPath(
      'property_image', // must match backend field name
      profileImage.path,
      filename: basename(profileImage.path),
    ),
  );
  // Attach each image file
  for (var image in images) {
    request.files.add(
      await http.MultipartFile.fromPath(
        'images', // field name for the backend
        image.path,
        filename: basename(image.path),
      ),
    );
  }

  var streamedResponse = await request.send();
  var response = await http.Response.fromStream(streamedResponse);

  if (response.statusCode == 200 || response.statusCode == 201) {
    final data = jsonDecode(response.body);
    return EngineerBioModel.fromJson(data);
  } else {
    throw Exception('Upload Failed: ${response.statusCode} - ${response.body}');
  }
}
