import 'dart:convert';
import 'package:http/http.dart' as http;
import 'view_engineers_model.dart';

Future<EngineerProfileModel> fetchEngineerProfile(
  int engineerId,
  int workId,
) async {
  final url = Uri.parse(
    "https://417sptdw-8001.inc1.devtunnels.ms/userapp/engineers/$engineerId/works/$workId/",
  );
 // print(url);
  final response = await http.get(url);
  if (response.statusCode == 200) {
    final jsonData = jsonDecode(response.body);
    return EngineerProfileModel.fromJson(jsonData);
  } else {
    throw Exception(
      'Failed to load profile. Status code: ${response.statusCode}',
    );
  }
}
