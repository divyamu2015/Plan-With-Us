import 'dart:convert';

import 'package:house_construction_pro/constant_page.dart';
import 'package:house_construction_pro/screen/user_screen/house_details/property_input_model.dart';
import 'package:http/http.dart' as http;

Future<PropertyDetailModel> fetchPropertyDetails({
  required int categoryId,
  required double cent,
  required double sqft,
  required double amount,
  required int userId,
}) async {
  try {
    final Map<String, dynamic> body = {
      "category": categoryId,
      "user_id": userId,
      "sqft": sqft,
      "cent": cent,
      "expected_amount": amount,
    };
   final res = await http.post(
      Uri.parse(Urlss.propertyDetails),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    final Map<String, dynamic> jsonMap = jsonDecode(res.body);
  
    if (res.statusCode == 200 || res.statusCode == 201) {
      final response = PropertyDetailModel.fromJson(jsonMap);
      return response;
    } else {
      throw Exception("Failed to fetch property details: ${res.statusCode}");
    }
  } catch (e) {
    throw Exception(e.toString());
  }
}
