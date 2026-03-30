import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:house_construction_pro/screen/user_screen/request_view/request_model.dart';

Future<GetPropertyInputModel> getUserRequests(int userId, int requestId) async {
  final url = Uri.parse(
    'https://417sptdw-8001.inc1.devtunnels.ms/userapp/register/$userId/',
  );
 // print('request service url=== $url');
  final response = await http.get(url);
  if (response.statusCode == 200) {
    //print(response.statusCode);
    //print(response.body);

    final jsonData = jsonDecode(response.body);
    //print(jsonData);
    return GetPropertyInputModel.fromJson(jsonData);
  } else {
    throw Exception(
      'Failed to load profile. Status code: ${response.statusCode}',
    );
  }
}
