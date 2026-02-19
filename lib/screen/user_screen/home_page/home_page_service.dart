import 'dart:convert';

import 'package:house_construction_pro/constant_page.dart';
import 'package:house_construction_pro/screen/user_screen/home_page/home_page_model.dart';
import 'package:http/http.dart' as http;

Future<HouseSearchModel> fetchHouseSearch({
  required int userId,
  required int category,
  required double cent,
  required double sqft,
  required double expectedAmount,
}) async {
  final Map<String, dynamic> body = {
    "user_id": userId,
    "category": category,
    "cent": cent,
    "sqft": sqft,
    "expected_amount": expectedAmount,
  };

  final response = await http.post(
    Uri.parse(Urlss.propertyDetails),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(body),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    final jsonData = jsonDecode(response.body);
    return HouseSearchModel.fromJson(jsonData);
  } else {
    throw Exception("Failed to fetch search results");
  }
}
