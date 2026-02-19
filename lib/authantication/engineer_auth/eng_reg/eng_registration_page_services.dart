import 'dart:convert';
import 'dart:io';
import 'package:house_construction_pro/authantication/engineer_auth/eng_reg/eng_registration_page_model.dart';
import 'package:house_construction_pro/constant_page.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

Future<EngineeringRegModel> engineerRegister({
  required String name,
  required String password,
  required String email,
  required int phone,
  required String address,
  required XFile profilePic,
  required XFile workCertificate,
}) async {
  try {
    // Prepare the multipart request
    var request = http.MultipartRequest('POST', Uri.parse(Urlss.engineerReguri));

    // Adding text fields
    request.fields['name'] = name;
    request.fields['password'] = password;
    request.fields['email'] = email;
    request.fields['phone'] = phone.toString();
    request.fields['address'] = address;
     request.files.add(
      await http.MultipartFile.fromPath(
        'profile_image',
        profilePic.path,
      ),
    );
    request.files.add(
      await http.MultipartFile.fromPath('id_proof',
        workCertificate.path,)
    );

   

    // Sending request
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

   // print(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      return EngineeringRegModel.fromJson(decoded);
    } else {
      throw Exception("Failed to register user: ${response.statusCode}");
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
