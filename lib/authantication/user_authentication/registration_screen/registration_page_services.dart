import 'dart:convert';
import 'dart:io';
import 'package:house_construction_pro/authantication/user_authentication/registration_screen/registration_page_model.dart';
import 'package:house_construction_pro/constant_page.dart';
import 'package:http/http.dart' as http;

Future<UserRegistrationModel> userRegister({
  // required String id,
  required String name,
  required String password,
  required String email,
  required String phone,
  required String address,
}) async {
  try {
    
    final Map<String, dynamic> body = {
      "name": name,
      "password": password,
      "email": email,
      "phone": phone,
      "address": address,
    }; 
    final res = await http.post(
      Uri.parse(Urlss.regPageuri),
      headers: <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    final Map<String, dynamic> decoded = jsonDecode(res.body);
   // print(res.body);

    if (res.statusCode == 200 || res.statusCode == 201) {
    //  print(res.statusCode);
      //  final Map<String, dynamic> decoded = jsonDecode(res.body);
      final response = UserRegistrationModel.fromJson(decoded);
      return response;
    } else {
      throw Exception("Failed to register user: ${res.statusCode}");
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
