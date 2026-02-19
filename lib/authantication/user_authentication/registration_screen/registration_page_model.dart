class UserRegistrationModel {
  int? id;
  String name;
  String password;
  String email;
  String phone;
  String address;

  UserRegistrationModel({
    this.id,
    required this.name,
    required this.password,
    required this.email,
    required this.phone,
    required this.address,
  });

  factory UserRegistrationModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? data = json['data']; // Get the 'data' map

    return UserRegistrationModel(
      id: data != null && data['id'] != null ? data['id'] as int : null,
      name: data != null ? data['name'] ?? '' : '',
      password: data != null ? data['password'] ?? '' : '',
      email: data != null ? data['email'] ?? '' : '',
      phone: data != null ? data['phone'] ?? '' : '',
      address: data != null ? data['address'] ?? '' : '',
    );
  }
}
