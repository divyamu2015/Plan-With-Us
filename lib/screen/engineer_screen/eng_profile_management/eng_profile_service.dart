import 'dart:convert';

import 'package:house_construction_pro/screen/engineer_screen/eng_profile_management/eng_profile_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

Future<EngiProManagModel> getEngineerProfile({
  required XFile profilePic,
  required String name,
  required String email,
  required String password,
  required String address,
  required String status,
  required int phone,
  required int emploId,
}) async {
  try {
    final url = Uri.parse(
      'https://417sptdw-8001.inc1.devtunnels.ms/userapp/engineer/profile/$emploId/',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
    final jsonData=  jsonDecode(response.body);
    return EngiProManagModel.fromJson(jsonData);
    } else {
      throw Exception(
        'Failed to load profile. Status code: ${response.statusCode}',
      );
    }
  } catch (e) {
    throw Exception('Error fetching profile: $e');
  }
}