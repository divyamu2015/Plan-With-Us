import 'dart:convert';
import 'dart:io';

import 'package:house_construction_pro/authantication/user_authentication/login_screen/login_model_page.dart';
import 'package:house_construction_pro/constant_page.dart';
import 'package:http/http.dart' as http;

Future<UserLoginModel> userLogin({
  required String role,
  required String email,
  required String password, 
  //required String userId,
  //  required this.role,
  //  required this.email,
  //  required this.password
}) async {
  try {
    final Map<String, dynamic> body = {
      "user_type": role,
      "email": email,
      "password": password,

      // "user_type": userType,
      // "email": email,
      // "password": password,
    };
    final res = await http.post(
      Uri.parse(Urlss.loginPageuri),
      headers: <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    final Map<String, dynamic> decoded = jsonDecode(res.body);

    if (res.statusCode == 200) {
      final response = UserLoginModel.fromJson(decoded);
      return response;
    } else {
      throw Exception("Failed to login User ${res.statusCode}");
    }
  } on SocketException {
    throw Exception('Server Error');
  } on HttpException {
    throw Exception('Something went wrong');
  } on FormatException {
    throw Exception('Bad Request');
  } catch (e) {
    throw Exception(e.toString());
  }
}
